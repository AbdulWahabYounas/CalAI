import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/meal_log_service.dart';
import '../models/food_model.dart';
import '../models/activity_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';
import '../screens/food_search_screen.dart';
import '../services/step_tracker_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userPlan;
  bool _isLoading = true;

  // Calorie tracking state
  final MealLogService _mealLogService = MealLogService();
  Map<String, double> _todayTotals = {
    'calories': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  List<FoodModel> _todayLogs = [];
  List<ActivityModel> _todayActivities = [];
  double _todayWater = 0;
  int _currentSteps = 0;
  final int _stepTarget = 10000;
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPlan();
    _fetchTodayData();
    _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    if (await Permission.activityRecognition.request().isGranted) {
      await StepTrackerService.start();
    }
  }

  Future<void> _fetchUserPlan() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('plan')
            .doc('current_plan')
            .get();

        if (doc.exists) {
          setState(() {
            _userPlan = doc.data();
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTodayData() async {
    setState(() => _isLoadingLogs = true);
    final totals = await _mealLogService.getTodayTotals();
    final logs = await _mealLogService.getTodayLogs();
    final activities = await _mealLogService.getTodayActivities();
    final water = await _mealLogService.getTodayWater();
    final steps = await _mealLogService.getTodaySteps();

    if (mounted) {
      setState(() {
        _todayTotals = totals;
        _todayLogs = logs;
        _todayActivities = activities;
        _todayWater = water;
        _currentSteps = steps;
        _isLoadingLogs = false;
      });
    }
  }

  Future<void> _updateWater(double delta) async {
    final success = await _mealLogService.updateWater(delta);
    if (success) {
      _fetchTodayData();
    }
  }

  Future<void> _updateSteps(int delta) async {
    final newSteps = (_currentSteps + delta).clamp(0, 50000);
    final success = await _mealLogService.updateSteps(newSteps);
    if (success) {
      _fetchTodayData();
    }
  }

  Future<void> _deleteMeal(FoodModel meal) async {
    if (meal.docId == null) return;
    final success = await _mealLogService.deleteMeal(meal.docId!);
    if (success && mounted) {
      _fetchTodayData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meal.name} removed'),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // Navigate to food search and refresh on return
  Future<void> _openFoodSearch() async {
    final result = await Get.to(() => const FoodSearchScreen());
    if (result == true) {
      _fetchTodayData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex == 1 ? 1 : (_currentIndex == 2 ? 0 : 0),
        children: [
          _currentIndex == 1 ? const AnalyticsScreen() : _buildHomeTab(),
          _currentIndex == 2 ? const SettingsScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFoodSearch,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildHorizontalCalendar(),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildActivityRow(),
              const SizedBox(height: 24),
              _buildWaterCard(),
              const SizedBox(height: 32),
              const Text(
                "Recently logged",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRecentlyLoggedSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final consumed = _todayTotals['calories'] ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.apple, color: Colors.black, size: 32),
            SizedBox(width: 8),
            Text(
              "Cal AI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                consumed.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = date.day == now.day && date.month == now.month;
        final dayName = DateFormat('E').format(date).substring(0, 1);

        return Column(
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: Colors.black, style: BorderStyle.solid, width: 1.5)
                    : Border.all(color: Colors.grey.shade200, style: BorderStyle.none),
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isToday ? Colors.black : Colors.grey.shade400,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActivityRow() {
    return Row(
      children: [
        Expanded(child: _buildStepsCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildCaloriesBurnedCard()),
      ],
    );
  }

  Widget _buildStepsCard() {
    final progress = (_currentSteps / _stepTarget).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    NumberFormat('#,###').format(_currentSteps),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    " /${NumberFormat('#,###').format(_stepTarget)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "Steps today",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100),
                  ),
                ),
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Icon(Icons.directions_walk, size: 24, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesBurnedCard() {
    final stepCals = _currentSteps * 0.04;
    final activityCals = _todayActivities.fold(0.0, (sum, a) => sum + a.caloriesBurned);
    final totalBurned = stepCals + activityCals;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 20),
              const SizedBox(width: 4),
              Text(
                totalBurned.toStringAsFixed(0),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            "Calories burned",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          _buildBurnItem(Icons.directions_run, "Steps", "+${stepCals.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          if (_todayActivities.isNotEmpty)
            _buildBurnItem(Icons.fitness_center, _todayActivities.first.name, "+${_todayActivities.first.caloriesBurned.toStringAsFixed(0)}")
          else
            _buildBurnItem(Icons.fitness_center, "Weight lifting", "+0"),
        ],
      ),
    );
  }

  Widget _buildBurnItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard() {
    final cups = (_todayWater / 8).floor();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_drink_outlined, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Water", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                Text("${_todayWater.toStringAsFixed(0)} fl oz ($cups cups)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _updateWater(-8),
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.grey,
          ),
          IconButton(
            onPressed: () => _updateWater(8),
            icon: const Icon(Icons.add_circle),
            color: Colors.black,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyLoggedSection() {
    if (_isLoadingLogs) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Column(
      children: [
        ..._todayLogs.map((meal) => _buildLoggedMealCard(meal)),
        ..._todayActivities.map((activity) => _buildLoggedActivityCard(activity)),
      ],
    );
  }

  Widget _buildLoggedActivityCard(ActivityModel activity) {
    final timeStr = activity.loggedAt != null ? DateFormat('h:mm a').format(activity.loggedAt!) : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Icon(Icons.fitness_center, color: Colors.black, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text("${activity.caloriesBurned.toStringAsFixed(0)} calories", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 10, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text("Intensity: ${activity.intensity}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.timer_outlined, size: 10, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text("${activity.durationMinutes} Mins", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          if (timeStr.isNotEmpty)
            Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLoggedMealCard(FoodModel meal) {
    final timeStr = meal.loggedAt != null ? DateFormat('h:mm a').format(meal.loggedAt!) : '';

    return Dismissible(
      key: Key(meal.docId ?? meal.name + meal.calories.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteMeal(meal),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Food Image placeholder
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=200&auto=format&fit=crop"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Food info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        "${meal.calories.toStringAsFixed(0)} calories",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniMacroChip("🍗", "${meal.protein.toStringAsFixed(0)}g"),
                      const SizedBox(width: 4),
                      _buildMiniMacroChip("🍞", "${meal.carbs.toStringAsFixed(0)}g"),
                      const SizedBox(width: 4),
                      _buildMiniMacroChip("💧", "${meal.fat.toStringAsFixed(0)}g"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacroChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavBarItem(Icons.home_filled, "Home", 0),
          _buildNavBarItem(Icons.bar_chart_outlined, "Progress", 1),
          _buildNavBarItem(Icons.settings_outlined, "Settings", 2),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.black : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
