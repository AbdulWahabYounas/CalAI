import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'workout_frequency.dart';

class BirthDatePage extends StatefulWidget {
  final double currentWeight;
  final bool isImperial;

  const BirthDatePage({
    super.key,
    required this.currentWeight,
    required this.isImperial,
  });

  @override
  State<BirthDatePage> createState() => _BirthDatePageState();
}

class _BirthDatePageState extends State<BirthDatePage> {
  DateTime _selectedDate = DateTime(2000, 1, 1);

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "When were you born?",
      subtitle: "This will be used to calibrate your custom plan.",
      isContinueEnabled: true,
      onContinue: () {
        Get.to(() => WorkoutFrequencyPage(
          currentWeight: widget.currentWeight,
          isImperial: widget.isImperial,
        ));
      },
      child: SizedBox(
        height: 250,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _selectedDate,
          maximumDate: DateTime.now(),
          minimumDate: DateTime(1900),
          onDateTimeChanged: (DateTime newDate) {
            setState(() {
              _selectedDate = newDate;
            });
          },
        ),
      ),
    );
  }
}
