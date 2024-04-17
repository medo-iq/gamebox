import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';

class HomeGamePage extends StatefulWidget {
  const HomeGamePage({Key? key}) : super(key: key);

  @override
  _HomeGamePageState createState() => _HomeGamePageState();
}

class _HomeGamePageState extends State<HomeGamePage>
    with SingleTickerProviderStateMixin {
  late int level;
  late int correctBoxIndex;
  late List<Color> boxColors;
  late bool gameOver;
  late int lastCorrectBoxIndex;
  late AnimationController _controller;
  late SequenceAnimation winAnimation;
  late SequenceAnimation loseAnimation;

  @override
  void initState() {
    super.initState();
    level = 1;
    gameOver = false;
    initializeGame();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    winAnimation = SequenceAnimationBuilder()
        .addAnimatable(
          animatable: Tween<double>(begin: 1.0, end: 1.0), // Set scale to 1.0
          from: const Duration(milliseconds: 0),
          to: const Duration(milliseconds: 600),
          tag: "scale",
        )
        .addAnimatable(
          animatable: Tween<double>(begin: 1.0, end: 1.0),
          from: const Duration(milliseconds: 0),
          to: const Duration(milliseconds: 600),
          tag: "opacity",
        )
        .animate(_controller);
    loseAnimation = SequenceAnimationBuilder()
        .addAnimatable(
          animatable: Tween<double>(begin: 1.0, end: 1.0),
          from: const Duration(milliseconds: 0),
          to: const Duration(milliseconds: 300),
          tag: "scale",
        )
        .addAnimatable(
          animatable: Tween<double>(begin: 1.0, end: 0.9),
          from: const Duration(milliseconds: 0),
          to: const Duration(milliseconds: 300),
          tag: "opacity",
        )
        .animate(_controller);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initializeGame() {
    correctBoxIndex = Random().nextInt(3);
    lastCorrectBoxIndex = correctBoxIndex;
    boxColors = List<Color>.generate(3, (index) => Colors.grey);
  }

  void restartGame() {
    setState(() {
      level = 1;
      initializeGame();
      gameOver = false;
    });
  }

  void nextLevel() {
    setState(() {
      level++;
      initializeGame();
    });
  }

  void _onBoxTap(int index) {
    if (!gameOver) {
      setState(() {
        if (index == correctBoxIndex) {
          _controller.reset();
          _controller.forward();
          boxColors[index] = Colors.transparent; // To trigger animation
          nextLevel();
          // Show green color notification for 0.5 seconds
          Future.delayed(const Duration(milliseconds: 50), () {
            setState(() {
              boxColors[index] =
                  Colors.green.withOpacity(1); // Start with opacity 1
              // Animate to fully transparent after 0.3 seconds
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {
                  boxColors[index] = Colors.green.withOpacity(0);
                });
              });
            });
          });
        } else {
          _controller.reset();
          _controller.forward();
          boxColors[lastCorrectBoxIndex] = Colors.green;
          boxColors[correctBoxIndex] = Colors.red;
          gameOver = true;
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background Box
                Positioned(
                  top: 120,
                  left: 53,
                  child: Container(
                    width: 350,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: const Color(0xffcccccc),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                // Game Info
                Positioned(
                  left: 40,
                  child: SizedBox(
                    width: 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(95, 54, 54, 54),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(0.0, -65.0),
                              child: Container(
                                width: 120,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xff7c90fe),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 2, 0, 0),
                                      child: Text(
                                        'LEVEL $level',
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Select the correct box
                const Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Select the correct box',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Boxes
                Positioned(
                  top: 200,
                  left: 37,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20),
                      _buildBox(0),
                      const SizedBox(width: 20),
                      _buildBox(1),
                      const SizedBox(width: 20),
                      _buildBox(2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Game Over Message
          if (gameOver)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFD685D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
                    child: ElevatedButton(
                      onPressed: restartGame,
                      child: const Text('Restart Game',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(188, 0, 0, 0),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBox(int index) {
    return GestureDetector(
      onTap: () => _onBoxTap(index),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: index == correctBoxIndex
                ? winAnimation["scale"].value
                : loseAnimation["scale"].value,
            child: Opacity(
              opacity: index == correctBoxIndex
                  ? winAnimation["opacity"].value
                  : loseAnimation["opacity"].value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: boxColors[index],
                  border: Border.all(color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
