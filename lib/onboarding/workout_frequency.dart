import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'source_page.dart';

class WorkoutFrequencyPage extends StatefulWidget {
  final double currentWeight;
  final bool isImperial;

  const WorkoutFrequencyPage({
    super.key,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<WorkoutFrequencyPage> createState() => _WorkoutFrequencyPageState();
}

class _WorkoutFrequencyPageState extends State<WorkoutFrequencyPage> {
  String? _selectedFrequency;

  void _selectFrequency(String frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "How many workouts do you do per week?",
      subtitle: "This will be used to calibrate your custom plan.",
      isContinueEnabled: _selectedFrequency != null,
      onContinue: () {
        Get.to(() => SourcePage(
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: [
          _buildOption("0-2", "Workouts now and then"),
          const SizedBox(height: 16),
          _buildOption("3-5", "A few workouts per week", isActive: true), // Example active state logic if needed
          const SizedBox(height: 16),
          _buildOption("6+", "Dedicated athlete"),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String subLabel, {bool isActive = false}) {
     final isSelected = _selectedFrequency == label;

    return GestureDetector(
      onTap: () => _selectFrequency(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            // Placeholder for icon/graphic if needed, using a simple circle for now as per design
             Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: Colors.white,
                 shape: BoxShape.circle,
                 border: Border.all(color: Colors.grey.shade300),
               ),
               child: Center(
                 child: isSelected ? const Icon(Icons.check, size: 20) : null,
               ),
             ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
