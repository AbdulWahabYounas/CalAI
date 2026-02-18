import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'height_weight.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Choose your Gender",
      subtitle: "This will be used to calibrate your custom plan.",
      isContinueEnabled: _selectedGender != null,
      onContinue: () {
        Get.to(() => const HeightWeightPage());
      },
      child: Column(
        children: [
          _buildOption("Male"),
          const SizedBox(height: 16),
          _buildOption("Female"),
          const SizedBox(height: 16),
          _buildOption("Other"),
        ],
      ),
    );
  }

  Widget _buildOption(String label) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => _selectGender(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
