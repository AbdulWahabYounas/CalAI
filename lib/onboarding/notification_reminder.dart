import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'final_onboarding.dart';

class NotificationReminderPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const NotificationReminderPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Be reminded to log meals",
      onContinue: () {
        Get.to(() => FinalOnboardingPage(
          goal: goal,
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          isImperial: isImperial,
          speed: speed,
        ));
      },
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Mock Notification Dialog
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Cal AI would like to send you Notifications",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Colors.grey),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.to(() => FinalOnboardingPage(
                          goal: goal,
                          targetWeight: targetWeight,
                          currentWeight: currentWeight,
                          isImperial: isImperial,
                          speed: speed,
                        )),
                        child: const Text("Don't Allow", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),
                    ),
                    Container(width: 1, height: 50, color: Colors.grey.shade300),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.to(() => FinalOnboardingPage(
                          goal: goal,
                          targetWeight: targetWeight,
                          currentWeight: currentWeight,
                          isImperial: isImperial,
                          speed: speed,
                        )),
                        child: const Text("Allow", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Icon(Icons.back_hand, size: 40, color: Colors.orange), // Representing the finger pointing from screenshot
        ],
      ),
    );
  }
}
