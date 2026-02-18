import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'target_projection.dart';

class TargetWeightPage extends StatefulWidget {
  final String goal; // "Lose weight" or "Gain weight"
  final double currentWeight;
  final bool isImperial;

  const TargetWeightPage({
    super.key,
    required this.goal,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<TargetWeightPage> createState() => _TargetWeightPageState();
}

class _TargetWeightPageState extends State<TargetWeightPage> {
  late bool _isImperial;
  late int _selectedLbs;
  late int _selectedKg;

  @override
  void initState() {
    super.initState();
    _isImperial = widget.isImperial;
    _selectedLbs = _isImperial ? widget.currentWeight.round() : 140;
    _selectedKg = !_isImperial ? widget.currentWeight.round() : 65;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "What is your target weight?",
      subtitle: "This helps us calculate the duration to reach your goal.",
      isContinueEnabled: true,
      onContinue: () {
        double targetWeight = _isImperial ? _selectedLbs.toDouble() : _selectedKg.toDouble();
        Get.to(() => TargetProjectionPage(
          goal: widget.goal,
          targetWeight: targetWeight.toString(),
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
        ));
      },
      child: Column(
        children: [
          _buildUnitToggle(),
          const SizedBox(height: 60),
          _buildWeightPicker(),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isImperial = true),
          child: Text(
            "Imperial",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isImperial ? Colors.black : Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: !_isImperial,
            onChanged: (value) => setState(() => _isImperial = !value),
            activeColor: Colors.black,
            activeTrackColor: Colors.grey.shade300,
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: Colors.grey.shade300,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() => _isImperial = false),
          child: Text(
            "Metric",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: !_isImperial ? Colors.black : Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightPicker() {
    return SizedBox(
      height: 250,
      child: _isImperial ? _buildLbsPicker() : _buildKgPicker(),
    );
  }

  Widget _buildLbsPicker() {
    final lbsValues = List.generate(451, (index) => 50 + index);
    return CupertinoPicker(
      itemExtent: 50,
      scrollController: FixedExtentScrollController(initialItem: lbsValues.indexOf(_selectedLbs)),
      onSelectedItemChanged: (index) => setState(() => _selectedLbs = lbsValues[index]),
      children: lbsValues.map((lb) => Center(
        child: Text("$lb lb", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      )).toList(),
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 2),
            bottom: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildKgPicker() {
    final kgValues = List.generate(231, (index) => 20 + index);
    return CupertinoPicker(
      itemExtent: 50,
      scrollController: FixedExtentScrollController(initialItem: kgValues.indexOf(_selectedKg)),
      onSelectedItemChanged: (index) => setState(() => _selectedKg = kgValues[index]),
      children: kgValues.map((kg) => Center(
        child: Text("$kg kg", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      )).toList(),
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 2),
            bottom: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
        ),
      ),
    );
  }
}
