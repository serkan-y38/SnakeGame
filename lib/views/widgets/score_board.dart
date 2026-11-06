import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/enums/game_status.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int highScore;
  final GameStatus status;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.highScore,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: GameConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameConstants.boardBorderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreItem(
            icon: Icons.bolt_rounded,
            iconColor: GameConstants.snakeHeadColor,
            label: 'SCORE',
            value: score.toString(),
          ),

          _buildScoreItem(
            icon: Icons.emoji_events_rounded,
            iconColor: GameConstants.warningColor,
            label: 'HIGH SCORE',
            value: highScore.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: GameConstants.textMutedColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: GameConstants.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
