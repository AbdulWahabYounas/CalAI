import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'rollover_calories.dart';

class CaloriesBurnedPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const CaloriesBurnedPage({
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
      title: "Add calories burned back to your daily goal?",
      footer: Row(
        children: [
          Expanded(
            child: _buildButton("No", Colors.black, Colors.white, () {
               Get.to(() => RolloverCaloriesPage(
                 goal: goal,
                 targetWeight: targetWeight,
                 currentWeight: currentWeight,
                 isImperial: isImperial,
                 speed: speed,
               ));
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildButton("Yes", Colors.black, Colors.white, () {
               Get.to(() => RolloverCaloriesPage(
                 goal: goal,
                 targetWeight: targetWeight,
                 currentWeight: currentWeight,
                 isImperial: isImperial,
                 speed: speed,
               ));
            }),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder for the running person image
                  Icon(Icons.directions_run, size: 100, color: Colors.grey.shade300),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Goal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.black, size: 20),
                              const SizedBox(width: 4),
                              const Text("500 Cals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                child: const Icon(Icons.directions_run, color: Colors.white, size: 12),
                              ),
                              const SizedBox(width: 8),
                              const Text("Running", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("+100 cals", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
