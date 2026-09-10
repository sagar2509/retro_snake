import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RetroSnakeApp());
}

class RetroSnakeApp extends StatelessWidget {
  const RetroSnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F1A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9BBC0F),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
