import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/game/snake_game.dart';
import 'package:retro_snake/screens/game_screen.dart';
import 'package:retro_snake/widgets/game_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<MethodCall> hapticCalls;

  setUp(() {
    hapticCalls = [];
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      hapticCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  final gameBoardFinder = find.byType(GameBoard);
  SnakeGame liveGame(WidgetTester tester) =>
      tester.widget<GameBoard>(gameBoardFinder).game;

  Future<void> pumpGame(WidgetTester tester, {Map<String, Object>? prefs}) async {
    SharedPreferences.setMockInitialValues(prefs ?? {});
    await tester.pumpWidget(const MaterialApp(home: GameScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the ready overlay and starts playing on tap', (tester) async {
    await pumpGame(tester);

    expect(find.text('READY?'), findsOneWidget);
    expect(find.text('TAP TO START'), findsOneWidget);
    expect(find.text('SCORE 0'), findsOneWidget);
    expect(find.text('HI 0'), findsOneWidget);

    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    expect(find.text('READY?'), findsNothing);
    expect(liveGame(tester).status, GameStatus.playing);
  });

  testWidgets('swipe gestures steer the snake in all four directions', (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    Future<void> swipeAndCommit(Offset offset, Direction expected) async {
      await tester.drag(gameBoardFinder, offset);
      await tester.pump(liveGame(tester).tickDuration);
      expect(liveGame(tester).direction, expected);
    }

    await swipeAndCommit(const Offset(0, 40), Direction.down);
    await swipeAndCommit(const Offset(40, 0), Direction.right);
    await swipeAndCommit(const Offset(0, -40), Direction.up);
    await swipeAndCommit(const Offset(-40, 0), Direction.left);
  });

  testWidgets('a small drag below the threshold is ignored', (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    final directionBefore = liveGame(tester).direction;
    await tester.drag(gameBoardFinder, const Offset(4, 0));
    await tester.pump(liveGame(tester).tickDuration);

    expect(liveGame(tester).direction, directionBefore);
  });

  testWidgets('d-pad buttons steer the snake', (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    Future<void> tapAndCommit(IconData icon, Direction expected) async {
      await tester.tap(find.byIcon(icon));
      await tester.pump(liveGame(tester).tickDuration);
      expect(liveGame(tester).direction, expected);
    }

    await tapAndCommit(Icons.keyboard_arrow_down, Direction.down);
    await tapAndCommit(Icons.keyboard_arrow_right, Direction.right);
    await tapAndCommit(Icons.keyboard_arrow_up, Direction.up);
    await tapAndCommit(Icons.keyboard_arrow_left, Direction.left);
  });

  testWidgets('pause/resume works from the icon button and from tapping the board',
      (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(liveGame(tester).status, GameStatus.paused);
    expect(find.text('PAUSED'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(liveGame(tester).status, GameStatus.playing);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();
    expect(liveGame(tester).status, GameStatus.playing);
  });

  testWidgets('eating food raises the score and triggers a medium haptic pulse',
      (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    final game = liveGame(tester);
    final head = game.snake.first;
    game.food = Point(head.x + 1, head.y); // directly ahead, direction is right

    await tester.pump(game.tickDuration);

    expect(game.score, 1);
    expect(
      hapticCalls.map((c) => c.arguments),
      contains('HapticFeedbackType.mediumImpact'),
    );
  });

  testWidgets('hitting a wall ends the game, vibrates and persists the high score',
      (tester) async {
    await pumpGame(tester, prefs: {'high_score': 0});
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    final game = liveGame(tester);
    game.snake = [Point(game.columns - 1, 5), Point(game.columns - 2, 5)];
    game.changeDirection(Direction.right);

    await tester.pump(game.tickDuration);
    await tester.pumpAndSettle();

    expect(game.status, GameStatus.gameOver);
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(
      hapticCalls.map((c) => c.arguments),
      contains('HapticFeedbackType.heavyImpact'),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('high_score'), game.highScore);
  });

  testWidgets('tapping after game over retries with a fresh score', (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    final game = liveGame(tester);
    game.snake = [Point(game.columns - 1, 5), Point(game.columns - 2, 5)];
    game.changeDirection(Direction.right);
    await tester.pump(game.tickDuration);
    await tester.pumpAndSettle();
    expect(game.status, GameStatus.gameOver);

    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    expect(liveGame(tester).status, GameStatus.playing);
    expect(find.text('SCORE 0'), findsOneWidget);
  });

  testWidgets('disposing while the game is playing cancels the timer cleanly',
      (tester) async {
    await pumpGame(tester);
    await tester.tap(gameBoardFinder, warnIfMissed: false);
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
  });
}
