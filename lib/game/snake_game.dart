import 'dart:math';
import 'package:flutter/foundation.dart';

enum Direction { up, down, left, right }

enum GameStatus { ready, playing, paused, gameOver }

/// Holds all Snake game state and rules. Pure logic, no Flutter UI code,
/// so it's easy to unit test independently of widgets.
class SnakeGame extends ChangeNotifier {
  SnakeGame({this.columns = 17, this.rows = 27});

  final int columns;
  final int rows;

  List<Point<int>> snake = [];
  Point<int> food = const Point(0, 0);
  Direction direction = Direction.right;
  Direction _queuedDirection = Direction.right;
  GameStatus status = GameStatus.ready;
  int score = 0;
  int highScore = 0;

  final Random _random = Random();

  /// How long to wait before the next move. Speeds up as the score grows,
  /// floors out at a fast-but-playable pace, just like the old phone game.
  Duration get tickDuration {
    int speedLevel = score ~/ 5;
    if (speedLevel > 10) speedLevel = 10;
    int ms = 220 - speedLevel * 14;
    if (ms < 80) ms = 80;
    return Duration(milliseconds: ms);
  }

  void reset() {
    final startX = columns ~/ 2;
    final startY = rows ~/ 2;
    snake = [
      Point(startX - 1, startY),
      Point(startX - 2, startY),
      Point(startX - 3, startY),
    ];
    direction = Direction.right;
    _queuedDirection = Direction.right;
    score = 0;
    status = GameStatus.ready;
    _placeFood();
    notifyListeners();
  }

  void start() {
    if (status == GameStatus.gameOver || snake.isEmpty) {
      reset();
    }
    status = GameStatus.playing;
    notifyListeners();
  }

  void pause() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
      notifyListeners();
    }
  }

  void resume() {
    if (status == GameStatus.paused) {
      status = GameStatus.playing;
      notifyListeners();
    }
  }

  /// Queues a direction change. Ignored if it's a 180-degree reversal,
  /// since that would mean instantly running into your own neck.
  void changeDirection(Direction newDirection) {
    if (_isOpposite(newDirection, direction)) return;
    _queuedDirection = newDirection;
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.up && b == Direction.down) ||
        (a == Direction.down && b == Direction.up) ||
        (a == Direction.left && b == Direction.right) ||
        (a == Direction.right && b == Direction.left);
  }

  /// Advances the game by one grid step. Called on a timer from the UI.
  void tick() {
    if (status != GameStatus.playing) return;

    direction = _queuedDirection;
    final head = snake.first;
    Point<int> newHead;
    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    final hitWall =
        newHead.x < 0 || newHead.x >= columns || newHead.y < 0 || newHead.y >= rows;
    if (hitWall || snake.contains(newHead)) {
      _gameOver();
      return;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      score += 1;
      if (score > highScore) highScore = score;
      _placeFood();
    } else {
      snake.removeLast();
    }

    notifyListeners();
  }

  void _gameOver() {
    status = GameStatus.gameOver;
    if (score > highScore) highScore = score;
    notifyListeners();
  }

  void _placeFood() {
    Point<int> candidate;
    do {
      candidate = Point(_random.nextInt(columns), _random.nextInt(rows));
    } while (snake.contains(candidate));
    food = candidate;
  }
}
