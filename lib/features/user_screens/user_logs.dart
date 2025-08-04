import 'package:flutter/material.dart';

class User_Logs_Screen extends StatefulWidget {
  const User_Logs_Screen({super.key});

  @override
  State<User_Logs_Screen> createState() => _User_Logs_ScreenState();
}

class _User_Logs_ScreenState extends State<User_Logs_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("User Logs Screen")
        ],
      ),
    );
  }
}
