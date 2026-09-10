import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/snake_game.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SnakeGame _game;
  Timer? _timer;
  Offset _dragTotal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame();
    _game.reset();
    _game.addListener(_onGameChanged);
    _loadHighScore();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _game.removeListener(_onGameChanged);
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _game.highScore = prefs.getInt('high_score') ?? 0;
    if (mounted) setState(() {});
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', _game.highScore);
  }

  void _onGameChanged() {
    if (!mounted) return;
    if (_game.status == GameStatus.playing) {
      _scheduleNextTick();
    } else {
      _timer?.cancel();
      if (_game.status == GameStatus.gameOver) {
        _saveHighScore();
      }
    }
    setState(() {});
  }

  // Re-scheduled after every tick (rather than a fixed Timer.periodic) so
  // the interval can shrink smoothly as the snake speeds up with score.
  void _scheduleNextTick() {
    _timer?.cancel();
    _timer = Timer(_game.tickDuration, () {
      _game.tick();
      if (_game.status == GameStatus.playing) {
        _scheduleNextTick();
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragTotal += details.delta;
    const threshold = 18.0;
    if (_dragTotal.dx.abs() > threshold || _dragTotal.dy.abs() > threshold) {
      if (_dragTotal.dx.abs() > _dragTotal.dy.abs()) {
        _game.changeDirection(
            _dragTotal.dx > 0 ? Direction.right : Direction.left);
      } else {
        _game.changeDirection(
            _dragTotal.dy > 0 ? Direction.down : Direction.up);
      }
      _dragTotal = Offset.zero;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragTotal = Offset.zero;
  }

  void _handleTap() {
    if (_game.status == GameStatus.ready || _game.status == GameStatus.gameOver) {
      _game.start();
    } else if (_game.status == GameStatus.paused) {
      _game.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildScoreBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                  onTap: _handleTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GameBoard(game: _game),
                      if (_game.status != GameStatus.playing) _buildOverlay(),
                    ],
                  ),
                ),
              ),
            ),
            _buildDPad(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF9BBC0F)),
          ),
          Text(
            'SCORE ${_game.score}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF9BBC0F),
              letterSpacing: 2,
            ),
          ),
          Text(
            'HI ${_game.highScore}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF9BBC0F),
              letterSpacing: 2,
            ),
          ),
          IconButton(
            onPressed: () {
              if (_game.status == GameStatus.playing) {
                _game.pause();
              } else if (_game.status == GameStatus.paused) {
                _game.resume();
              }
            },
            icon: Icon(
              _game.status == GameStatus.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              color: const Color(0xFF9BBC0F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    String title;
    String subtitle;
    switch (_game.status) {
      case GameStatus.ready:
        title = 'READY?';
        subtitle = 'TAP TO START';
        break;
      case GameStatus.paused:
        title = 'PAUSED';
        subtitle = 'TAP TO RESUME';
        break;
      case GameStatus.gameOver:
        title = 'GAME OVER';
        subtitle = 'SCORE ${_game.score} \u2022 TAP TO RETRY';
        break;
      case GameStatus.playing:
        title = '';
        subtitle = '';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A0F).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9BBC0F), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 4,
              color: Color(0xFF9BBC0F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDPad() {
    return SizedBox(
      height: 170,
      width: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: 0, child: _dpadButton(Icons.keyboard_arrow_up, Direction.up)),
          Positioned(
              bottom: 0,
              child: _dpadButton(Icons.keyboard_arrow_down, Direction.down)),
          Positioned(
              left: 0,
              child: _dpadButton(Icons.keyboard_arrow_left, Direction.left)),
          Positioned(
              right: 0,
              child:
                  _dpadButton(Icons.keyboard_arrow_right, Direction.right)),
        ],
      ),
    );
  }

  Widget _dpadButton(IconData icon, Direction direction) {
    return Material(
      color: const Color(0xFF1B2E1B),
      shape: const CircleBorder(side: BorderSide(color: Color(0xFF9BBC0F), width: 2)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _game.changeDirection(direction),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: const Color(0xFF9BBC0F), size: 30),
        ),
      ),
    );
  }
}
