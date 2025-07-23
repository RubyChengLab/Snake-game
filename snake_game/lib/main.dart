import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData.dark(),
      home: const SnakeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int columns = 20;
  static const Duration tickRate = Duration(milliseconds: 200);

  late Timer timer;
  List<Point<int>> snake = [
    const Point(10, 10),
    const Point(9, 10),
    const Point(8, 10),
  ];
  Point<int> food = const Point(5, 5);
  Point<int> direction = const Point(1, 0); // 初始向右
  int score = 0;
  bool isGameOver = false;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    startGame();
    focusNode.requestFocus();
  }

  void startGame() {
    timer = Timer.periodic(tickRate, (Timer t) => updateGame());
  }

  void updateGame() {
    setState(() {
      final newHead = snake.first + direction;

      if (newHead.x < 0 || newHead.y < 0 || newHead.x >= columns || newHead.y >= rows || snake.contains(newHead)) {
        timer.cancel();
        isGameOver = true;
        return;
      }

      snake.insert(0, newHead);
      if (newHead == food) {
        score++;
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void generateFood() {
    final random = Random();
    do {
      food = Point(random.nextInt(columns), random.nextInt(rows));
    } while (snake.contains(food));
  }

  void changeDirection(Point<int> newDirection) {
    if (direction + newDirection != const Point(0, 0)) {
      direction = newDirection;
    }
  }

  void onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyId) {
        case 0x100070052: // Arrow Up
          changeDirection(const Point(0, -1));
          break;
        case 0x100070051: // Arrow Down
          changeDirection(const Point(0, 1));
          break;
        case 0x100070050: // Arrow Left
          changeDirection(const Point(-1, 0));
          break;
        case 0x10007004F: // Arrow Right
          changeDirection(const Point(1, 0));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cellSize = min(screenWidth / columns, (screenHeight - 100) / rows);

    return Scaffold(
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: focusNode,
          onKey: onKey,
          autofocus: true,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black,
                width: double.infinity,
                child: Text('Score: $score', style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
              ),
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < 0) changeDirection(const Point(0, -1));
                    if (details.primaryDelta! > 0) changeDirection(const Point(0, 1));
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! < 0) changeDirection(const Point(-1, 0));
                    if (details.primaryDelta! > 0) changeDirection(const Point(1, 0));
                  },
                  child: Center(
                    child: Container(
                      width: cellSize * columns,
                      height: cellSize * rows,
                      color: Colors.black,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                        ),
                        itemCount: rows * columns,
                        itemBuilder: (context, index) {
                          final x = index % columns;
                          final y = index ~/ columns;
                          final point = Point(x, y);

                          Color color;
                          if (snake.contains(point)) {
                            color = Colors.green;
                          } else if (point == food) {
                            color = Colors.red;
                          } else {
                            color = Colors.grey.shade800;
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (isGameOver)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red,
                  child: Text('Game Over! Score: $score', style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

extension on Point<int> {
  Point<int> operator +(Point<int> other) => Point(x + other.x, y + other.y);
}