import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';
import '../models/activity_model.dart';

class MealLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference? _logsCollection() {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('meal_logs');
  }

  CollectionReference? _activitiesCollection() {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('activity_logs');
  }

  DocumentReference? _dailyTrackingDoc(String dateKey) {
    if (_uid == null) return null;
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_tracking')
        .doc(dateKey);
  }

  CollectionReference? _myFoodsCollection() {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('my_foods');
  }

  // ─── MEAL LOGGING ──────────────────────────────

  /// Log a meal to Firestore
  Future<bool> logMeal(FoodModel food) async {
    try {
      final collection = _logsCollection();
      if (collection == null) return false;
      await collection.add(food.toMap());
      return true;
    } catch (e) {
      print("Firestore Error (logMeal): $e");
      return false;
    }
  }

  /// Delete a logged meal
  Future<bool> deleteMeal(String docId) async {
    try {
      final collection = _logsCollection();
      if (collection == null) return false;
      await collection.doc(docId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch all meal logs for today
  Future<List<FoodModel>> getTodayLogs() async {
    try {
      final collection = _logsCollection();
      if (collection == null) return [];

      final snapshot = await collection
          .where('dateKey', isEqualTo: _todayKey())
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Firestore Error (getTodayLogs): $e");
      return [];
    }
  }

  /// Get summed totals for today
  Future<Map<String, double>> getTodayTotals() async {
    final logs = await getTodayLogs();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final log in logs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFat += log.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  // ─── HISTORICAL DATA ──────────────────────────────

  /// Get logs for a date range (for charts)
  Future<Map<String, double>> getDailyCaloriesForRange(int days) async {
    try {
      final collection = _logsCollection();
      if (collection == null) return {};

      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));
      final startKey = _dateKey(start);

      final snapshot = await collection
          .where('dateKey', isGreaterThanOrEqualTo: startKey)
          .orderBy('dateKey')
          .get();

      final Map<String, double> dailyTotals = {};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final key = data['dateKey'] as String? ?? '';
        final cal = (data['calories'] ?? 0).toDouble();
        dailyTotals[key] = (dailyTotals[key] ?? 0) + cal;
      }

      return dailyTotals;
    } catch (e) {
      print("Firestore Error (getDailyCaloriesForRange): $e");
      return {};
    }
  }

  /// Get count of distinct days that have meal logs
  Future<int> getDaysLoggedCount() async {
    try {
      final collection = _logsCollection();
      if (collection == null) return 0;

      final snapshot = await collection.get();
      final Set<String> dateKeys = {};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final key = data['dateKey'] as String?;
        if (key != null) dateKeys.add(key);
      }
      return dateKeys.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get average daily calories over N days
  Future<double> getAverageCalories(int days) async {
    final dailyTotals = await getDailyCaloriesForRange(days);
    if (dailyTotals.isEmpty) return 0;
    final total = dailyTotals.values.fold(0.0, (currentSum, v) => currentSum + v);
    return total / dailyTotals.length;
  }

  // ─── ACTIVITY LOGGING ──────────────────────────────

  /// Log an exercise/activity
  Future<bool> logActivity(ActivityModel activity) async {
    try {
      final collection = _activitiesCollection();
      if (collection == null) return false;
      await collection.add(activity.toMap());
      return true;
    } catch (e) {
      print("Firestore Error (logActivity): $e");
      return false;
    }
  }

  /// Delete an activity
  Future<bool> deleteActivity(String docId) async {
    try {
      final collection = _activitiesCollection();
      if (collection == null) return false;
      await collection.doc(docId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get today's activities
  Future<List<ActivityModel>> getTodayActivities() async {
    try {
      final collection = _activitiesCollection();
      if (collection == null) return [];

      final snapshot = await collection
          .where('dateKey', isEqualTo: _todayKey())
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── WATER TRACKING ──────────────────────────────

  /// Get today's water intake in fl oz
  Future<double> getTodayWater() async {
    try {
      final doc = _dailyTrackingDoc(_todayKey());
      if (doc == null) return 0;
      final snapshot = await doc.get();
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>?;
      return (data?['waterOz'] ?? 0).toDouble();
    } catch (e) {
      print("Firestore Error (getTodayWater): $e");
      return 0;
    }
  }

  /// Update water intake for today (add or subtract 8oz)
  Future<bool> updateWater(double changeOz) async {
    try {
      final doc = _dailyTrackingDoc(_todayKey());
      if (doc == null) return false;
      await doc.set({
        'waterOz': FieldValue.increment(changeOz),
        'dateKey': _todayKey(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Firestore Error (updateWater): $e");
      return false;
    }
  }

  // ─── STEP TRACKING ──────────────────────────────

  /// Get today's step count
  Future<int> getTodaySteps() async {
    try {
      final doc = _dailyTrackingDoc(_todayKey());
      if (doc == null) return 0;
      final snapshot = await doc.get();
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>?;
      return (data?['steps'] ?? 0).toInt();
    } catch (e) {
      return 0;
    }
  }

  /// Update step count for today
  Future<bool> updateSteps(int steps) async {
    try {
      final doc = _dailyTrackingDoc(_todayKey());
      if (doc == null) return false;
      await doc.set({
        'steps': steps,
        'dateKey': _todayKey(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get daily steps for a range
  Future<Map<String, int>> getDailyStepsForRange(int days) async {
    try {
      if (_uid == null) return {};
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));
      final startKey = _dateKey(start);

      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('daily_tracking')
          .where('dateKey', isGreaterThanOrEqualTo: startKey)
          .orderBy('dateKey')
          .get();

      final Map<String, int> dailySteps = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final key = data['dateKey'] as String? ?? '';
        final steps = (data['steps'] ?? 0).toInt();
        dailySteps[key] = steps;
      }

      return dailySteps;
    } catch (e) {
      return {};
    }
  }

  /// Get average daily steps over N days
  Future<double> getAverageSteps(int days) async {
    final dailySteps = await getDailyStepsForRange(days);
    if (dailySteps.isEmpty) return 0;
    final total = dailySteps.values.fold(0, (sum, v) => sum + v);
    return total / dailySteps.length;
  }

  // ─── HELPERS ──────────────────────────────

  String _todayKey() {
    return _dateKey(DateTime.now());
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ─── MY FOODS ──────────────────────────────

  /// Save a food item to the user's permanent "My foods" library
  Future<bool> saveToMyFoods(FoodModel food) async {
    try {
      final collection = _myFoodsCollection();
      if (collection == null) return false;

      // Check for duplicates by name
      final existing = await collection
          .where('name', isEqualTo: food.name)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return true;

      await collection.add(food.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all items from the user's "My foods" library
  Future<List<FoodModel>> getMyFoods() async {
    try {
      final collection = _myFoodsCollection();
      if (collection == null) return [];

      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => FoodModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove a food item from "My foods"
  Future<bool> deleteFromMyFoods(String docId) async {
    try {
      final collection = _myFoodsCollection();
      if (collection == null) return false;
      await collection.doc(docId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
