import 'package:flutter/material.dart';

class UserSetting_Screen extends StatefulWidget {
  const UserSetting_Screen({super.key});

  @override
  State<UserSetting_Screen> createState() => _UserSetting_ScreenState();
}

class _UserSetting_ScreenState extends State<UserSetting_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("User Setting Screen")
        ],
      ),
    );
  }
}
