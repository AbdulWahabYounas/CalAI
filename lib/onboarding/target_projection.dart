import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'target_speed.dart';

class TargetProjectionPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;

  const TargetProjectionPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  Widget build(BuildContext context) {
    final action = goal.toLowerCase().contains("lose") ? "Losing" : "Gaining";
    
    return OnboardingScaffold(
      title: "", // We'll build the title manually for custom styling
      isContinueEnabled: true,
      onContinue: () {
        Get.to(() => TargetSpeedPage(
          goal: goal,
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          isImperial: isImperial,
        ));
      },
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                children: [
                  TextSpan(text: "$action "),
                  TextSpan(
                    text: targetWeight,
                    style: const TextStyle(color: Color(0xFFE6A071)), // Warm orange color from design
                  ),
                  const TextSpan(text: " is a realistic target. It's not hard at all!"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "90% of users say that the change is obvious after using Cal AI and it is not easy to rebound.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
