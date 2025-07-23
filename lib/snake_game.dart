import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int cols = 20;
  static const Duration tickRate = Duration(milliseconds: 200);

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  String direction = 'right';
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
    // 桌機支援鍵盤
    RawKeyboard.instance.addListener(_handleKey);
  }

  @override
  void dispose() {
    timer?.cancel();
    RawKeyboard.instance.removeListener(_handleKey);
    super.dispose();
  }

  void startGame() {
    snake = [const Point(10, 10)];
    direction = 'right';
    spawnFood();
    score = 0;
    timer?.cancel();
    timer = Timer.periodic(tickRate, (_) => updateSnake());
  }

  void updateSnake() {
    final head = snake.first;
    Point<int> newHead;

    switch (direction) {
      case 'up':
        newHead = Point(head.x, head.y - 1);
        break;
      case 'down':
        newHead = Point(head.x, head.y + 1);
        break;
      case 'left':
        newHead = Point(head.x - 1, head.y);
        break;
      case 'right':
        newHead = Point(head.x + 1, head.y);
        break;
      default:
        return;
    }

    // 撞牆或撞到自己就遊戲結束
    if (newHead.x < 0 || newHead.y < 0 || newHead.x >= cols || newHead.y >= rows || snake.contains(newHead)) {
      timer?.cancel();
      showGameOverDialog();
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score += 10;
        spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void spawnFood() {
    final rng = Random();
    do {
      food = Point(rng.nextInt(cols), rng.nextInt(rows));
    } while (snake.contains(food));
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel.toLowerCase();
      switch (key) {
        case 'w':
        case 'arrow up':
          if (direction != 'down') direction = 'up';
          break;
        case 's':
        case 'arrow down':
          if (direction != 'up') direction = 'down';
          break;
        case 'a':
        case 'arrow left':
          if (direction != 'right') direction = 'left';
          break;
        case 'd':
        case 'arrow right':
          if (direction != 'left') direction = 'right';
          break;
      }
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("你的分數是：$score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text("再玩一次"),
          ),
        ],
      ),
    );
  }

  // 手機滑動方向控制
  void onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (details.velocity.pixelsPerSecond.dx.abs() > details.velocity.pixelsPerSecond.dy.abs()) {
      if (velocity > 0 && direction != 'left') direction = 'right';
      else if (velocity < 0 && direction != 'right') direction = 'left';
    } else {
      if (velocity > 0 && direction != 'up') direction = 'down';
      else if (velocity < 0 && direction != 'down') direction = 'up';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = MediaQuery.of(context).size.width / cols;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: onSwipe,
          onVerticalDragEnd: onSwipe,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("分數：$score", style: const TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    final x = index % cols;
                    final y = index ~/ cols;
                    final point = Point(x, y);
                    Color color;

                    if (snake.first == point) {
                      color = Colors.greenAccent;
                    } else if (snake.contains(point)) {
                      color = Colors.green;
                    } else if (food == point) {
                      color = Colors.red;
                    } else {
                      color = Colors.grey[900]!;
                    }

                    return Container(
                      width: gridSize,
                      height: gridSize,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
