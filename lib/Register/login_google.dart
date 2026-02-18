import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../onboarding/gender_selection.dart';

class LoginGoogle {
  static Future<void> signIn(BuildContext context) async {
    final AuthService authService = Get.put(AuthService());
    await authService.signInWithGoogle();
    
    // Check if user is signed in and navigate
    if (authService.user.value != null) {
      Get.offAll(() => const GenderSelectionPage());
    }
  }
}
