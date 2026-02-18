import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'previous_experience.dart';

class SourcePage extends StatefulWidget {
  final double currentWeight;
  final bool isImperial;

  const SourcePage({
    super.key,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  String? _selectedSource;

  void _selectSource(String source) {
    setState(() {
      _selectedSource = source;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Where did you hear about us?",
      isContinueEnabled: _selectedSource != null,
      onContinue: () {
        Get.to(() => PreviousExperiencePage(
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: [
          _buildOption("Youtube", Icons.play_arrow, Colors.red),
          const SizedBox(height: 16),
          _buildOption("App Store", Icons.apple, Colors.blue), // Or generic store icon
          const SizedBox(height: 16),
          _buildOption("X", Icons.close, Colors.black), // Using close icon as X placeholder or text
          const SizedBox(height: 16),
          _buildOption("TV", Icons.tv, Colors.black),
          const SizedBox(height: 16),
          _buildOption("Friend or family", Icons.people, Colors.black),
          const SizedBox(height: 16),
          _buildOption("Instagram", Icons.camera_alt, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildOption(String label, IconData iconData, Color iconColor) {
    final isSelected = _selectedSource == label;
    return GestureDetector(
      onTap: () => _selectSource(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                 borderRadius: BorderRadius.circular(12),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.shade200,
                     blurRadius: 4,
                     offset: const Offset(0, 2),
                   )
                 ]
               ),
               child: Icon(iconData, color: iconColor),
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
