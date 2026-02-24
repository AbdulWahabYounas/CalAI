import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'calories_burned.dart';

class DietSelectionPage extends StatefulWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const DietSelectionPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
    required this.speed,
  });

  @override
  State<DietSelectionPage> createState() => _DietSelectionPageState();
}

class _DietSelectionPageState extends State<DietSelectionPage> {
  String? _selectedDiet;

  final List<Map<String, dynamic>> _diets = [
    {"label": "Classic", "icon": Icons.restaurant_menu},
    {"label": "Pescatarian", "icon": Icons.set_meal},
    {"label": "Vegetarian", "icon": Icons.eco},
    {"label": "Vegan", "icon": Icons.grass},
  ];

  void _selectDiet(String label) {
    setState(() {
      _selectedDiet = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Do you follow a specific diet?",
      progress: 0.60,
      isContinueEnabled: _selectedDiet != null,
      onContinue: () {
        Get.to(() => CaloriesBurnedPage(
          goal: widget.goal,
          targetWeight: widget.targetWeight,
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
          speed: widget.speed,
        ));
      },
      child: Column(
        children: _diets.map((diet) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOption(diet["label"], diet["icon"]),
        )).toList(),
      ),
    );
  }

  Widget _buildOption(String label, IconData icon) {
    final isSelected = _selectedDiet == label;
    return GestureDetector(
      onTap: () => _selectDiet(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
