import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'current_weight.dart';
import 'onboarding_scaffold.dart';
import 'target_weight.dart';
import 'diet_selection.dart';
import '../controllers/onboarding_controller.dart';

class GoalSelectionPage extends StatefulWidget {
  final bool isImperial;

  const GoalSelectionPage({
    super.key,
    required this.isImperial,
  });

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  String? _selectedGoal;

  final List<String> _goals = [
    "Lose weight",
    "Maintain",
    "Gain weight",
  ];

  void _selectGoal(String goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "What is your goal?",
      subtitle: "This helps us generate a plan for your calorie intake.",
      progress: 0.32,
      isContinueEnabled: _selectedGoal != null,
      onContinue: () {
        final controller = Get.find<OnboardingController>();
        controller.goal.value = _selectedGoal!;
        Get.to(() => CurrentWeightPage(
          goal: _selectedGoal!,
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: _goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildOption(goal),
        )).toList(),
      ),
    );
  }

  Widget _buildOption(String label) {
    final isSelected = _selectedGoal == label;
    return GestureDetector(
      onTap: () => _selectGoal(label),
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
