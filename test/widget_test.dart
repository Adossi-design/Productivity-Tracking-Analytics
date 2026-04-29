import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_tracking_analytics/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductivityTrackingApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
