import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'birth_date.dart';

class HeightWeightPage extends StatefulWidget {
  const HeightWeightPage({super.key});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage> {
  bool _isImperial = true; // true for Imperial (ft/in, lb), false for Metric (cm, kg)

  // Height values
  int _selectedFeet = 5;
  int _selectedInches = 6;
  int _selectedCm = 170;

  // Weight values
  int _selectedLbs = 140;
  int _selectedKg = 65;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Height & weight",
      subtitle: "This will be used to calibrate your custom plan.",
      isContinueEnabled: true, // Always enabled as we have default values
      onContinue: () {
        double currentWeight = _isImperial ? _selectedLbs.toDouble() : _selectedKg.toDouble();
        Get.to(() => BirthDatePage(currentWeight: currentWeight, isImperial: _isImperial));
      },
      child: Column(
        children: [
          _buildUnitToggle(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildHeightPicker()),
              Expanded(child: _buildWeightPicker()),
            ],
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
            activeColor: Colors.black, // Color when Metric (true)
            activeTrackColor: Colors.grey.shade300,
            inactiveThumbColor: Colors.black, // Color when Imperial (false)
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
          height: 200, // Fixed height for picker
          child: _isImperial ? _buildImperialHeightPicker() : _buildMetricHeightPicker(),
        ),
      ],
    );
  }

  Widget _buildMetricHeightPicker() {
     // Range: 100cm to 250cm
    final cmValues = List.generate(151, (index) => 100 + index);

    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(initialItem: cmValues.indexOf(_selectedCm)),
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedCm = cmValues[index];
        });
      },
      children: cmValues.map((cm) => Center(
        child: Text(
          "$cm cm",
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      )).toList(),
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.grey.shade100.withOpacity(0.3),
           borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }

  Widget _buildImperialHeightPicker() {
      // Using two pickers for Ft and In is complex in a single column slot if they need to scroll independently.
      // A common way is to have them side-by-side or fused.
      // Let's scroll as a fused string "5 ft 6 in"? No, usually they are separate wheels.
      // But here we are in a column "Height". The design shows them stacked or side by side?
      // Design shows "5 ft" selected and NEXT to it "6 in" selected.
      // Since Height and Weight are side-by-side columns, inside the "Height" column we need two wheels?
      // Or maybe the design is Height column and Weight column are separate.
      // Let's look at the design again.
      // Imperial: Height (ft | in)   Weight (lb)
      // So Height has 2 sub-columns.
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: _selectedFeet - 1), // 1 to 8 ft
              onSelectedItemChanged: (index) {
                setState(() => _selectedFeet = index + 1);
              },
              children: List.generate(8, (index) => index + 1).map((ft) => Center(
                child: Text("$ft ft", style: const TextStyle(fontSize: 20)),
              )).toList(),
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: false, capEndEdge: false),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: _selectedInches), // 0 to 11 in
              onSelectedItemChanged: (index) {
                setState(() => _selectedInches = index);
              },
              children: List.generate(12, (index) => index).map((inch) => Center(
                child: Text("$inch in", style: const TextStyle(fontSize: 20)),
              )).toList(),
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: false, capEndEdge: false),
            ),
          ),
        ],
      );
  }


  Widget _buildWeightPicker() {
    return Column(
      children: [
        const Text(
          "Weight",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _isImperial ? _buildLbsPicker() : _buildKgPicker(),
        ),
      ],
    );
  }

  Widget _buildLbsPicker() {
    // Range 50 to 500 lbs
    final lbsValues = List.generate(451, (index) => 50 + index);
    
    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(initialItem: lbsValues.indexOf(_selectedLbs)),
      onSelectedItemChanged: (index) {
        setState(() => _selectedLbs = lbsValues[index]);
      },
      children: lbsValues.map((lb) => Center(
        child: Text("$lb lb", style: const TextStyle(fontSize: 20)),
      )).toList(),
       selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.grey.shade100.withOpacity(0.3),
           borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }

  Widget _buildKgPicker() {
    // Range 20 to 250 kg
    final kgValues = List.generate(231, (index) => 20 + index);

    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(initialItem: kgValues.indexOf(_selectedKg)),
      onSelectedItemChanged: (index) {
        setState(() => _selectedKg = kgValues[index]);
      },
      children: kgValues.map((kg) => Center(
        child: Text("$kg kg", style: const TextStyle(fontSize: 20)),
      )).toList(),
       selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.grey.shade100.withOpacity(0.3),
           borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }
}
