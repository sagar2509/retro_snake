import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9BBC0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0F1A0F), width: 6),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SNAKE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 48,
                          letterSpacing: 8,
                          color: Color(0xFF0F1A0F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'RETRO EDITION',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 4,
                          color: Color(0xFF0F1A0F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'HI-SCORE: $_highScore',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0F1A0F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                    _loadHighScore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9BBC0F),
                    foregroundColor: const Color(0xFF0F1A0F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Color(0xFF0F1A0F), width: 3),
                    ),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SWIPE OR USE THE D-PAD TO MOVE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white54,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
