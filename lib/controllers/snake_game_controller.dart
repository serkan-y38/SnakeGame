import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/constants/game_constants.dart';
import '../core/enums/direction.dart';
import '../core/enums/game_status.dart';
import '../models/position.dart';

class SnakeGameController extends ChangeNotifier {
  final Random _random = Random();

  List<Position> _snake = [];
  Position _food = const Position(15, 10);
  Direction _currentDirection = Direction.right;
  Direction _nextDirection = Direction.right;
  GameStatus _status = GameStatus.initial;

  int _score = 0;
  int _highScore = 0;
  Timer? _gameTimer;
  Duration _currentSpeed = GameConstants.initialSpeed;

  VoidCallback? onFoodEaten;

  List<Position> get snake => List.unmodifiable(_snake);

  Position get food => _food;

  Direction get currentDirection => _currentDirection;

  GameStatus get status => _status;

  int get score => _score;

  int get highScore => _highScore;

  bool get isPlaying => _status == GameStatus.playing;

  bool get isPaused => _status == GameStatus.paused;

  bool get isGameOver => _status == GameStatus.gameOver;

  bool get isInitial => _status == GameStatus.initial;

  SnakeGameController() {
    _resetGameComponents();
  }

  void _resetGameComponents() {
    const int startX = 6;
    const int startY = 10;
    _snake = [
      const Position(startX + 2, startY),
      const Position(startX + 1, startY),
      const Position(startX, startY),
    ];
    _currentDirection = Direction.right;
    _nextDirection = Direction.right;
    _currentSpeed = GameConstants.initialSpeed;
    _food = _generateFood();
  }

  void startGame() {
    if (_status == GameStatus.playing) return;

    if (_status == GameStatus.gameOver || _status == GameStatus.initial) {
      _resetGameComponents();
      _score = 0;
    }

    _status = GameStatus.playing;
    _startTimer();
    notifyListeners();
  }

  void pauseGame() {
    if (_status != GameStatus.playing) return;

    _status = GameStatus.paused;
    _gameTimer?.cancel();
    notifyListeners();
  }

  void togglePause() {
    if (_status == GameStatus.playing) {
      pauseGame();
    } else if (_status == GameStatus.paused || _status == GameStatus.initial) {
      startGame();
    } else if (_status == GameStatus.gameOver) {
      restartGame();
    }
  }

  void restartGame() {
    _gameTimer?.cancel();
    _resetGameComponents();
    _score = 0;
    _status = GameStatus.playing;
    _startTimer();
    notifyListeners();
  }

  void changeDirection(Direction newDirection) {
    if (_status == GameStatus.initial) {
      startGame();
    }

    if (_status != GameStatus.playing) return;

    if (!_currentDirection.isOpposite(newDirection)) {
      _nextDirection = newDirection;
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_currentSpeed, (_) => _tick());
  }

  void _tick() {
    if (_status != GameStatus.playing) return;

    _currentDirection = _nextDirection;

    final Position currentHead = _snake.first;
    int nextX = currentHead.x;
    int nextY = currentHead.y;

    switch (_currentDirection) {
      case Direction.up:
        nextY -= 1;
        break;
      case Direction.down:
        nextY += 1;
        break;
      case Direction.left:
        nextX -= 1;
        break;
      case Direction.right:
        nextX += 1;
        break;
    }

    if (nextX < 0) {
      nextX = GameConstants.gridColumns - 1;
    } else if (nextX >= GameConstants.gridColumns) {
      nextX = 0;
    }

    if (nextY < 0) {
      nextY = GameConstants.gridRows - 1;
    } else if (nextY >= GameConstants.gridRows) {
      nextY = 0;
    }

    final Position nextHead = Position(nextX, nextY);

    if (_snake.contains(nextHead)) {
      _handleGameOver();
      return;
    }

    _snake.insert(0, nextHead);

    if (nextHead == _food) {
      _score += GameConstants.pointsPerFood;
      if (_score > _highScore) {
        _highScore = _score;
      }
      onFoodEaten?.call();
      _food = _generateFood();
      _adjustSpeed();
    } else {
      _snake.removeLast();
    }

    notifyListeners();
  }

  void _adjustSpeed() {
    if (_currentSpeed > GameConstants.minSpeed) {
      final int newMilliseconds = max(
        GameConstants.minSpeed.inMilliseconds,
        _currentSpeed.inMilliseconds - GameConstants.speedStepMilliseconds,
      );
      _currentSpeed = Duration(milliseconds: newMilliseconds);
      _startTimer();
    }
  }

  Position _generateFood() {
    final List<Position> availablePositions = [];
    final Set<Position> snakePositions = _snake.toSet();

    for (int x = 0; x < GameConstants.gridColumns; x++) {
      for (int y = 0; y < GameConstants.gridRows; y++) {
        final pos = Position(x, y);
        if (!snakePositions.contains(pos)) {
          availablePositions.add(pos);
        }
      }
    }

    if (availablePositions.isEmpty) {
      return const Position(0, 0);
    }

    return availablePositions[_random.nextInt(availablePositions.length)];
  }

  void _handleGameOver() {
    _status = GameStatus.gameOver;
    _gameTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
