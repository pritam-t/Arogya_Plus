import 'package:flutter/material.dart';

class NearbyDoc_Screen extends StatefulWidget {
  const NearbyDoc_Screen({super.key});

  @override
  State<NearbyDoc_Screen> createState() => _NearbyDoc_ScreenState();
}

class _NearbyDoc_ScreenState extends State<NearbyDoc_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Doctor screen")
        ],
      ),
    );
  }
}
