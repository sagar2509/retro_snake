import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/screens/game_screen.dart';
import 'package:retro_snake/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  testWidgets('shows title, default high score and play button', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('RETRO EDITION'), findsOneWidget);
    expect(find.text('HI-SCORE: 0'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.textContaining('SWIPE OR USE THE D-PAD'), findsOneWidget);
  });

  testWidgets('loads a stored high score asynchronously', (tester) async {
    SharedPreferences.setMockInitialValues({'high_score': 42});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('HI-SCORE: 42'), findsOneWidget);
  });

  testWidgets('tapping PLAY opens the game screen and reloads high score on return',
      (tester) async {
    SharedPreferences.setMockInitialValues({'high_score': 5});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('HI-SCORE: 5'), findsOneWidget);
  });
}
