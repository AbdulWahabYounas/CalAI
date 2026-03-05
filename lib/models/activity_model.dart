import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? docId;
  final String name;
  final double caloriesBurned;
  final int durationMinutes;
  final String intensity; // Light, Medium, Hard
  final DateTime? loggedAt;

  ActivityModel({
    this.docId,
    required this.name,
    required this.caloriesBurned,
    required this.durationMinutes,
    this.intensity = 'Medium',
    this.loggedAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      docId: doc.id,
      name: data['name'] ?? 'Unknown',
      caloriesBurned: (data['caloriesBurned'] ?? 0).toDouble(),
      durationMinutes: (data['durationMinutes'] ?? 0).toInt(),
      intensity: data['intensity'] ?? 'Medium',
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'caloriesBurned': caloriesBurned,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'loggedAt': FieldValue.serverTimestamp(),
      'dateKey': _todayKey(),
    };
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
