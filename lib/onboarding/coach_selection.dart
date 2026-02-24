import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'goal_selection.dart';
import '../controllers/onboarding_controller.dart';

class CoachSelectionPage extends StatefulWidget {
  final bool isImperial;

  const CoachSelectionPage({
    super.key,
    required this.isImperial,
  });

  @override
  State<CoachSelectionPage> createState() => _CoachSelectionPageState();
}

class _CoachSelectionPageState extends State<CoachSelectionPage> {
  bool? _worksWithCoach;

  void _selectOption(bool value) {
    setState(() {
      _worksWithCoach = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Do you currently work with a personal coach or nutritionist?",
      progress: 0.28,
      isContinueEnabled: _worksWithCoach != null,
      onContinue: () {
        final controller = Get.find<OnboardingController>();
        controller.coach.value = _worksWithCoach! ? "Yes" : "No";
        Get.to(() => GoalSelectionPage(
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: [
          _buildOption(true, "Yes", Icons.check_circle),
          const SizedBox(height: 16),
          _buildOption(false, "No", Icons.cancel),
        ],
      ),
    );
  }

  Widget _buildOption(bool value, String label, IconData icon) {
    final isSelected = _worksWithCoach == value;
    return GestureDetector(
      onTap: () => _selectOption(value),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.grey.shade400,
                size: 20,
              ),
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
