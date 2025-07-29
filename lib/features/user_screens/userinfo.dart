import 'package:flutter/material.dart';

class UserInfo_Screen extends StatefulWidget {
  const UserInfo_Screen({super.key});

  @override
  State<UserInfo_Screen> createState() => _UserInfo_ScreenState();
}

class _UserInfo_ScreenState extends State<UserInfo_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("User Info Screen")
        ],
      ),
    );
  }
}
