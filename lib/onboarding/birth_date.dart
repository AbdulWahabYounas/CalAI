import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'workout_frequency.dart';
import '../controllers/onboarding_controller.dart';

class BirthDatePage extends StatefulWidget {
  final bool isImperial;

  const BirthDatePage({
    super.key,
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
      progress: 0.12,
      isContinueEnabled: true,
      onContinue: () {
        final controller = Get.find<OnboardingController>();
        controller.birthDate.value = _selectedDate;
        Get.to(() => WorkoutFrequencyPage(
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
