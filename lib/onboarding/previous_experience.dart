import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'coach_selection.dart';

class PreviousExperiencePage extends StatefulWidget {
  final double currentWeight;
  final bool isImperial;

  const PreviousExperiencePage({
    super.key,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<PreviousExperiencePage> createState() => _PreviousExperiencePageState();
}

class _PreviousExperiencePageState extends State<PreviousExperiencePage> {
  bool? _hasExperience;

  void _selectExperience(bool hasExperience) {
    setState(() {
      _hasExperience = hasExperience;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Have you tried other calorie tracking apps?",
      isContinueEnabled: _hasExperience != null,
      onContinue: () {
        // Navigate to Coach Selection Page
        Get.to(() => CoachSelectionPage(
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: [
          _buildOption(true, "Yes", Icons.thumb_up),
          const SizedBox(height: 16),
          _buildOption(false, "No", Icons.thumb_down),
        ],
      ),
    );
  }

  Widget _buildOption(bool value, String label, IconData icon) {
    final isSelected = _hasExperience == value;
    return GestureDetector(
      onTap: () => _selectExperience(value),
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
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.white,
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
