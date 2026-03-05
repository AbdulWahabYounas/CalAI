import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String? docId;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int servings;
  final DateTime? loggedAt;

  FoodModel({
    this.docId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.servings = 1,
    this.loggedAt,
  });

  /// Estimated steps needed to burn this food's calories (~0.04 kcal/step)
  int get stepsEquivalent => (calories / 0.04).round();

  /// Estimated walking minutes to burn calories (~5 kcal/min walking)
  int get walkingMinutes => (calories / 5).round();

  factory FoodModel.fromUsdaJson(Map<String, dynamic> food) {
    final String foodName = food['description'] ?? 'Unknown Food';
    final List<dynamic> nutrients = food['foodNutrients'] ?? [];

    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    for (final nutrient in nutrients) {
      final dynamic id = nutrient['nutrientId'] ?? nutrient['attr_id'];
      final String nutrientName = (nutrient['nutrientName'] ?? '').toString().toLowerCase();
      final double value = (nutrient['value'] ?? 0).toDouble();

      // IDs for USDA FDC: Energy=1008, Protein=1003, Lipid=1004, Carbs=1005
      if (id == 1008 || nutrientName.contains('energy') || nutrientName.contains('kcal')) {
        // Some records have both kJ and kcal. Usually Energy (1008) is kcal.
        if (nutrient['unitName'] == 'KCAL' || !nutrientName.contains('kj')) {
             calories = value;
        }
      } else if (id == 1003 || nutrientName == 'protein') {
        protein = value;
      } else if (id == 1005 || nutrientName.contains('carbohydrate')) {
        carbs = value;
      } else if (id == 1004 || nutrientName.contains('fat') || nutrientName.contains('lipid')) {
        fat = value;
      }
    }

    return FoodModel(
      name: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  factory FoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodModel(
      docId: doc.id,
      name: data['name'] ?? 'Unknown',
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      servings: (data['servings'] ?? 1).toInt(),
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servings': servings,
      'loggedAt': FieldValue.serverTimestamp(),
      'dateKey': _todayKey(),
    };
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
