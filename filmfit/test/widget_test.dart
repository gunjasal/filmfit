// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filmfit/main.dart';

void main() {
  testWidgets('FilmFit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the input view is displayed.
    expect(find.text('FilmFit - 사각형 입력'), findsOneWidget);
    expect(find.text('사각형 회전 허용안함'), findsOneWidget);
    expect(find.text('배치'), findsOneWidget);

    // Verify that there's at least one rectangle input.
    expect(find.text('가로(mm)'), findsAtLeastNWidgets(1));
    expect(find.text('세로(mm)'), findsAtLeastNWidgets(1));
    expect(find.text('갯수'), findsAtLeastNWidgets(1));
  });
}
