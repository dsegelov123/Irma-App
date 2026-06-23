import 'package:irma/services/storage_service.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/tri_metric_engine.dart';

/// Service generating NHS-grounded daily advice and notifications,
/// strictly conforming to the Irma wise aunt character persona (Section 6).
class AdviceService {
  // Localized NHS clinical guidance snippets (Section 2.3)
  static const Map<String, String> _nhsGuidance = {
    'menstruation': 'During menstruation, your body\'s energy is naturally directed towards uterine shedding. NHS clinical guidelines suggest gentle activity like walking or stretching, which releases endorphins to help alleviate cramps. Prioritise rest and warm baths to aid recovery.',
    'follicular': 'During the follicular phase, rising oestrogen levels naturally boost your focus, creativity, and motivation. It is a highly productive window for planning and launching new projects. Maintain balanced nutrition to support this metabolic shift.',
    'ovulation': 'Ovulation represents your monthly physical peak, driven by elevated oestrogen. While social bandwidth and mood are high, ensure you get regular sleep to support your body through this natural energy spike.',
    'luteal': 'As you progress through the luteal phase, progesterone increases, which can soften your physical energy. Pacing your activities and ensuring high-quality rest helps prevent sudden fatigue.',
    'pre_menstrual': 'The pre-menstrual phase involves dropping hormone levels, which can impact mood stability. NHS guidance suggests reducing caffeine and salt intake to help manage pre-menstrual tension and physical bloating.',
    
    // Symptom-specific advice (Section 7.3)
    'cramps': 'For painful menstrual cramps (dysmenorrhoea), NHS clinical references advise applying a heat pad or warm water bottle to your abdomen, performing light stretching exercises, or taking over-the-counter pain relief like paracetamol or ibuprofen if appropriate.',
    'fatigue': 'Managing fatigue requires structure. Try to maintain a regular sleep schedule, get natural daylight exposure, and consume slow-release complex carbohydrates to support steady blood sugar levels.',
    'mood_swings': 'Fluctuating emotional stability is a common response to hormonal changes. Practising mindful breathing and taking quiet moments for yourself can help ground your emotional equilibrium.',
    'stress': 'Elevated stress levels can worsen physical symptoms. NHS clinical guidelines recommend relaxation techniques, regular physical activity, and setting boundaries to protect your mental energy.',
    'bloating': 'Bloating is linked to water retention. NHS advice suggests drinking plenty of water, eating smaller and more frequent meals, and engaging in light walking to stimulate digestion.',
    
    // Crisis Triage (Section 6.2)
    'crisis': 'I am concerned by the severity of the symptoms you are experiencing. In line with NHS clinical safety guidelines, if you are experiencing severe, sudden pain, or heavy bleeding that requires changing pads hourly, please contact NHS 111 or your general practitioner immediately. Do not delay seeking professional medical attention.'
  };

  /// Generates the advice based on active cycle data, metrics, and symptoms.
  static String generateDailyAdvice({DateTime? targetDate}) {
    final date = targetDate ?? DateTime.now();
    final cycleState = CycleEngine.getCurrentCycleState(targetDate: date);
    final metrics = TriMetricEngine.calculateMetricsForDate(date);
    
    final phase = cycleState['phase'].toString().toLowerCase();
    final List<String> symptoms = TriMetricEngine.getSymptomsForDate(date);
    
    // 1. Check for crisis parameters first
    bool hasCrisisSymptom = symptoms.any((s) =>
        s.toLowerCase().contains('severe') ||
        s.toLowerCase().contains('hemorrhage') ||
        s.toLowerCase().contains('bleeding') && s.toLowerCase().contains('heavy') ||
        s.toLowerCase().contains('emergency'));
        
    if (hasCrisisSymptom) {
      return _nhsGuidance['crisis']!;
    }
    
    // 2. Base advice on current phase
    String advice = '';
    if (phase.contains('menstruation')) {
      advice = _nhsGuidance['menstruation']!;
    } else if (phase.contains('follicular')) {
      advice = _nhsGuidance['follicular']!;
    } else if (phase.contains('ovulation')) {
      advice = _nhsGuidance['ovulation']!;
    } else if (phase.contains('luteal')) {
      advice = _nhsGuidance['luteal']!;
    } else {
      advice = _nhsGuidance['pre_menstrual']!;
    }
    
    // 3. Append advice for specific symptoms if present
    if (symptoms.isNotEmpty) {
      for (final symptom in symptoms) {
        final s = symptom.toLowerCase().trim();
        if ((s.contains('cramp') || s.contains('pain')) && _nhsGuidance.containsKey('cramps')) {
          advice += '\n\n${_nhsGuidance['cramps']!}';
        } else if ((s.contains('fatigue') || s.contains('tired') || s.contains('sleep')) && _nhsGuidance.containsKey('fatigue')) {
          advice += '\n\n${_nhsGuidance['fatigue']!}';
        } else if ((s.contains('mood') || s.contains('swing') || s.contains('irritable')) && _nhsGuidance.containsKey('mood_swings')) {
          advice += '\n\n${_nhsGuidance['mood_swings']!}';
        } else if ((s.contains('stress') || s.contains('anxious') || s.contains('worry')) && _nhsGuidance.containsKey('stress')) {
          advice += '\n\n${_nhsGuidance['stress']!}';
        } else if (s.contains('bloat') && _nhsGuidance.containsKey('bloating')) {
          advice += '\n\n${_nhsGuidance['bloating']!}';
        }
      }
    } else {
      // If no symptoms, check if any parent metric is Low and append guidance
      if (metrics['body'] < 45) {
        advice += '\n\nYour physical energy appears lower today. Focus on keeping hydrated, eating nourishing meals, and giving yourself permission to rest.';
      } else if (metrics['soul'] < 45) {
        advice += '\n\nIf you feel emotionally stretched, take a step back from busy social commitments. Protecting your boundary is a form of self-care.';
      } else if (metrics['mind'] < 45) {
        advice += '\n\nFocus can be elusive during hormonal shifts. Break your tasks into small steps, and do not expect perfection of yourself today.';
      }
    }
    
    return advice;
  }

  /// Generates detailed, wise aunt style advice focusing on the body, mind, and soul metrics.
  static String generateMetricsAdvice(int body, int mind, int soul) {
    final List<String> feedback = [];

    // Body advice
    if (body < 45) {
      feedback.add("Your Body score is low ($body%). Prioritise physical recovery: rest, stay hydrated, and stick to gentle movements like light walking. Keep meals nourishing and slow-release.");
    } else if (body <= 75) {
      feedback.add("Your Body score is moderate ($body%). Listen to your physical signals. Balanced activity mixed with scheduled recovery will help maintain your physical resilience.");
    } else {
      feedback.add("Your Body score is high ($body%). You have strong physical energy today! Capitalize on this with active workouts or projects, but stay mindful of hydration.");
    }

    // Mind advice
    if (mind < 45) {
      feedback.add("Your Mind score is low ($mind%). Focus and motivation may feel elusive. Break large tasks into small, manageable steps, and give yourself grace today.");
    } else if (mind <= 75) {
      feedback.add("Your Mind score is moderate ($mind%). Motivation is steady. Focus on deep-work windows while taking regular breaks to sustain your cognitive endurance.");
    } else {
      feedback.add("Your Mind score is high ($mind%). Your cognitive focus and motivation are peaking. This is a great window for complex problem solving and creative brainstorming.");
    }

    // Soul advice
    if (soul < 45) {
      feedback.add("Your Soul score is low ($soul%). Emotional stability or social bandwidth is tender. Take a step back from busy commitments. Protecting your boundaries is true self-care.");
    } else if (soul <= 75) {
      feedback.add("Your Soul score is moderate ($soul%). Your emotional equilibrium is stable. Spend time in warm, low-pressure social environments that recharge you.");
    } else {
      feedback.add("Your Soul score is high ($soul%). Your social energy and emotional outlook are bright and resilient. Share this positive energy with friends or family.");
    }

    return feedback.join("\n\n");
  }

  /// Dispatches a notification alert payload based on privacy configuration (Section 4.3).
  static Map<String, String> generateNotificationPayload() {
    final box = StorageService.settingsBox;
    final String privacyState = box.get('notification_privacy_state', defaultValue: 'State A') as String;
    
    if (privacyState == 'State B') {
      // State B: Discreet/Masked
      return {
        'title': 'Irma',
        'body': 'Irma has an update for you.',
      };
    } else {
      // State A: Conversational & Vague (Default)
      final cycleState = CycleEngine.getCurrentCycleState();
      final String phase = cycleState['phase'].toString();
      
      String body = 'I\'ve compiled today\'s wellness advice for you.';
      if (phase.contains('Menstruation')) {
        body = 'I\'ve updated your log. Let\'s make sure you\'re comfortable today.';
      } else if (phase.contains('Pre-menstrual')) {
        body = 'I have some reminders ready to help you prepare for the coming days.';
      }
      
      return {
        'title': 'Irma\'s Daily Note',
        'body': body,
      };
    }
  }

  /// Appends generated advice to historical log for display in Notifications Screen.
  static Future<void> saveDailyAdviceLog(String adviceText) async {
    final box = StorageService.settingsBox;
    final List<dynamic> logs = box.get('advice_logs', defaultValue: <dynamic>[]) as List<dynamic>;
    
    final newLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'content': adviceText,
    };
    
    logs.add(newLog);
    // Keep only last 30 logs to avoid excessive box growth
    if (logs.length > 30) {
      logs.removeAt(0);
    }
    await box.put('advice_logs', logs);
  }
}
