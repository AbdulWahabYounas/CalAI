import 'dart:async';

import 'package:cal_ai/Register/register_home.dart';
import 'package:cal_ai/Home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (Get.currentRoute != '/HomeScreen') {
          Get.offAll(() => const HomeScreen());
        }
      } else {
        if (Get.currentRoute != '/RegisterHome') {
          Get.offAll(() => const RegisterHome());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 60,
              color: Colors.black,
            ),
            const SizedBox(width: 10),
            const Text(
              "Cal AI",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display', // System font fallback usually works
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
