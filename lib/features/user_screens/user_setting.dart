import 'package:flutter/material.dart';

import '../../data/local/db_helper.dart';
import '../../main.dart';

class UserSetting_Screen extends StatefulWidget {
  const UserSetting_Screen({super.key});

  @override
  State<UserSetting_Screen> createState() => _UserSetting_ScreenState();
}

class _UserSetting_ScreenState extends State<UserSetting_Screen> {
  Map<String, dynamic>? userinfo;
  final DBHelper dbref = DBHelper.getInstance;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      final result = await dbref.getUsers();
      if (result.isNotEmpty) {
        setState(() {
          userinfo = result.first;
        });
      } else {
        print("No user found in DB");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Setting")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userinfo == null
            ? const Center(child: Text("No user found"))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildInfoBox("ID", userinfo![DBHelper.COL_ID].toString()),
            buildInfoBox("Name", userinfo![DBHelper.COL_NAME]),
            buildInfoBox("Age", userinfo![DBHelper.COL_AGE].toString()),
            buildInfoBox("Gender", userinfo![DBHelper.COL_GENDER]),
            buildInfoBox("Height", "${userinfo![DBHelper.COL_HEIGHT]} cm"),
            buildInfoBox("Weight", "${userinfo![DBHelper.COL_WEIGHT]} kg"),
            buildInfoBox("Blood", userinfo![DBHelper.COL_BLOOD]),
          ],
        ),
      ),
    );
  }

  Widget buildInfoBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      width: double.infinity,
      child: Text(
        "$title: $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
