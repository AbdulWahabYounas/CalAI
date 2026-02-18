import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import '../Home/home_screen.dart';

class PlanSourcesPage extends StatelessWidget {
  const PlanSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "How to reach your goals:",
      footer: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Get.offAll(() => const HomeScreen()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Let's get started!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalItem(Icons.favorite, Colors.pink.shade300, "Use health scores to improve your routine"),
          const SizedBox(height: 32),
          _buildGoalItem(Icons.restaurant, Colors.green.shade300, "Track your food"),
          const SizedBox(height: 32),
          _buildGoalItem(Icons.local_fire_department, Colors.grey.shade400, "Follow your daily calorie recommendation"),
          const SizedBox(height: 32),
          _buildGoalItem(Icons.eco, Colors.orange.shade200, "Balance your carbs, proteins, and fat"),
          const SizedBox(height: 64),
          const Text(
            "Plan based on the following sources, among other peer-reviewed medical studies:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSourceLink("Basal metabolic rate"),
          _buildSourceLink("Calorie counting - Harvard"),
          _buildSourceLink("International Society of Sports Nutrition"),
          _buildSourceLink("National Institutes of Health"),
        ],
      ),
    );
  }

  Widget _buildGoalItem(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "• $text",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
