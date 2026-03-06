import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import 'models/weight_entry.dart';
import 'widgets/progress_stat_card.dart';
import 'widgets/progress_chart.dart';
import 'widgets/progress_filter_tabs.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _progressService = ProgressService();
  String _selectedFilter = "90 Days";
  
  // Cache data
  List<WeightEntry> _allWeightEntries = [];
  double? _latestWeight;
  double? _targetWeight;
  int _daysLogged = 0;
  double _goalPercent = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _progressService.getWeightHistory();
      final latest = await _progressService.getLatestWeight();
      final target = await _progressService.getTargetWeight();
      final days = await _progressService.getDaysLogged();
      final percent = await _progressService.getGoalProgressPercent();

      if (mounted) {
        setState(() {
          _allWeightEntries = entries;
          _latestWeight = latest;
          _targetWeight = target;
          _daysLogged = days;
          _goalPercent = percent;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading progress data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<WeightEntry> _getFilteredEntries() {
    final now = DateTime.now();
    DateTime threshold;

    switch (_selectedFilter) {
      case "90 Days":
        threshold = now.subtract(const Duration(days: 90));
        break;
      case "6 Months":
        threshold = now.subtract(const Duration(days: 180));
        break;
      case "1 Year":
        threshold = now.subtract(const Duration(days: 365));
        break;
      default:
        return _allWeightEntries;
    }

    return _allWeightEntries.where((e) => e.date.isAfter(threshold)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ProgressStatCard(
                              title: "Last weight",
                              value: "${_latestWeight?.toStringAsFixed(0) ?? '---'} lbs",
                              percent: _goalPercent,
                              icon: Icons.scale_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProgressStatCard(
                              title: "Days logged",
                              value: "$_daysLogged logged",
                              percent: (_daysLogged / 30).clamp(0.0, 1.0),
                              icon: Icons.apple,
                              color: Colors.blue,
                              badge: "2 Cheat",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ProgressFilterTabs(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (filter) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ProgressChart(
                              entries: _getFilteredEntries(),
                              selectedFilter: _selectedFilter,
                              goalPercent: _goalPercent,
                              targetWeight: _targetWeight,
                            ),
                            const SizedBox(height: 24),
                            _buildMotivationalText(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildMotivationalText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "Great job! Consistency is key, and you're mastering it!",
        style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
