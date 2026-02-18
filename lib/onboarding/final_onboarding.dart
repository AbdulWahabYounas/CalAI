import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'long_term_results.dart';

class FinalOnboardingPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const FinalOnboardingPage({
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
      title: "All done! Time to generate your custom plan!",
      onContinue: () {
        Get.to(() => LongTermResultsPage(
          goal: goal,
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          isImperial: isImperial,
          speed: speed,
        ));
      },
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade50,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 40),
                  // Mock illustration of the hand heart
                  Icon(Icons.front_hand, size: 120, color: Colors.black),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text("All done!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
