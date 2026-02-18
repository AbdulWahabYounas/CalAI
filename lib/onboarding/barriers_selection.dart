import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'diet_selection.dart';

class BarriersSelectionPage extends StatefulWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const BarriersSelectionPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
    required this.speed,
  });

  @override
  State<BarriersSelectionPage> createState() => _BarriersSelectionPageState();
}

class _BarriersSelectionPageState extends State<BarriersSelectionPage> {
  final Set<String> _selectedBarriers = {};

  final List<Map<String, dynamic>> _barriers = [
    {"label": "Lack of consistency", "icon": Icons.bar_chart},
    {"label": "Unhealthy eating habits", "icon": Icons.restaurant},
    {"label": "Lack of support", "icon": Icons.handshake},
    {"label": "Busy schedule", "icon": Icons.calendar_month},
    {"label": "Lack of meal inspiration", "icon": Icons.apple},
  ];

  void _toggleBarrier(String label) {
    setState(() {
      if (_selectedBarriers.contains(label)) {
        _selectedBarriers.remove(label);
      } else {
        _selectedBarriers.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "What's stopping you from reaching your goals?",
      isContinueEnabled: _selectedBarriers.isNotEmpty,
      onContinue: () {
        Get.to(() => DietSelectionPage(
          goal: widget.goal,
          targetWeight: widget.targetWeight,
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
          speed: widget.speed,
        ));
      },
      child: Column(
        children: _barriers.map((barrier) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOption(barrier["label"], barrier["icon"]),
        )).toList(),
      ),
    );
  }

  Widget _buildOption(String label, IconData icon) {
    final isSelected = _selectedBarriers.contains(label);
    return GestureDetector(
      onTap: () => _toggleBarrier(label),
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
