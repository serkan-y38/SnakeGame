import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/game_constants.dart';
import 'views/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameConstants.backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: GameConstants.snakeHeadColor,
          surface: GameConstants.surfaceColor,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const GameScreen(),
    );
  }
}
