import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/food_model.dart';
import '../services/meal_log_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final MealLogService _mealLogService = MealLogService();
  double _servings = 1.0;
  bool _isLogging = false;

  late FoodModel _currentFood;

  @override
  void initState() {
    super.initState();
    _currentFood = widget.food;
  }

  void _updateServings(double newServings) {
    if (newServings < 0.1) return;
    setState(() {
      _servings = newServings;
    });
  }

  Future<void> _logMeal() async {
    setState(() => _isLogging = true);
    
    // Create copy with adjusted macros based on servings
    final loggedFood = FoodModel(
      name: _currentFood.name,
      calories: _currentFood.calories * _servings,
      protein: _currentFood.protein * _servings,
      carbs: _currentFood.carbs * _servings,
      fat: _currentFood.fat * _servings,
      servings: _servings.round(),
    );

    final success = await _mealLogService.logMeal(loggedFood);
    
    if (mounted) {
      setState(() => _isLogging = false);
      if (success) {
        Get.back(result: true);
        Get.snackbar(
          "Success",
          "${_currentFood.name} logged!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
        );
      } else {
        Get.snackbar("Error", "Failed to log meal");
      }
    }
  }

  int _calculateHealthScore() {
    // Simple logic: higher protein % usually better in this context
    double totalMacros = _currentFood.protein + _currentFood.carbs + _currentFood.fat;
    if (totalMacros == 0) return 5;
    double proteinRatio = _currentFood.protein / totalMacros;
    if (proteinRatio > 0.3) return 9;
    if (proteinRatio > 0.15) return 7;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = _calculateHealthScore();
    final timeStr = DateFormat('h:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1467003909585-2f8a72700288?q=80&w=800&auto=format&fit=crop"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(Icons.arrow_back_ios_new, () => Get.back()),
                        Row(
                          children: [
                            _buildCircleButton(Icons.ios_share, () {}),
                            const SizedBox(width: 12),
                            _buildCircleButton(Icons.more_horiz, () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Nutrition",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeStr,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentFood.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _servings.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit_outlined, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Calorie Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.black, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Calories", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(
                              (_currentFood.calories * _servings).toStringAsFixed(0),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Macros Row
                  Row(
                    children: [
                      _buildMacroCard("Protein", "${(_currentFood.protein * _servings).toStringAsFixed(0)}g", Colors.red.shade400, "🍗"),
                      const SizedBox(width: 12),
                      _buildMacroCard("Carbs", "${(_currentFood.carbs * _servings).toStringAsFixed(0)}g", Colors.orange.shade400, "🍞"),
                      const SizedBox(width: 12),
                      _buildMacroCard("Fats", "${(_currentFood.fat * _servings).toStringAsFixed(0)}g", Colors.blue.shade400, "💧"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Health Score
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.pink.shade50, shape: BoxShape.circle),
                                  child: Icon(Icons.favorite, color: Colors.pink.shade300, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text("Health Score", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Text("$healthScore/10", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: healthScore / 10,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildIngredientItem("Chicken Breast"),
                  _buildIngredientItem("Avocado"),
                  _buildIngredientItem("Whole Grain Bread"),
                  _buildIngredientItem("Eggs"),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Fix Results", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLogging ? null : _logMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLogging
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
