import 'package:flutter/material.dart';

class AI_Assistant_Screen extends StatefulWidget {
  const AI_Assistant_Screen({super.key});

  @override
  State<AI_Assistant_Screen> createState() => _AI_Assistant_ScreenState();
}

class _AI_Assistant_ScreenState extends State<AI_Assistant_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/bot_light.png',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "AI ASSISTANT\nCOMING SOON!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );

  }
}
