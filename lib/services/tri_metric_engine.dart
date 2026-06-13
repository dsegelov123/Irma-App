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
    Map<String, double> baselines = {};
    
    if (day <= periodDuration) {
      // Phase 1: Menstruation
      double progress = day / periodDuration;
      baselines['Energy'] = 40.0 + (progress * 15);
      baselines['Wakefulness'] = 45.0 + (progress * 15);
      baselines['Recovery'] = 40.0 + (progress * 20);
      
      baselines['Focus'] = 55.0 + (progress * 10);
      baselines['Creativity'] = 50.0 + (progress * 15);
      baselines['Motivation'] = 40.0 + (progress * 20);
      
      baselines['Mood'] = 45.0 + (progress * 20);
      baselines['SocialBandwidth'] = 30.0 + (progress * 25);
      baselines['Stability'] = 40.0 + (progress * 25);
    } else {
      int ovulationDay = cycleLength - 14;
      if (ovulationDay <= periodDuration) {
        ovulationDay = periodDuration + 2;
      }
      
      if (day < ovulationDay) {
        // Phase 2: Follicular Phase
        int follicularLength = ovulationDay - periodDuration - 1;
        double progress = follicularLength > 0 ? (day - periodDuration - 1) / follicularLength : 0.5;
        progress = progress.clamp(0.0, 1.0);
        
        baselines['Energy'] = 55.0 + (progress * 30);
        baselines['Wakefulness'] = 60.0 + (progress * 25);
        baselines['Recovery'] = 60.0 + (progress * 20);
        
        baselines['Focus'] = 65.0 + (progress * 20);
        baselines['Creativity'] = 65.0 + (progress * 25);
        baselines['Motivation'] = 60.0 + (progress * 25);
        
        baselines['Mood'] = 65.0 + (progress * 25);
        baselines['SocialBandwidth'] = 55.0 + (progress * 35);
        baselines['Stability'] = 65.0 + (progress * 20);
      } else if (day == ovulationDay) {
        // Phase 3: Ovulation (Peak)
        baselines['Energy'] = 90.0;
        baselines['Wakefulness'] = 85.0;
        baselines['Recovery'] = 80.0;
        
        baselines['Focus'] = 88.0;
        baselines['Creativity'] = 90.0;
        baselines['Motivation'] = 90.0;
        
        baselines['Mood'] = 92.0;
        baselines['SocialBandwidth'] = 95.0;
        baselines['Stability'] = 85.0;
      } else {
        int preMenstrualStart = cycleLength - 4;
        if (preMenstrualStart <= ovulationDay) {
          preMenstrualStart = cycleLength - 2;
        }
        
        if (day < preMenstrualStart) {
          // Phase 4: Luteal Phase
          int lutealLength = preMenstrualStart - ovulationDay - 1;
          double progress = lutealLength > 0 ? (day - ovulationDay - 1) / lutealLength : 0.5;
          progress = progress.clamp(0.0, 1.0);
          
          baselines['Energy'] = 85.0 - (progress * 15);
          baselines['Wakefulness'] = 80.0 - (progress * 10);
          baselines['Recovery'] = 80.0 - (progress * 5);
          
          baselines['Focus'] = 85.0 - (progress * 15);
          baselines['Creativity'] = 85.0 - (progress * 20);
          baselines['Motivation'] = 85.0 - (progress * 20);
          
          baselines['Mood'] = 88.0 - (progress * 20);
          baselines['SocialBandwidth'] = 85.0 - (progress * 30);
          baselines['Stability'] = 80.0 - (progress * 15);
        } else {
          // Phase 5: Pre-menstrual Phase
          int pmLength = cycleLength - preMenstrualStart + 1;
          double progress = pmLength > 0 ? (day - preMenstrualStart) / pmLength : 0.5;
          progress = progress.clamp(0.0, 1.0);
          
          baselines['Energy'] = 70.0 - (progress * 25);
          baselines['Wakefulness'] = 70.0 - (progress * 20);
          baselines['Recovery'] = 75.0 - (progress * 25);
          
          baselines['Focus'] = 70.0 - (progress * 25);
          baselines['Creativity'] = 65.0 - (progress * 15);
          baselines['Motivation'] = 65.0 - (progress * 25);
          
          baselines['Mood'] = 68.0 - (progress * 28);
          baselines['SocialBandwidth'] = 55.0 - (progress * 25);
          baselines['Stability'] = 65.0 - (progress * 30);
        }
      }
    }
    
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
    
    // Compile adjusted scores (cap between 5 and 100)
    Map<String, int> finalScores = {};
    baselines.forEach((key, val) {
      double adj = adjustments[key] ?? 0.0;
      double finalVal = (val + adj).clamp(5.0, 100.0);
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
    if (score < 45) {
      return 'Low';
    } else if (score <= 75) {
      return 'Medium';
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
