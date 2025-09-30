import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cross_platform_airdrop/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('AirDrop Pro'), findsOneWidget);
  });
}
