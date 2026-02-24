import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'birth_date.dart';
import '../controllers/onboarding_controller.dart';

class HeightSelectionPage extends StatefulWidget {
  const HeightSelectionPage({super.key});

  @override
  State<HeightSelectionPage> createState() => _HeightSelectionPageState();
}

class _HeightSelectionPageState extends State<HeightSelectionPage> {
  bool _isImperial = true;

  int _selectedFeet = 5;
  int _selectedInches = 6;
  int _selectedCm = 170;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "How tall are you?",
      subtitle: "This will be used to calibrate your custom plan.",
      progress: 0.08,
      isContinueEnabled: true,
      onContinue: () {
        final controller = Get.find<OnboardingController>();
        controller.isImperialHeight.value = _isImperial;
        controller.heightFeet.value = _selectedFeet;
        controller.heightInches.value = _selectedInches;
        controller.heightCm.value = _selectedCm;
        Get.to(() => BirthDatePage(isImperial: _isImperial));
      },
      child: Column(
        children: [
          _buildUnitToggle(),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 200,
              child: _buildHeightPicker(),
            ),
          ),
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

  Widget _buildHeightPicker() {
    return Column(
      children: [
        const Text(
          "Height",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _isImperial ? _buildImperialHeightPicker() : _buildMetricHeightPicker(),
        ),
      ],
    );
  }

  Widget _buildMetricHeightPicker() {
    final cmValues = List.generate(151, (index) => 100 + index);
    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(initialItem: cmValues.indexOf(_selectedCm)),
      onSelectedItemChanged: (index) => setState(() => _selectedCm = cmValues[index]),
      children: cmValues.map((cm) => Center(
        child: Text("$cm cm", style: const TextStyle(fontSize: 20, color: Colors.black)),
      )).toList(),
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.grey.shade100.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildImperialHeightPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: _selectedFeet - 1),
            onSelectedItemChanged: (index) => setState(() => _selectedFeet = index + 1),
            children: List.generate(8, (index) => index + 1).map((ft) => Center(
              child: Text("$ft ft", style: const TextStyle(fontSize: 20)),
            )).toList(),
            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: false, capEndEdge: false),
          ),
        ),
        Expanded(
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: _selectedInches),
            onSelectedItemChanged: (index) => setState(() => _selectedInches = index),
            children: List.generate(12, (index) => index).map((inch) => Center(
              child: Text("$inch in", style: const TextStyle(fontSize: 20)),
            )).toList(),
            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: false, capEndEdge: false),
          ),
        ),
      ],
    );
  }
}
