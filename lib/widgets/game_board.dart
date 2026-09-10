import 'package:flutter/material.dart';
import '../game/snake_game.dart';

/// Renders the Nokia-3310-style LCD screen: a yellow-green background,
/// a faint pixel grid, and blocky dark squares for the snake and food.
class GameBoard extends StatelessWidget {
  const GameBoard({super.key, required this.game});

  final SnakeGame game;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: game.columns / game.rows,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9BBC0F),
          border: Border.all(color: const Color(0xFF0F1A0F), width: 6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _BoardPainter(game: game),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.game});

  final SnakeGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / game.columns;
    final cellHeight = size.height / game.rows;

    final gridPaint = Paint()..color = const Color(0xFF8BAC0F);
    for (int x = 0; x < game.columns; x++) {
      for (int y = 0; y < game.rows; y++) {
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect.deflate(0.4), gridPaint);
      }
    }

    final snakePaint = Paint()..color = const Color(0xFF0F1A0F);
    for (final segment in game.snake) {
      final rect = Rect.fromLTWH(
        segment.x * cellWidth,
        segment.y * cellHeight,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(rect.deflate(1.2), snakePaint);
    }

    final foodPaint = Paint()..color = const Color(0xFF0F1A0F);
    final foodRect = Rect.fromLTWH(
      game.food.x * cellWidth,
      game.food.y * cellHeight,
      cellWidth,
      cellHeight,
    );
    canvas.drawRect(foodRect.deflate(2.5), foodPaint);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}
