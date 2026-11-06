import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/enums/game_status.dart';

class GameControls extends StatelessWidget {
  final GameStatus status;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onRestart;

  const GameControls({
    super.key,
    required this.status,
    required this.onTogglePlayPause,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = status == GameStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          label: isPlaying
              ? 'PAUSE'
              : (status == GameStatus.paused ? 'RESUME' : 'START'),
          color: isPlaying
              ? GameConstants.warningColor
              : GameConstants.snakeHeadColor,
          onPressed: onTogglePlayPause,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.replay_rounded,
          label: 'NEW GAME',
          color: GameConstants.secondaryAccent,
          onPressed: onRestart,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
