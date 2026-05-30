import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_tracking_analytics/screens/splash_screen.dart';

void main() {
  // The full app boots Firebase + providers, which can't run under flutter_test
  // without mocks. We smoke-test a self-contained screen instead so the suite
  // actually compiles and passes (the previous test threw ProviderNotFound).
  testWidgets('SplashScreen renders its branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Time Tracker'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
