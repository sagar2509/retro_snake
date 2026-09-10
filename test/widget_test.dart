// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Retro Snake app smoke test', (WidgetTester tester) async {
    // Provide initial mock values for SharedPreferences.
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const RetroSnakeApp());

    // Verify that the game title 'SNAKE' is present.
    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('RETRO EDITION'), findsOneWidget);

    // Verify that the 'PLAY' button is present.
    expect(find.text('PLAY'), findsOneWidget);
  });
}
