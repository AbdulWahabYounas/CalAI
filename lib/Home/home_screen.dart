import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/meal_log_service.dart';
import '../models/food_model.dart';
import '../models/activity_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';
// Removed unused AnalyticsScreen import
import 'package:intl/intl.dart';
import '../screens/food_search_screen.dart';
import '../services/step_tracker_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../progress/progress_screen.dart';

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

  bool _permissionRequested = false;

  Future<void> _initStepTracking() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    try {
      final status = await Permission.activityRecognition.status;
      if (!status.isGranted) {
        final result = await Permission.activityRecognition.request();
        if (result.isGranted) {
          await StepTrackerService.start();
        }
      } else {
        await StepTrackerService.start();
      }
    } catch (e) {
      print("Error initializing step tracking: $e");
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

        if (doc.exists && mounted) {
          setState(() {
            _userPlan = doc.data();
            _isLoading = false;
          });
          return;
        }
      }
      // If user is null or doc doesn't exist, stop loading anyway
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchTodayData() async {
    try {
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
    } catch (e) {
      print("Error fetching today's data: $e");
      if (mounted) {
        setState(() => _isLoadingLogs = false);
      }
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
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const ProgressScreen(),
          const SettingsScreen(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.apple, color: Colors.black, size: 36),
            SizedBox(width: 8),
            Text(
              "Cal AI",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              SizedBox(width: 4),
              Text(
                "1",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? const Color(0xFFFFE5E5) : Colors.transparent,
                border: Border.all(
                  color: isToday ? const Color(0xFFFF4D4D) : Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                dayName,
                style: TextStyle(
                  color: isToday ? const Color(0xFFFF4D4D) : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isToday ? Colors.black : Colors.grey.shade400,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
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
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat('#,###').format(_currentSteps),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  " /${NumberFormat('#,###').format(_stepTarget)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            "Steps today",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade50),
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_walk, size: 28, color: Colors.black),
                ),
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
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 24, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                totalBurned.toStringAsFixed(0),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Text(
            "Calories burned",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          _buildBurnItem(Icons.directions_run, "Steps", "+${stepCals.toStringAsFixed(0)}"),
          const SizedBox(height: 16),
          if (_todayActivities.isNotEmpty)
            _buildBurnItem(Icons.fitness_center, _todayActivities.first.name, "+${_todayActivities.first.caloriesBurned.toStringAsFixed(0)}")
          else
            _buildBurnItem(Icons.fitness_center, "Weight lifting", "+50"),
        ],
      ),
    );
  }

  Widget _buildBurnItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard() {
    final cups = (_todayWater / 8).floor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_drink_outlined, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text("${_todayWater.toStringAsFixed(0)} fl oz ($cups cups)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () => _updateWater(-8),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.black, size: 28),
          ),
          IconButton(
            onPressed: () => _updateWater(8),
            icon: const Icon(Icons.add_circle, color: Colors.black, size: 32),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Icon(Icons.fitness_center, color: Colors.black, size: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activity.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    if (timeStr.isNotEmpty)
                      Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("${activity.caloriesBurned.toStringAsFixed(0)} calories", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Intensity: ${activity.intensity}", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${activity.durationMinutes} Mins", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5).withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            // Food Image placeholder
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        "${meal.calories.toStringAsFixed(0)} calories",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniMacroChip("🍗", "${meal.protein.toStringAsFixed(0)}g"),
                      const SizedBox(width: 6),
                      _buildMiniMacroChip("🍞", "${meal.carbs.toStringAsFixed(0)}g"),
                      const SizedBox(width: 6),
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
