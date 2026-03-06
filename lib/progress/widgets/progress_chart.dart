import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_entry.dart';

class ProgressChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final String selectedFilter;
  final double goalPercent;
  final double? targetWeight;

  const ProgressChart({
    super.key,
    required this.entries,
    required this.selectedFilter,
    this.goalPercent = 0.0,
    this.targetWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text("No data available for this range"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Weight History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildGoalDoneBadge(),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => const Color(0xFF1E1E1E).withOpacity(0.9),
                  tooltipRoundedRadius: 12,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final entry = entries[spot.x.toInt()];
                      return LineTooltipItem(
                        '${entry.weight.toStringAsFixed(1)} kg\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        children: [
                          TextSpan(
                            text: DateFormat('d MMM yyyy').format(entry.date),
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.normal, fontSize: 10),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade100,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _getInterval(),
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        final date = entries[index].date;
                        String label;
                        if (selectedFilter == "1 Year" || selectedFilter == "All") {
                          label = DateFormat('MMM').format(date);
                        } else {
                          label = DateFormat('d MMM').format(date);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            label,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.w500),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (targetWeight != null) ...[
                   LineChartBarData(
                    spots: [
                      FlSpot(0, targetWeight!),
                      FlSpot(entries.length.toDouble() - 1, targetWeight!),
                    ],
                    isCurved: false,
                    color: Colors.grey.withOpacity(0.3),
                    barWidth: 1,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
                LineChartBarData(
                  spots: _getSpots(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: entries.length < 15,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF4CAF50),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.15),
                        const Color(0xFF4CAF50).withOpacity(0.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalDoneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            "${(goalPercent * 100).toStringAsFixed(0)}%",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 2),
          Text(
            "of goal done",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.edit_outlined, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(entries.length, (i) {
      return FlSpot(i.toDouble(), entries[i].weight);
    });
  }

  double _getInterval() {
    if (entries.length > 30) return entries.length / 5;
    if (entries.length > 14) return 7;
    return 1;
  }
}
