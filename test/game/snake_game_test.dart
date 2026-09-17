import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/game/snake_game.dart';

void main() {
  group('SnakeGame.reset', () {
    test('initializes snake, direction, score and status', () {
      final game = SnakeGame(columns: 17, rows: 27);
      game.reset();

      expect(game.snake, [
        const Point(7, 13),
        const Point(6, 13),
        const Point(5, 13),
      ]);
      expect(game.direction, Direction.right);
      expect(game.score, 0);
      expect(game.status, GameStatus.ready);
      expect(game.snake.contains(game.food), isFalse);
    });

    test('places food outside a near-full board without infinite looping',
        () {
      final game = SnakeGame(columns: 3, rows: 1);
      for (var i = 0; i < 30; i++) {
        game.reset();
        expect(game.snake.contains(game.food), isFalse);
      }
    });
  });

  group('SnakeGame.start', () {
    test('moves ready game straight to playing', () {
      final game = SnakeGame()..reset();
      game.start();
      expect(game.status, GameStatus.playing);
    });

    test('resets a game-over game before playing again', () {
      final game = SnakeGame()..reset();
      game.start();
      // Force a collision so the game ends.
      game.snake = [const Point(0, 0), const Point(1, 0), const Point(2, 0)];
      game.direction = Direction.left;
      game.changeDirection(Direction.left);
      game.tick();
      expect(game.status, GameStatus.gameOver);

      game.start();
      expect(game.status, GameStatus.playing);
      expect(game.score, 0);
    });

    test('resets when snake is empty', () {
      final game = SnakeGame();
      expect(game.snake, isEmpty);
      game.start();
      expect(game.status, GameStatus.playing);
      expect(game.snake, isNotEmpty);
    });
  });

  group('SnakeGame.pause/resume', () {
    test('pause only takes effect while playing', () {
      final game = SnakeGame()..reset();
      game.pause();
      expect(game.status, GameStatus.ready);

      game.start();
      game.pause();
      expect(game.status, GameStatus.paused);
    });

    test('resume only takes effect while paused', () {
      final game = SnakeGame()..reset();
      game.resume();
      expect(game.status, GameStatus.ready);

      game.start();
      game.pause();
      game.resume();
      expect(game.status, GameStatus.playing);
    });
  });

  group('SnakeGame.changeDirection', () {
    test('ignores a 180-degree reversal', () {
      final game = SnakeGame()..reset();
      expect(game.direction, Direction.right);
      game.changeDirection(Direction.left);
      game.start();
      game.tick();
      // Still moved right, reversal request was dropped.
      expect(game.snake.first, const Point(8, 13));
    });

    test('accepts a valid turn', () {
      final game = SnakeGame()..reset();
      game.changeDirection(Direction.up);
      game.start();
      game.tick();
      expect(game.snake.first, const Point(7, 12));
      expect(game.direction, Direction.up);
    });

    test('all opposite pairs are rejected', () {
      final game = SnakeGame()..reset();
      game.direction = Direction.up;
      game.changeDirection(Direction.down);
      expect(game.direction, Direction.up);

      game.direction = Direction.down;
      game.changeDirection(Direction.up);
      expect(game.direction, Direction.down);

      game.direction = Direction.right;
      game.changeDirection(Direction.left);
      expect(game.direction, Direction.right);
    });
  });

  group('SnakeGame.tick', () {
    test('does nothing when not playing', () {
      final game = SnakeGame()..reset();
      final before = List.of(game.snake);
      game.tick();
      expect(game.snake, before);
      expect(game.status, GameStatus.ready);
    });

    test('moves the snake one cell in each direction', () {
      final game = SnakeGame(columns: 20, rows: 20);
      game.snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
      game.food = const Point(19, 19);
      game.status = GameStatus.playing;

      game.direction = Direction.right;
      game.changeDirection(Direction.right);
      game.tick();
      expect(game.snake.first, const Point(11, 10));

      game.direction = Direction.down;
      game.changeDirection(Direction.down);
      game.tick();
      expect(game.snake.first, const Point(11, 11));

      game.direction = Direction.left;
      game.changeDirection(Direction.left);
      game.tick();
      expect(game.snake.first, const Point(10, 11));

      game.direction = Direction.up;
      game.changeDirection(Direction.up);
      game.tick();
      expect(game.snake.first, const Point(10, 10));
    });

    test('keeps the same length when no food is eaten', () {
      final game = SnakeGame(columns: 20, rows: 20);
      game.snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
      game.food = const Point(19, 19);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.snake.length, 3);
    });

    test('grows and raises score/highScore when eating food', () {
      final game = SnakeGame(columns: 20, rows: 20);
      game.snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
      game.food = const Point(11, 10);
      game.status = GameStatus.playing;
      game.highScore = 0;

      game.tick();

      expect(game.snake.length, 4);
      expect(game.score, 1);
      expect(game.highScore, 1);
      expect(game.snake.contains(game.food), isFalse);
    });

    test('does not lower highScore when it is already higher', () {
      final game = SnakeGame(columns: 20, rows: 20);
      game.snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
      game.food = const Point(11, 10);
      game.status = GameStatus.playing;
      game.highScore = 5;

      game.tick();

      expect(game.score, 1);
      expect(game.highScore, 5);
    });

    test('ends the game when hitting the right wall', () {
      final game = SnakeGame(columns: 5, rows: 5);
      game.snake = [const Point(4, 2), const Point(3, 2)];
      game.direction = Direction.right;
      game.changeDirection(Direction.right);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.status, GameStatus.gameOver);
    });

    test('ends the game when hitting the left wall', () {
      final game = SnakeGame(columns: 5, rows: 5);
      game.snake = [const Point(0, 2), const Point(1, 2)];
      game.direction = Direction.left;
      game.changeDirection(Direction.left);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.status, GameStatus.gameOver);
    });

    test('ends the game when hitting the top wall', () {
      final game = SnakeGame(columns: 5, rows: 5);
      game.snake = [const Point(2, 0), const Point(2, 1)];
      game.direction = Direction.up;
      game.changeDirection(Direction.up);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.status, GameStatus.gameOver);
    });

    test('ends the game when hitting the bottom wall', () {
      final game = SnakeGame(columns: 5, rows: 5);
      game.snake = [const Point(2, 4), const Point(2, 3)];
      game.direction = Direction.down;
      game.changeDirection(Direction.down);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.status, GameStatus.gameOver);
    });

    test('ends the game when the snake bites itself', () {
      final game = SnakeGame(columns: 10, rows: 10);
      // A U-turn shape where moving up runs the head into the body.
      game.snake = [
        const Point(5, 5),
        const Point(4, 5),
        const Point(4, 4),
        const Point(5, 4),
        const Point(5, 5 + 1),
      ];
      game.direction = Direction.up;
      game.changeDirection(Direction.up);
      game.status = GameStatus.playing;

      game.tick();
      expect(game.status, GameStatus.gameOver);
    });

    test('records highScore when the game ends', () {
      final game = SnakeGame(columns: 5, rows: 5);
      game.snake = [const Point(4, 2), const Point(3, 2)];
      game.direction = Direction.right;
      game.changeDirection(Direction.right);
      game.status = GameStatus.playing;
      game.score = 7;
      game.highScore = 3;

      game.tick();

      expect(game.status, GameStatus.gameOver);
      expect(game.highScore, 7);
    });
  });

  group('SnakeGame.tickDuration', () {
    test('starts at the base speed', () {
      final game = SnakeGame()..score = 0;
      expect(game.tickDuration, const Duration(milliseconds: 220));
    });

    test('speeds up as score increases', () {
      final game = SnakeGame()..score = 15;
      expect(game.tickDuration, const Duration(milliseconds: 178));
    });

    test('floors out at the fastest pace for very high scores', () {
      final game = SnakeGame()..score = 1000;
      expect(game.tickDuration, const Duration(milliseconds: 80));
    });
  });

  test('notifies listeners on reset, start, pause, resume and tick', () {
    final game = SnakeGame(columns: 20, rows: 20);
    var notifications = 0;
    game.addListener(() => notifications++);

    game.reset();
    expect(notifications, 1);

    game.start();
    expect(notifications, 2);

    game.pause();
    expect(notifications, 3);

    game.resume();
    expect(notifications, 4);

    game.tick();
    expect(notifications, 5);
  });
}
