import 'package:irma/services/storage_service.dart';

/// The computational engine managing period tracking, phase projections,
/// early overrides, and rolling average outlier filters.
class CycleEngine {
  /// Retrieves all recorded period start dates, sorted chronologically.
  static List<DateTime> getCycleStarts() {
    final box = StorageService.settingsBox;
    final List<dynamic>? startsList = box.get('cycle_starts') as List<dynamic>?;
    
    if (startsList == null || startsList.isEmpty) {
      // Fallback to the date captured during onboarding
      final onsetStr = box.get('last_period_start_date') as String?;
      if (onsetStr != null) {
        return [DateTime.parse(onsetStr)];
      }
      return [DateTime.now().subtract(const Duration(days: 14))];
    }
    
    final dates = startsList.map((e) => DateTime.parse(e as String)).toList();
    dates.sort();
    return dates;
  }

  /// Logs a new period onset date, resetting active cycle to Day 1.
  /// This implements the Immediate State-Overriding & Reset Logic (Section 7.2).
  static Future<void> logPeriodStart(DateTime date) async {
    final box = StorageService.settingsBox;
    final dates = getCycleStarts();
    
    // Normalize date to midnight to prevent timezone/hour shifting anomalies
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Avoid duplicate entries for the same day
    final exists = dates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
        
    if (!exists) {
      dates.add(normalizedDate);
      dates.sort();
      final stringList = dates.map((d) => d.toIso8601String()).toList();
      await box.put('cycle_starts', stringList);
      
      // Update the active tracking anchor to the most recent start date
      final latest = dates.last;
      await box.put('last_period_start_date', latest.toIso8601String());
    }
  }

  /// Removes a period start date. Useful for undoing incorrect logs.
  static Future<void> removePeriodStart(DateTime date) async {
    final box = StorageService.settingsBox;
    final dates = getCycleStarts();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    dates.removeWhere((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
        
    dates.sort();
    final stringList = dates.map((d) => d.toIso8601String()).toList();
    await box.put('cycle_starts', stringList);
    
    if (dates.isNotEmpty) {
      await box.put('last_period_start_date', dates.last.toIso8601String());
    } else {
      await box.delete('last_period_start_date');
    }
  }

  /// Calculates historical cycle lengths between recorded starts.
  static List<int> getCycleLengths() {
    final starts = getCycleStarts();
    if (starts.length < 2) return [];
    
    List<int> lengths = [];
    for (int i = 0; i < starts.length - 1; i++) {
      lengths.add(starts[i + 1].difference(starts[i]).inDays);
    }
    return lengths;
  }

  /// Computes the running average of cycle lengths, excluding outliers (Section 7.4).
  static double getAverageCycleLength() {
    final box = StorageService.settingsBox;
    final onboardingDefault = box.get('average_cycle_length', defaultValue: 28) as int;
    final lengths = getCycleLengths();
    
    if (lengths.isEmpty) {
      return onboardingDefault.toDouble();
    }
    
    // Filter 1: physiological limits (18-45 days)
    List<int> step1Lengths = [];
    for (final len in lengths) {
      if (len >= 18 && len <= 45) {
        step1Lengths.add(len);
      }
    }
    
    if (step1Lengths.isEmpty) {
      return onboardingDefault.toDouble();
    }
    
    // Filter 2: statistical outlier filter (Section 7.4: deviates by > 8 days from mean)
    final double initialMean = step1Lengths.reduce((a, b) => a + b) / step1Lengths.length;
    List<int> filteredLengths = [];
    for (final len in step1Lengths) {
      if ((len - initialMean).abs() <= 8) {
        filteredLengths.add(len);
      }
    }
    
    if (filteredLengths.isEmpty) {
      return initialMean;
    }
    
    return filteredLengths.reduce((a, b) => a + b) / filteredLengths.length;
  }

  /// Determines if a specific historical cycle index was an outlier.
  static bool isCycleOutlier(int length, double averageLength) {
    if (length < 18 || length > 45) return true;
    if ((length - averageLength).abs() > 8) return true;
    return false;
  }

  /// Calculates the active day in the cycle relative to the most recent onset.
  static int getCycleDay({DateTime? targetDate}) {
    final queryDate = targetDate ?? DateTime.now();
    final normalizedQuery = DateTime(queryDate.year, queryDate.month, queryDate.day);
    
    final starts = getCycleStarts();
    
    // Find the most recent cycle start that occurs on or before the query date
    DateTime? activeAnchor;
    for (final start in starts.reversed) {
      if (start.isBefore(normalizedQuery) ||
          (start.year == normalizedQuery.year &&
           start.month == normalizedQuery.month &&
           start.day == normalizedQuery.day)) {
        activeAnchor = start;
        break;
      }
    }
    
    // Fallback if query date precedes all recorded starts
    activeAnchor ??= starts.first;
    
    return normalizedQuery.difference(activeAnchor).inDays + 1;
  }

  /// Maps a specific cycle day number to one of the 5 physiological states (Section 7.1).
  static String getPhaseForDay(int day, int cycleLength, int periodDuration) {
    // Days ≤ 0 are before the cycle anchor (prior cycle) — do not classify
    if (day <= 0) return 'Unknown';

    if (day <= periodDuration) {
      return 'Menstruation';
    }
    
    // Ovulation occurs approximately 14 days before the next cycle
    int ovulationDay = cycleLength - 14;
    
    // Safety check for short cycles / long periods
    if (ovulationDay <= periodDuration) {
      ovulationDay = periodDuration + 2;
    }
    
    if (day < ovulationDay) {
      return 'Follicular Phase';
    } else if (day == ovulationDay) {
      return 'Ovulation';
    }
    
    // Pre-menstrual phase is the last 5 days of the cycle
    int preMenstrualStart = cycleLength - 4;
    if (preMenstrualStart <= ovulationDay) {
      preMenstrualStart = cycleLength - 2;
    }
    
    if (day < preMenstrualStart) {
      return 'Luteal Phase';
    } else {
      return 'Pre-menstrual Phase';
    }
  }

  /// Returns the details of the current cycle.
  static Map<String, dynamic> getCurrentCycleState({DateTime? targetDate}) {
    final box = StorageService.settingsBox;
    final int periodDuration = box.get('average_period_duration', defaultValue: 5) as int;
    final double avgLengthDouble = getAverageCycleLength();
    final int avgLength = avgLengthDouble.round();
    
    final int currentDay = getCycleDay(targetDate: targetDate);
    final String currentPhase = getPhaseForDay(currentDay, avgLength, periodDuration);
    
    // Days until next period is forecasted
    int daysUntilNext = avgLength - currentDay + 1;
    if (daysUntilNext < 0) {
      // User is late
      daysUntilNext = 0;
    }
    
    return {
      'day': currentDay,
      'phase': currentPhase,
      'average_length': avgLength,
      'period_duration': periodDuration,
      'days_until_next': daysUntilNext,
      'is_late': currentDay > avgLength,
    };
  }
}
