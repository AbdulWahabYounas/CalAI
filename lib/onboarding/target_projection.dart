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
    final double targetVal = double.tryParse(targetWeight) ?? currentWeight;
    final double diff = (currentWeight - targetVal).abs();
    final String diffStr = diff.toStringAsFixed(0);
    final String unit = isImperial ? "lbs" : "kg";

    String reaction;
    if (diff > 50) {
      reaction = "This is a bold journey, and we're here to support you! $diffStr $unit is a significant goal.";
    } else if (diff > 10) {
      reaction = "$diffStr $unit is a realistic target. It's not hard at all!";
    } else {
      reaction = "You're so close! $diffStr $unit is a very achievable target.";
    }

    final action = goal.toLowerCase().contains("lose") ? "Losing" : "Gaining";
    
    return OnboardingScaffold(
      title: "", // We'll build the title manually for custom styling
      progress: 0.44,
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
                  fontSize: 28, // Reduced slightly to fit more text
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                children: [
                  TextSpan(text: reaction),
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
