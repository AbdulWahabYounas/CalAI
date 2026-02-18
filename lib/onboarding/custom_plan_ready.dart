import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'plan_sources.dart';

class CustomPlanReadyPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const CustomPlanReadyPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
    required this.speed,
  });

  int get _calories {
    int base = 2000;
    if (goal.contains("Lose")) {
      return base - (speed * 500).round();
    } else if (goal.contains("Gain")) {
      return base + (speed * 500).round();
    }
    return base;
  }

  String get _achievementDate {
    if (goal == "Maintain") return "Today";
    
    double targetVal = double.tryParse(targetWeight) ?? currentWeight;
    double diff = (currentWeight - targetVal).abs();
    int weeks = (diff / speed).ceil();
    
    DateTime targetDate = DateTime.now().add(Duration(days: weeks * 7));
    return "${_getMonthName(targetDate.month)} ${targetDate.day}, ${targetDate.year}";
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final cals = _calories;
    final carbs = (cals * 0.4 / 4).round();
    final protein = (cals * 0.35 / 4).round();
    final fats = (cals * 0.25 / 9).round();
    final unit = isImperial ? "lbs" : "kg";

    return OnboardingScaffold(
      title: "Congratulations\nyour custom plan is ready!",
      footer: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Get.to(() => const PlanSourcesPage()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Let's get started!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Column(
        children: [
          const Center(
            child: Icon(Icons.check_circle, size: 48, color: Colors.black),
          ),
          const SizedBox(height: 24),
          Text(
            goal == "Maintain" ? "You should maintain:" : "You should ${goal.toLowerCase().contains("lose") ? "lose" : "gain"}:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              goal == "Maintain" ? "Maintain current weight" : "${goal.toLowerCase().contains("lose") ? "Lose" : "Gain"} ${(currentWeight - (double.tryParse(targetWeight) ?? 0)).abs().round()} $unit by $_achievementDate",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 48),
          const Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Daily recommendation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("You can edit this anytime", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildMacroCard("Calories", "$cals", Colors.black, 0.7, Icons.local_fire_department),
              _buildMacroCard("Carbs", "${carbs}g", Colors.orange, 0.6, Icons.grain),
              _buildMacroCard("Protein", "${protein}g", Colors.red.shade400, 0.8, Icons.kebab_dining),
              _buildMacroCard("Fats", "${fats}g", Colors.blue.shade400, 0.4, Icons.opacity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color, double progress, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.edit, size: 12, color: Colors.grey.shade400),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
