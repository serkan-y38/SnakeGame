import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/enums/direction.dart';
import '../../core/enums/game_status.dart';
import '../../models/position.dart';

class GameBoard extends StatefulWidget {
  final List<Position> snake;
  final Position food;
  final Direction currentDirection;
  final GameStatus status;
  final ValueChanged<Direction> onDirectionChanged;
  final VoidCallback? onTap;

  const GameBoard({
    super.key,
    required this.snake,
    required this.food,
    required this.currentDirection,
    required this.status,
    required this.onDirectionChanged,
    this.onTap,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  double _panDx = 0;
  double _panDy = 0;
  static const double _swipeSensitivity = 20.0;

  void _handlePanStart(DragStartDetails details) {
    _panDx = 0;
    _panDy = 0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _panDx += details.delta.dx;
    _panDy += details.delta.dy;

    if (_panDx.abs() > _swipeSensitivity || _panDy.abs() > _swipeSensitivity) {
      if (_panDx.abs() > _panDy.abs()) {
        widget.onDirectionChanged(
          _panDx > 0 ? Direction.right : Direction.left,
        );
      } else {
        widget.onDirectionChanged(_panDy > 0 ? Direction.down : Direction.up);
      }
      _panDx = 0;
      _panDy = 0;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > 100 || velocity.dy.abs() > 100) {
      if (velocity.dx.abs() > velocity.dy.abs()) {
        widget.onDirectionChanged(
          velocity.dx > 0 ? Direction.right : Direction.left,
        );
      } else {
        widget.onDirectionChanged(
          velocity.dy > 0 ? Direction.down : Direction.up,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Container(
          decoration: BoxDecoration(
            color: GameConstants.boardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GameConstants.boardBorderColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: GameConstants.primaryAccent.withValues(alpha: 0.05),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _BoardPainter(
                  snake: widget.snake,
                  food: widget.food,
                  currentDirection: widget.currentDirection,
                ),
              ),

              if (widget.status == GameStatus.initial)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: GameConstants.surfaceColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: GameConstants.snakeHeadColor.withValues(
                          alpha: 0.6,
                        ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GameConstants.snakeHeadColor.withValues(
                            alpha: 0.15,
                          ),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swipe_rounded,
                          color: GameConstants.snakeHeadColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'SWIPE TO START',
                          style: TextStyle(
                            color: GameConstants.snakeHeadColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (widget.status == GameStatus.paused)
                Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: GameConstants.surfaceColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: GameConstants.warningColor.withValues(
                          alpha: 0.6,
                        ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GameConstants.warningColor.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pause_circle_filled_rounded,
                          color: GameConstants.warningColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PAUSED',
                          style: TextStyle(
                            color: GameConstants.warningColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<Position> snake;
  final Position food;
  final Direction currentDirection;

  _BoardPainter({
    required this.snake,
    required this.food,
    required this.currentDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / GameConstants.gridColumns;
    final double cellHeight = size.height / GameConstants.gridRows;
    const double cellPadding = 1.2;
    const Radius cornerRadius = Radius.circular(4.0);

    final Paint emptyCellPaint = Paint()
      ..color = GameConstants.gridCellColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (int col = 0; col < GameConstants.gridColumns; col++) {
      for (int row = 0; row < GameConstants.gridRows; row++) {
        final Rect rect = Rect.fromLTWH(
          col * cellWidth + cellPadding,
          row * cellHeight + cellPadding,
          cellWidth - (cellPadding * 2),
          cellHeight - (cellPadding * 2),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, cornerRadius),
          emptyCellPaint,
        );
      }
    }

    final double foodCenterX = (food.x * cellWidth) + (cellWidth / 2);
    final double foodCenterY = (food.y * cellHeight) + (cellHeight / 2);
    final double foodRadius = (cellWidth / 2) - 1.5;

    final Paint foodGlowPaint = Paint()
      ..color = GameConstants.foodGlowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(foodCenterX, foodCenterY),
      foodRadius + 2,
      foodGlowPaint,
    );

    final Paint foodPaint = Paint()
      ..color = GameConstants.foodColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(foodCenterX, foodCenterY), foodRadius, foodPaint);

    final Paint foodHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        foodCenterX - (foodRadius * 0.3),
        foodCenterY - (foodRadius * 0.3),
      ),
      foodRadius * 0.3,
      foodHighlightPaint,
    );

    final Paint bodyPaint = Paint()
      ..color = GameConstants.snakeBodyColor
      ..style = PaintingStyle.fill;

    final Paint bodyBorderPaint = Paint()
      ..color = GameConstants.snakeBodyBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < snake.length; i++) {
      final Position segment = snake[i];
      final Rect segmentRect = Rect.fromLTWH(
        segment.x * cellWidth + cellPadding,
        segment.y * cellHeight + cellPadding,
        cellWidth - (cellPadding * 2),
        cellHeight - (cellPadding * 2),
      );
      final RRect rrect = RRect.fromRectAndRadius(segmentRect, cornerRadius);
      canvas.drawRRect(rrect, bodyPaint);
      canvas.drawRRect(rrect, bodyBorderPaint);
    }

    if (snake.isNotEmpty) {
      final Position head = snake.first;
      final Rect headRect = Rect.fromLTWH(
        head.x * cellWidth + cellPadding,
        head.y * cellHeight + cellPadding,
        cellWidth - (cellPadding * 2),
        cellHeight - (cellPadding * 2),
      );

      final Paint headGlowPaint = Paint()
        ..color = GameConstants.snakeHeadColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(headRect, const Radius.circular(6)),
        headGlowPaint,
      );

      final Paint headPaint = Paint()
        ..color = GameConstants.snakeHeadColor
        ..style = PaintingStyle.fill;
      final RRect headRRect = RRect.fromRectAndRadius(
        headRect,
        const Radius.circular(5.0),
      );
      canvas.drawRRect(headRRect, headPaint);

      _drawEyes(canvas, headRect, cellWidth, cellHeight);
    }
  }

  void _drawEyes(
    Canvas canvas,
    Rect headRect,
    double cellWidth,
    double cellHeight,
  ) {
    final Paint eyePaint = Paint()
      ..color = GameConstants.snakeHeadEyeColor
      ..style = PaintingStyle.fill;

    final double eyeRadius = cellWidth * 0.12;
    Offset eye1;
    Offset eye2;

    switch (currentDirection) {
      case Direction.up:
        eye1 = Offset(
          headRect.left + cellWidth * 0.28,
          headRect.top + cellHeight * 0.28,
        );
        eye2 = Offset(
          headRect.right - cellWidth * 0.28,
          headRect.top + cellHeight * 0.28,
        );
        break;
      case Direction.down:
        eye1 = Offset(
          headRect.left + cellWidth * 0.28,
          headRect.bottom - cellHeight * 0.28,
        );
        eye2 = Offset(
          headRect.right - cellWidth * 0.28,
          headRect.bottom - cellHeight * 0.28,
        );
        break;
      case Direction.left:
        eye1 = Offset(
          headRect.left + cellWidth * 0.28,
          headRect.top + cellHeight * 0.28,
        );
        eye2 = Offset(
          headRect.left + cellWidth * 0.28,
          headRect.bottom - cellHeight * 0.28,
        );
        break;
      case Direction.right:
        eye1 = Offset(
          headRect.right - cellWidth * 0.28,
          headRect.top + cellHeight * 0.28,
        );
        eye2 = Offset(
          headRect.right - cellWidth * 0.28,
          headRect.bottom - cellHeight * 0.28,
        );
        break;
    }

    canvas.drawCircle(eye1, eyeRadius, eyePaint);
    canvas.drawCircle(eye2, eyeRadius, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.food != food ||
        oldDelegate.currentDirection != currentDirection;
  }
}
