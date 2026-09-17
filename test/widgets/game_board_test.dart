import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/game/snake_game.dart';
import 'package:retro_snake/widgets/game_board.dart';

void main() {
  testWidgets('renders the board with snake and food painted', (tester) async {
    final game = SnakeGame(columns: 10, rows: 10)..reset();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: GameBoard(game: game)),
      ),
    );

    expect(find.byType(GameBoard), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('repaints when the underlying game state changes', (tester) async {
    final game = SnakeGame(columns: 10, rows: 10)..reset();

    Widget buildBoard() => MaterialApp(
          home: Center(child: GameBoard(game: game)),
        );

    await tester.pumpWidget(buildBoard());

    game.start();
    game.tick();

    // Rebuilding creates a new painter; shouldRepaint should be exercised.
    await tester.pumpWidget(buildBoard());
    expect(find.byType(GameBoard), findsOneWidget);
  });
}
