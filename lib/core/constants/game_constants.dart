import 'package:flutter/material.dart';

class GameConstants {
  GameConstants._();

  static const int gridRows = 20;
  static const int gridColumns = 20;

  static const Duration initialSpeed = Duration(milliseconds: 170);
  static const Duration minSpeed = Duration(milliseconds: 80);
  static const int speedStepMilliseconds = 5;

  static const int pointsPerFood = 10;

  static const Color backgroundColor = Color(0xFF0A0E17);
  static const Color surfaceColor = Color(0xFF131D2E);
  static const Color boardBackgroundColor = Color(0xFF0D1424);
  static const Color boardBorderColor = Color(0xFF1E293B);
  static const Color gridCellColor = Color(0xFF162032);

  static const Color snakeHeadColor = Color(0xFF00FF88);
  static const Color snakeHeadEyeColor = Color(0xFF0A0E17);
  static const Color snakeBodyColor = Color(0xFF10B981);
  static const Color snakeBodyBorderColor = Color(0xFF059669);
  static const Color foodColor = Color(0xFFFF2A6D);
  static const Color foodGlowColor = Color(0x66FF2A6D);

  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color secondaryAccent = Color(0xFF00F0FF);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color textMutedColor = Color(0xFF94A3B8);
}
