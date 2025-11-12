// Basic Flutter widget test for tuPoint
//
// This test verifies the app launches successfully with the authentication screen.
// In production, this would include comprehensive UI tests for all screens and flows.

import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App launches with authentication screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TuPointApp());

    // Verify that the authentication screen is displayed
    expect(find.text('tuPoint'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);
    expect(find.text('Sign In with Apple'), findsOneWidget);
  });
}
