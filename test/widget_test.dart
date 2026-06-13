import 'package:flutter_test/flutter_test.dart';
import 'package:irma/main.dart';

void main() {
  testWidgets('App boot loading screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Loading view renders the IRMA title.
    expect(find.text('IRMA'), findsOneWidget);
  });
}
