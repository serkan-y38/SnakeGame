import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/snake_game_controller.dart';
import '../core/constants/game_constants.dart';
import '../core/enums/direction.dart';
import 'widgets/game_board.dart';
import 'widgets/game_controls.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SnakeGameController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isGameOverDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = SnakeGameController();
    _controller.addListener(_handleGameStateChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _handleGameStateChange() {
    if (!mounted) return;

    if (_controller.isGameOver && !_isGameOverDialogShowing) {
      _isGameOverDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameOverDialog(
          score: _controller.score,
          highScore: _controller.highScore,
          onRestart: () {
            _controller.restartGame();
            _focusNode.requestFocus();
          },
        ),
      ).then((_) {
        _isGameOverDialogShowing = false;
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      _controller.changeDirection(Direction.up);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS) {
      _controller.changeDirection(Direction.down);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA) {
      _controller.changeDirection(Direction.left);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _controller.changeDirection(Direction.right);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space) {
      _controller.togglePause();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleGameStateChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          backgroundColor: GameConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: GameConstants.backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GameConstants.snakeHeadColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: GameConstants.snakeHeadColor,
                size: 24,
              ),
            ),
          ),
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth > 460
                        ? 460
                        : constraints.maxWidth;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScoreBoard(
                              score: _controller.score,
                              highScore: _controller.highScore,
                              status: _controller.status,
                            ),
                            const SizedBox(height: 16),

                            GameBoard(
                              snake: _controller.snake,
                              food: _controller.food,
                              currentDirection: _controller.currentDirection,
                              status: _controller.status,
                              onTap: () {
                                if (_controller.isInitial ||
                                    _controller.isPaused) {
                                  _controller.togglePause();
                                }
                                _focusNode.requestFocus();
                              },
                              onDirectionChanged: (dir) {
                                _controller.changeDirection(dir);
                                _focusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 20),

                            GameControls(
                              status: _controller.status,
                              onTogglePlayPause: () {
                                _controller.togglePause();
                                _focusNode.requestFocus();
                              },
                              onRestart: () {
                                _controller.restartGame();
                                _focusNode.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
