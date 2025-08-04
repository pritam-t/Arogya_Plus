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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("AI ASSISTANT COMING SOON !")
        ],
      ),
    );
  }
}
