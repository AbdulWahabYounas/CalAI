import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'target_weight.dart';
import '../controllers/onboarding_controller.dart';

class CurrentWeightPage extends StatefulWidget {
  final String goal;
  final bool isImperial;

  const CurrentWeightPage({
    super.key,
    required this.goal,
    required this.isImperial,
  });

  @override
  State<CurrentWeightPage> createState() => _CurrentWeightPageState();
}

class _CurrentWeightPageState extends State<CurrentWeightPage> {
  late bool _isImperial;
  late int _selectedLbs;
  late int _selectedKg;

  @override
  void initState() {
    super.initState();
    _isImperial = widget.isImperial;
    _selectedLbs = 150;
    _selectedKg = 68;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "What is your current weight?",
      subtitle: "This is the starting point of your journey.",
      progress: 0.36,
      isContinueEnabled: true,
      onContinue: () {
        double currentWeight = _isImperial ? _selectedLbs.toDouble() : _selectedKg.toDouble();
        final controller = Get.find<OnboardingController>();
        controller.currentWeight.value = currentWeight;
        controller.isImperialWeight.value = _isImperial;
        
        Get.to(() => TargetWeightPage(
          goal: widget.goal,
          currentWeight: currentWeight,
          isImperial: _isImperial,
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
