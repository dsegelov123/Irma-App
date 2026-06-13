// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/services/advice_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '.';
  @override
  Future<String?> getApplicationSupportPath() async => '.';
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    
    // Mock FlutterSecureStorage method channel
    final Map<String, String> secureStorageMock = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          final key = methodCall.arguments['key'] as String;
          return secureStorageMock[key];
        }
        if (methodCall.method == 'write') {
          final key = methodCall.arguments['key'] as String;
          final value = methodCall.arguments['value'] as String;
          secureStorageMock[key] = value;
          return null;
        }
        if (methodCall.method == 'deleteAll') {
          secureStorageMock.clear();
          return null;
        }
        return null;
      },
    );

    await StorageService.init();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  setUp(() async {
    await StorageService.settingsBox.clear();
  });

  group('CycleEngine Calculations', () {
    test('Default onboarding settings return expected baseline averages', () {
      final box = StorageService.settingsBox;
      box.put('average_cycle_length', 28);
      box.put('average_period_duration', 5);
      
      expect(CycleEngine.getAverageCycleLength(), 28.0);
    });

    test('Phase mapping maps cycle days to correct physiological states', () {
      expect(CycleEngine.getPhaseForDay(3, 28, 5), 'Menstruation');
      expect(CycleEngine.getPhaseForDay(8, 28, 5), 'Follicular Phase');
      expect(CycleEngine.getPhaseForDay(14, 28, 5), 'Ovulation');
      expect(CycleEngine.getPhaseForDay(18, 28, 5), 'Luteal Phase');
      expect(CycleEngine.getPhaseForDay(25, 28, 5), 'Pre-menstrual Phase');
    });

    test('Early Period logging inserts new anchor and resets active cycle to Day 1', () async {
      final box = StorageService.settingsBox;
      await box.put('average_cycle_length', 28);
      await box.put('average_period_duration', 5);
      
      final initialOnset = DateTime.now().subtract(const Duration(days: 14));
      await box.put('last_period_start_date', initialOnset.toIso8601String());
      
      final today = DateTime.now();
      await CycleEngine.logPeriodStart(today);
      
      expect(CycleEngine.getCycleDay(targetDate: today), 1);
      
      final starts = CycleEngine.getCycleStarts();
      expect(starts.last.day, today.day);
    });

    test('Outlier detection correctly filters abnormal cycle lengths', () {
      expect(CycleEngine.isCycleOutlier(28, 28.0), false);
      expect(CycleEngine.isCycleOutlier(27, 28.0), false);
      
      expect(CycleEngine.isCycleOutlier(15, 28.0), true);
      expect(CycleEngine.isCycleOutlier(48, 28.0), true);
      expect(CycleEngine.isCycleOutlier(37, 28.0), true);
    });
  });

  group('Tri-Metric calculations & sub-metrics', () {
    test('Calculates Body, Mind, Soul scores and matches tiers', () {
      final box = StorageService.settingsBox;
      box.put('average_cycle_length', 28);
      box.put('average_period_duration', 5);
      
      final today = DateTime.now();
      final metrics = TriMetricEngine.calculateMetricsForDate(today);
      
      expect(metrics.containsKey('body'), true);
      expect(metrics.containsKey('mind'), true);
      expect(metrics.containsKey('soul'), true);
      expect(metrics['body'] >= 0 && metrics['body'] <= 100, true);
    });

    test('Adjusts scores downwards when symptoms like cramps or fatigue are logged', () {
      final box = StorageService.settingsBox;
      box.put('average_cycle_length', 28);
      box.put('average_period_duration', 5);
      
      final todayStr = 'log_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      
      final baseline = TriMetricEngine.calculateMetricsForDate(DateTime.now());
      
      box.put(todayStr, {
        'symptoms': ['cramps', 'fatigue'],
        'notes': 'test'
      });
      
      final adjusted = TriMetricEngine.calculateMetricsForDate(DateTime.now());
      
      expect(adjusted['body'] < baseline['body'], true);
    });
  });

  group('Advice Service Character & Dialects', () {
    test('Ensures UK-English spelling and wise aunt persona in advice snippets', () {
      final advice = AdviceService.generateDailyAdvice();
      
      expect(advice.contains('oestrogen') || advice.contains('prioritise') || advice.contains('programme') || advice.contains('dysmenorrhoea') || advice.contains('equilibrium'), true);
      expect(advice.contains('dear') || advice.contains('love') || advice.contains('poor little thing'), false);
    });

    test('Crisis trigger replaces normal advice with NHS referral recommendations', () {
      final box = StorageService.settingsBox;
      final todayStr = 'log_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      
      box.put(todayStr, {
        'symptoms': ['severe pain', 'heavy bleeding'],
        'notes': 'emergency'
      });
      
      final advice = AdviceService.generateDailyAdvice();
      expect(advice.contains('NHS 111') || advice.contains('emergency services'), true);
    });
  });
}
