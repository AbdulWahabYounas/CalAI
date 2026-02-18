import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'barriers_selection.dart';

class ComparisonStatsPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const ComparisonStatsPage({
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
      title: "Lose twice as much weight with Cal AI vs on your own",
      isContinueEnabled: true,
      onContinue: () {
        Get.to(() => BarriersSelectionPage(
          goal: goal,
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          isImperial: isImperial,
          speed: speed,
        ));
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar("Without\nCal AI", "20%", Colors.grey.shade200, 100),
                  const SizedBox(width: 24),
                  _buildBar("With\nCal AI", "2X", Colors.black, 180),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Cal AI makes it easy and holds you accountable.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, String value, Color color, double height) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color == Colors.black ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
