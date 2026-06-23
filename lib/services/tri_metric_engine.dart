import 'dart:math' as math;
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/cycle_engine.dart';

/// The engine managing calculations for the three parent wellness vectors:
/// - Body: Energy, Wakefulness, Recovery
/// - Mind: Focus, Creativity, Motivation
/// - Soul: Mood, Social Bandwidth, Stability
class TriMetricEngine {
  /// Computes the sub-metric values for a specific cycle day, length, and period duration,
  /// adjusting for symptoms logged on that date.
  static Map<String, int> calculateSubMetrics(
      int day, int cycleLength, int periodDuration, List<String> loggedSymptoms) {
    // 1. Calculate Baselines based on the phase progression
    double body = 0.0;
    double mind = 0.0;
    double soul = 0.0;

    int ovulationDay = cycleLength - 14;
    if (ovulationDay <= periodDuration) {
      ovulationDay = periodDuration + 2;
    }

    int preMenstrualStart = cycleLength - 4;
    if (preMenstrualStart <= ovulationDay) {
      preMenstrualStart = cycleLength - 2;
    }

    // Offsets for sub-metrics relative to the parent metrics (guaranteed sum = 0)
    double energyOffset = 0.0;
    double wakefulnessOffset = 0.0;
    double recoveryOffset = 0.0;

    double focusOffset = 0.0;
    double creativityOffset = 0.0;
    double motivationOffset = 0.0;

    double moodOffset = 0.0;
    double socialOffset = 0.0;
    double stabilityOffset = 0.0;

    if (day <= periodDuration) {
      // Phase 1: Menstruation
      double progress = day / periodDuration;
      body = 35.0 + progress * 10.0;
      mind = 50.0 + progress * 10.0;
      soul = 30.0 + progress * 15.0;

      energyOffset = -4.0;
      recoveryOffset = 2.0;
      wakefulnessOffset = 2.0;

      focusOffset = 5.0;
      creativityOffset = 0.0;
      motivationOffset = -5.0;

      moodOffset = 0.0;
      socialOffset = -10.0;
      stabilityOffset = 10.0;
    } else if (day < ovulationDay) {
      // Phase 2: Follicular Phase
      int follicularLength = ovulationDay - periodDuration;
      double progress = (day - periodDuration) / follicularLength;
      progress = progress.clamp(0.0, 1.0);

      body = 45.0 + progress * 43.0;

      double focusDay = periodDuration + (follicularLength * 0.6).roundToDouble();
      if (day <= focusDay) {
        double p = (focusDay - periodDuration) > 0 
            ? (day - periodDuration) / (focusDay - periodDuration) 
            : 0.5;
        mind = 60.0 + p * 30.0;
      } else {
        double p = (ovulationDay - focusDay) > 0 
            ? (day - focusDay) / (ovulationDay - focusDay) 
            : 0.5;
        mind = 90.0 - p * 12.0;
      }

      soul = 45.0 + progress * 40.0;

      energyOffset = 3.0 + progress * 7.0;
      recoveryOffset = -3.0 - progress * 9.0;
      wakefulnessOffset = -(energyOffset + recoveryOffset);

      focusOffset = 5.0 - progress * 10.0;
      creativityOffset = 2.0 + progress * 8.0;
      motivationOffset = -(focusOffset + creativityOffset);

      moodOffset = 0.0;
      socialOffset = -10.0 + progress * 15.0;
      stabilityOffset = 10.0 - progress * 15.0;
    } else if (day == ovulationDay) {
      // Phase 3: Ovulation
      body = 90.0;
      mind = 75.0;
      soul = 95.0;

      energyOffset = 10.0;
      recoveryOffset = -15.0;
      wakefulnessOffset = 5.0;

      focusOffset = -5.0;
      creativityOffset = 10.0;
      motivationOffset = -5.0;

      moodOffset = 5.0;
      socialOffset = 10.0;
      stabilityOffset = -15.0;
    } else if (day < preMenstrualStart) {
      // Phase 4: Luteal Phase
      int lutealLength = preMenstrualStart - ovulationDay;
      double progress = (day - ovulationDay) / lutealLength;
      progress = progress.clamp(0.0, 1.0);

      double lutealDrop = progress * 20.0;
      double progesteroneBump = math.sin(progress * math.pi) * 12.0;
      body = 90.0 - lutealDrop + progesteroneBump;

      double mindProgress = 1.0 - (progress - 0.5).abs() * 2.0;
      mindProgress = mindProgress.clamp(0.0, 1.0);
      mind = 75.0 + mindProgress * 9.0;

      soul = 95.0 - progress * 37.0;

      energyOffset = 10.0 - progress * 20.0;
      recoveryOffset = -15.0 + progress * 25.0;
      wakefulnessOffset = -(energyOffset + recoveryOffset);

      focusOffset = -5.0 + progress * 15.0;
      creativityOffset = 10.0 - progress * 15.0;
      motivationOffset = -(focusOffset + creativityOffset);

      moodOffset = 5.0 - progress * 5.0;
      socialOffset = 10.0 - progress * 30.0;
      stabilityOffset = -(moodOffset + socialOffset);
    } else {
      // Phase 5: Pre-menstrual Phase (PMS)
      int pmLength = cycleLength - preMenstrualStart + 1;
      double progress = (day - preMenstrualStart) / pmLength;
      progress = progress.clamp(0.0, 1.0);

      body = 70.0 - progress * 35.0;
      mind = 75.0 - progress * 25.0;
      soul = 58.0 - progress * 28.0;

      energyOffset = -10.0;
      recoveryOffset = 10.0 - progress * 8.0;
      wakefulnessOffset = -(energyOffset + recoveryOffset);

      focusOffset = 10.0 - progress * 5.0;
      creativityOffset = -5.0;
      motivationOffset = -(focusOffset + creativityOffset);

      moodOffset = 0.0;
      stabilityOffset = 20.0 - progress * 20.0;
      socialOffset = -20.0 + progress * 20.0;
    }

    Map<String, double> baselines = {
      'Energy': body + energyOffset,
      'Wakefulness': body + wakefulnessOffset,
      'Recovery': body + recoveryOffset,
      'Focus': mind + focusOffset,
      'Creativity': mind + creativityOffset,
      'Motivation': mind + motivationOffset,
      'Mood': soul + moodOffset,
      'SocialBandwidth': soul + socialOffset,
      'Stability': soul + stabilityOffset,
    };
    
    // 2. Adjust for Logged Symptoms
    Map<String, double> adjustments = {
      'Energy': 0.0, 'Wakefulness': 0.0, 'Recovery': 0.0,
      'Focus': 0.0, 'Creativity': 0.0, 'Motivation': 0.0,
      'Mood': 0.0, 'SocialBandwidth': 0.0, 'Stability': 0.0
    };
    
    for (final symptom in loggedSymptoms) {
      final s = symptom.toLowerCase().trim();
      if (s == 'cramps' || s == 'abdominal cramps') {
        adjustments['Energy'] = adjustments['Energy']! - 15.0;
        adjustments['Recovery'] = adjustments['Recovery']! - 15.0;
        adjustments['Stability'] = adjustments['Stability']! - 10.0;
      } else if (s == 'headache' || s == 'migraine') {
        adjustments['Focus'] = adjustments['Focus']! - 20.0;
        adjustments['Energy'] = adjustments['Energy']! - 10.0;
        adjustments['Stability'] = adjustments['Stability']! - 5.0;
      } else if (s == 'fatigue' || s == 'tiredness') {
        adjustments['Energy'] = adjustments['Energy']! - 25.0;
        adjustments['Wakefulness'] = adjustments['Wakefulness']! - 20.0;
        adjustments['Motivation'] = adjustments['Motivation']! - 15.0;
      } else if (s == 'mood swings' || s == 'mood_swings' || s == 'irritability') {
        adjustments['Mood'] = adjustments['Mood']! - 20.0;
        adjustments['Stability'] = adjustments['Stability']! - 25.0;
        adjustments['SocialBandwidth'] = adjustments['SocialBandwidth']! - 15.0;
      } else if (s == 'stress' || s == 'anxiety') {
        adjustments['Stability'] = adjustments['Stability']! - 15.0;
        adjustments['Focus'] = adjustments['Focus']! - 10.0;
        adjustments['Wakefulness'] = adjustments['Wakefulness']! - 10.0;
      } else if (s == 'bloating') {
        adjustments['Energy'] = adjustments['Energy']! - 5.0;
        adjustments['Recovery'] = adjustments['Recovery']! - 5.0;
      }
    }
    
    // Deterministic daily noise to add micro-fluctuations (prevents perfectly parallel lines)
    double getNoise(String metric, int dayNum) {
      final double angle = (dayNum * 47.0 + metric.hashCode % 100) * (math.pi / 180.0);
      return math.sin(angle) * 3.5;
    }
    
    // Compile adjusted scores (cap between 5 and 100)
    Map<String, int> finalScores = {};
    baselines.forEach((key, val) {
      double adj = adjustments[key] ?? 0.0;
      double noiseVal = getNoise(key, day);
      double finalVal = (val + adj + noiseVal).clamp(5.0, 100.0);
      finalScores[key] = finalVal.round();
    });
    
    return finalScores;
  }

  /// Retrieves symptoms logged on a specific date.
  static List<String> getSymptomsForDate(DateTime date) {
    final box = StorageService.settingsBox;
    final dateKey = 'log_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final logData = box.get(dateKey);
    if (logData != null && logData is Map) {
      final List<dynamic>? list = logData['symptoms'] as List<dynamic>?;
      if (list != null) {
        return list.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  /// Calculates parent scores (Body, Mind, Soul) and sub-metrics for a specific target date.
  static Map<String, dynamic> calculateMetricsForDate(DateTime date) {
    final box = StorageService.settingsBox;
    final int periodDuration = box.get('average_period_duration', defaultValue: 5) as int;
    final double avgLengthDouble = CycleEngine.getAverageCycleLength();
    final int avgLength = avgLengthDouble.round();
    
    // Find active cycle day on that date
    final int cycleDay = CycleEngine.getCycleDay(targetDate: date);
    final symptoms = getSymptomsForDate(date);
    
    final subMetrics = calculateSubMetrics(cycleDay, avgLength, periodDuration, symptoms);
    
    // Parent components are simple averages of sub-metrics
    int bodyScore = ((subMetrics['Energy']! + subMetrics['Wakefulness']! + subMetrics['Recovery']!) / 3).round();
    int mindScore = ((subMetrics['Focus']! + subMetrics['Creativity']! + subMetrics['Motivation']!) / 3).round();
    int soulScore = ((subMetrics['Mood']! + subMetrics['SocialBandwidth']! + subMetrics['Stability']!) / 3).round();
    
    return {
      'body': bodyScore,
      'mind': mindScore,
      'soul': soulScore,
      'body_tier': getTierForScore(bodyScore),
      'mind_tier': getTierForScore(mindScore),
      'soul_tier': getTierForScore(soulScore),
      'sub_metrics': subMetrics,
    };
  }

  /// Classifies a score into Low, Medium, or High (Section 10.2).
  static String getTierForScore(int score) {
    if (score <= 45) {
      return 'Low';
    } else if (score <= 75) {
      return 'Moderate';
    } else {
      return 'High';
    }
  }

  /// Under premium tier, calculates forecasted parent scores for the next 7 consecutive days (Section 5.2).
  static List<Map<String, dynamic>> calculate7DayForecast() {
    final isPremium = StorageService.settingsBox.get('user_is_premium', defaultValue: false) as bool;
    if (!isPremium) {
      return []; // Return empty if free tier
    }
    
    List<Map<String, dynamic>> forecast = [];
    final today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final forecastDate = today.add(Duration(days: i));
      final metrics = calculateMetricsForDate(forecastDate);
      forecast.add({
        'date': forecastDate,
        'body': metrics['body'],
        'mind': metrics['mind'],
        'soul': metrics['soul'],
        'body_tier': metrics['body_tier'],
        'mind_tier': metrics['mind_tier'],
        'soul_tier': metrics['soul_tier'],
      });
    }
    return forecast;
  }
}
