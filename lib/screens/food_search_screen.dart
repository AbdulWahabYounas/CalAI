import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/usda_service.dart';
import '../services/meal_log_service.dart';
import '../Home/food_detail_screen.dart';
import 'package:get/get.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UsdaService _usdaService = UsdaService();
  final MealLogService _mealLogService = MealLogService();

  List<FoodModel> _results = [];
  List<FoodModel> _myFoods = [];
  String _activeTab = 'All';
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _mealWasLogged = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchMyFoods();
    _fetchInitialSuggestions();
  }

  Future<void> _fetchInitialSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final results = await _usdaService.searchFood("Chicken");
      if (mounted) {
        setState(() {
          _results = results.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEmptyLogDialog() async {
    final nameController = TextEditingController();
    final calController = TextEditingController();

    return Get.dialog(
      AlertDialog(
        title: const Text("Log Manual Entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Food Name"),
            ),
            TextField(
              controller: calController,
              decoration: const InputDecoration(labelText: "Calories"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || calController.text.isEmpty) return;
              final food = FoodModel(
                name: nameController.text,
                calories: double.tryParse(calController.text) ?? 0,
                protein: 0,
                carbs: 0,
                fat: 0,
              );
              final success = await _mealLogService.logMeal(food);
              Get.back();
              if (success) {
                setState(() => _mealWasLogged = true);
                Get.snackbar("Logged", "${food.name} added to your log");
              }
            },
            child: const Text("Log"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchMyFoods() async {
    final foods = await _mealLogService.getMyFoods();
    if (mounted) {
      setState(() {
        _myFoods = foods;
      });
    }
  }

  Future<void> _saveToMyFoods(FoodModel food) async {
    final success = await _mealLogService.saveToMyFoods(food);
    if (success) {
      _fetchMyFoods();
      Get.snackbar(
        "Saved",
        "${food.name} added to My foods",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query.trim());
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _usdaService.searchFood(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to fetch food data. Please try again.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _openFoodDetail(FoodModel food) async {
    final result = await Get.to(() => FoodDetailScreen(food: food));
    if (result == true) {
      if (mounted) {
        setState(() {
          _mealWasLogged = true;
        });
        // Success snackbar is already shown in the detail screen via Get
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _mealWasLogged) {
          // Refresh logic if needed
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _mealWasLogged),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
            ),
          ),
          title: const Text(
            'Food Database',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (value) => _performSearch(value.trim()),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Describe what you ate',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _buildTab('All', _activeTab == 'All'),
                  _buildTab('My meals', _activeTab == 'My meals'),
                  _buildTab('My foods', _activeTab == 'My foods'),
                  _buildTab('Saved scans', _activeTab == 'Saved scans'),
                ],
              ),
            ),

            // Log empty food button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _showEmptyLogDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Log empty food',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Suggestions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : _activeTab == 'My foods'
                      ? _myFoods.isEmpty
                          ? const Center(child: Text("No saved foods yet"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _myFoods.length,
                              itemBuilder: (context, index) {
                                return _buildFoodListItem(_myFoods[index], isFromMyFoods: true);
                              },
                            )
                      : _results.isEmpty && _hasSearched
                          ? const Center(child: Text("No results found"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                return _buildFoodListItem(_results[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = text;
          });
          if (text == 'My foods') _fetchMyFoods();
        },
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodListItem(FoodModel food, {bool isFromMyFoods = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _openFoodDetail(food),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${food.calories.toStringAsFixed(0)} cal',
                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const Text(' · ', style: TextStyle(color: Colors.grey)),
                        const Text(
                          'serving',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isFromMyFoods 
                    ? () => _openFoodDetail(food) // Instant log from details or similar
                    : () => _saveToMyFoods(food),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFromMyFoods ? Icons.add_task : Icons.add, 
                    size: 20, 
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
