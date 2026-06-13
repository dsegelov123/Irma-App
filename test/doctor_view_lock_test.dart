// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/views/doctor_view.dart';
import 'package:google_fonts/google_fonts.dart';
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

  bool mockAuthResult = false;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
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
        return null;
      },
    );

    // Mock local_auth method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isDeviceSupported') return true;
        if (methodCall.method == 'deviceCanSupportBiometrics') return true;
        if (methodCall.method == 'getAvailableBiometrics') return ['fingerprint'];
        if (methodCall.method == 'authenticate') return mockAuthResult;
        return null;
      },
    );

    await StorageService.init();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('DoctorView intercepts back button and demands authentication', (WidgetTester tester) async {
    // Build DoctorView within a test environment with a parent navigator
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DoctorView()),
                  );
                  popped = true;
                },
                child: const Text('Go to Doctor View'),
              );
            },
          ),
        ),
      ),
    );

    // Push the DoctorView screen
    await tester.tap(find.text('Go to Doctor View'));
    await tester.pumpAndSettle();

    // Verify DoctorView is rendered
    expect(find.text('Doctor Consultation Mode'), findsOneWidget);

    // 1. Test Biometric Failure (should block back navigation)
    mockAuthResult = false;
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // The screen should still be visible because pop failed authentication
    expect(find.text('Doctor Consultation Mode'), findsOneWidget);
    expect(popped, false);

    // 2. Test Biometric Success (should allow back navigation)
    mockAuthResult = true;
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // The screen should now be popped and gone
    expect(find.text('Doctor Consultation Mode'), findsNothing);
    expect(popped, true);
  });
}
