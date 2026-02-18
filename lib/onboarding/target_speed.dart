import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'comparison_stats.dart';

class TargetSpeedPage extends StatefulWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;

  const TargetSpeedPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<TargetSpeedPage> createState() => _TargetSpeedPageState();
}

class _TargetSpeedPageState extends State<TargetSpeedPage> {
  double _speedValue = 1.0; // 0: Slow, 1: Recommended, 2: Fast
  
  String get _speedLabel {
    if (_speedValue < 0.5) return "0.5 lbs";
    if (_speedValue < 1.5) return "1.0 lbs";
    return "2.0 lbs";
  }

  double get _speedInLbs {
     if (_speedValue < 0.5) return 0.5;
    if (_speedValue < 1.5) return 1.0;
    return 2.0;
  }

  String get _duration {
    if (_speedValue < 0.5) return "24 months";
    if (_speedValue < 1.5) return "15 months";
    return "8 months";
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "How fast do you want to reach your goal?",
      isContinueEnabled: true,
      onContinue: () {
        Get.to(() => ComparisonStatsPage(
          goal: widget.goal,
          targetWeight: widget.targetWeight,
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
          speed: _speedInLbs,
        ));
      },
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            widget.goal.toLowerCase().contains("lose") ? "Weight loss speed per week" : "Weight gain speed per week",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            _speedLabel,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpeedIcon("Slow", Icons.timer_outlined, _speedValue < 0.5),
              _buildSpeedIcon("Recommended", Icons.bolt_outlined, _speedValue >= 0.5 && _speedValue < 1.5, isRecommended: true),
              _buildSpeedIcon("Fast", Icons.speed_outlined, _speedValue >= 1.5),
            ],
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Colors.black,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              overlayColor: Colors.black.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _speedValue,
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) => setState(() => _speedValue = value),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      const TextSpan(text: "You will reach your goal in "),
                      TextSpan(
                        text: _duration,
                        style: const TextStyle(color: Color(0xFFE6A071), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This is the most balanced pace, motivating and ideal for most users.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                Text(
                  "Daily calorie goal: 1,921 cal",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedIcon(String label, IconData icon, bool isSelected, {bool isRecommended = false}) {
    final color = isSelected ? (isRecommended ? const Color(0xFFE6A071) : Colors.black) : Colors.grey.shade400;
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
