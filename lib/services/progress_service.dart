import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../progress/models/weight_entry.dart';
import 'meal_log_service.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MealLogService _mealLogService = MealLogService();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<List<WeightEntry>> getWeightHistory() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('weight_logs')
          .orderBy('date', descending: false)
          .get();

      List<WeightEntry> history = snapshot.docs.map((doc) {
        final data = doc.data();
        return WeightEntry(
          date: data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.now(),
          weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      if (history.isEmpty) {
        // Fallback: If no logs yet, show starting weight from plan as the first point
        final target = await getTargetWeight();
        final current = await getLatestWeight();
        if (current != null) {
          // Add a point for a few days ago and today to make a line
          return [
            WeightEntry(date: DateTime.now().subtract(const Duration(days: 7)), weight: current),
            WeightEntry(date: DateTime.now(), weight: current),
          ];
        }
      }
      return history;
    } catch (e) {
      print("Error fetching weight history: $e");
      return [];
    }
  }

  Future<double?> getTargetWeight() async {
    if (_uid == null) return null;
    final doc = await _firestore.collection('users').doc(_uid).collection('plan').doc('current_plan').get();
    if (doc.exists) {
      final data = doc.data();
      return (data?['goals']?['targetWeight'] as num?)?.toDouble();
    }
    return null;
  }

  Future<double?> getLatestWeight() async {
    // Try to get latest from logs first
    if (_uid != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('weight_logs')
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return (snapshot.docs.first.data()['weight'] as num?)?.toDouble();
      }
    }
    
    // Fallback to plan data
    if (_uid == null) return null;
    final doc = await _firestore.collection('users').doc(_uid).collection('plan').doc('current_plan').get();
    if (doc.exists) {
      final data = doc.data();
      return (data?['goals']?['currentWeight'] as num?)?.toDouble();
    }
    return null;
  }

  Future<int> getDaysLogged() async {
    return await _mealLogService.getDaysLoggedCount();
  }

  Future<double> getGoalProgressPercent() async {
    if (_uid == null) return 0.0;
    try {
      final planDoc = await _firestore.collection('users').doc(_uid).collection('plan').doc('current_plan').get();
      if (!planDoc.exists) return 0.0;

      final planData = planDoc.data();
      final startWeight = (planData?['goals']?['currentWeight'] as num?)?.toDouble() ?? 0.0;
      final targetWeight = (planData?['goals']?['targetWeight'] as num?)?.toDouble() ?? 0.0;
      final latestWeight = await getLatestWeight() ?? startWeight;

      if (startWeight == targetWeight) return 1.0;

      // Calculation: How far are we from start towards target?
      double progress = (latestWeight - startWeight) / (targetWeight - startWeight);
      return progress.clamp(0.0, 1.0);
    } catch (e) {
      print("Error calculating goal progress: $e");
      return 0.0;
    }
  }
}
