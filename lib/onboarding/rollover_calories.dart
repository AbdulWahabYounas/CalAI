import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'notification_reminder.dart';

class RolloverCaloriesPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const RolloverCaloriesPage({
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
      title: "Rollover extra calories to the next day?",
      progress: 0.68,
      footer: Row(
        children: [
          Expanded(
            child: _buildButton("No", Colors.black, () {
               Get.to(() => NotificationReminderPage(
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
            child: _buildButton("Yes", Colors.black, () {
               Get.to(() => NotificationReminderPage(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Rollover up to ", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                const Text("200 cals", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Stack(
            children: [
               _buildCalCard("Yesterday", "350", "500", Colors.red.shade50, 150, false),
               Positioned(
                 top: 100,
                 right: 0,
                 child: _buildCalCard("Today", "350", "650", Colors.grey.shade100, 150, true),
               ),
            ],
          ),
          const SizedBox(height: 180), // Space for absolute positioned cards
        ],
      ),
    );
  }

  Widget _buildCalCard(String title, String current, String total, Color bgColor, int left, bool showRollover) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              const Icon(Icons.local_fire_department, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: current),
                TextSpan(text: "/$total", style: TextStyle(fontSize: 18, color: Colors.grey.shade400, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (showRollover)
            Row(
              children: [
                const Icon(Icons.restore, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                const Text("+150", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text("Cals left", style: TextStyle(color: Colors.white, fontSize: 10)),
                    Text(
                      showRollover ? "$left + $left" : "$left",
                      style: TextStyle(
                        color: showRollover ? Colors.blue : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 4,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bgColor, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
