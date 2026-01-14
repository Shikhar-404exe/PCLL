// PCLL App Widget Tests
//
// Basic smoke tests for the Personal Cognitive Load Ledger application.

import 'package:flutter_test/flutter_test.dart';

import 'package:pcll_app/main.dart';

void main() {
  testWidgets('PCLLApp smoke test - app launches', (WidgetTester tester) async {
    // Build the PCLL app and trigger a frame.
    await tester.pumpWidget(const PCLLApp());

    // Allow time for async initialization
    await tester.pumpAndSettle();

    // Verify the app renders without crashing
    // The app should show either the disclaimer, login, or main screen
    expect(find.byType(PCLLApp), findsOneWidget);
  });
}
