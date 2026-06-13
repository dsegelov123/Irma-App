import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:irma/views/loading_view.dart';

void main() {
  testWidgets('App boot loading screen smoke test', (WidgetTester tester) async {
    // Build LoadingView directly.
    await tester.pumpWidget(
      MaterialApp(
        home: LoadingView(onNavigation: (_) {}),
      ),
    );

    // Verify that the Loading view renders the IRMA title.
    expect(find.text('IRMA'), findsOneWidget);
  });
}
