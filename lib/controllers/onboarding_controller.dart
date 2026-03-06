import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingController extends GetxController {
  // Personal Info
  var gender = "".obs;
  var birthDate = Rxn<DateTime>();
  var heightFeet = 5.obs;
  var heightInches = 6.obs;
  var heightCm = 170.obs;
  var isImperialHeight = true.obs;

  // Weight & Goals
  var goal = "Lose weight".obs;
  var currentWeight = 0.0.obs;
  var targetWeight = 0.0.obs;
  var isImperialWeight = true.obs;
  var speed = 1.0.obs; // lbs per week recommended

  // Lifestyle & Preferences
  var workoutFrequency = "3-4 times a week".obs;
  var diet = "Classic".obs;
  var barrier = "".obs;
  var source = "".obs;
  var experience = "".obs;
  var coach = "".obs;

  // Calculators
  int get dailyCalories {
    int base = 2000;
    if (goal.value.contains("Lose")) {
      return base - (speed.value * 500).round();
    } else if (goal.value.contains("Gain")) {
      return base + (speed.value * 500).round();
    }
    return base;
  }

  Map<String, int> get macros {
    final cals = dailyCalories;
    return {
      'carbs': (cals * 0.4 / 4).round(),
      'protein': (cals * 0.35 / 4).round(),
      'fats': (cals * 0.25 / 9).round(),
    };
  }

  String get achievementDate {
    if (goal.value == "Maintain") return "Today";
    
    double diff = (currentWeight.value - targetWeight.value).abs();
    if (speed.value == 0) return "TBD";
    int weeks = (diff / speed.value).ceil();
    
    DateTime targetDate = DateTime.now().add(Duration(days: weeks * 7));
    return "${_getMonthName(targetDate.month)} ${targetDate.day}, ${targetDate.year}";
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Future<void> savePlanToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plan')
          .doc('current_plan')
          .set({
        'personalInfo': {
          'gender': gender.value,
          'birthDate': birthDate.value?.toIso8601String(),
          'height': {
            'feet': heightFeet.value,
            'inches': heightInches.value,
            'cm': heightCm.value,
            'isImperial': isImperialHeight.value,
          },
        },
        'goals': {
          'goal': goal.value,
          'currentWeight': currentWeight.value,
          'targetWeight': targetWeight.value,
          'isImperial': isImperialWeight.value,
          'speed': speed.value,
        },
        'lifestyle': {
          'workoutFrequency': workoutFrequency.value,
          'diet': diet.value,
          'barrier': barrier.value,
          'source': source.value,
          'experience': experience.value,
          'coach': coach.value,
        },
        'planDetails': {
          'dailyCalories': dailyCalories,
          'macros': macros,
          'achievementDate': achievementDate,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firestore Error (savePlanToFirestore): $e");
      rethrow;
    }
  }
}
