import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final IconData icon;
  final Color color;
  final String? badge;

  const ProgressStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.icon,
    this.color = Colors.black,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 4.0,
                  percent: percent.clamp(0.0, 1.0),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.grey.shade100,
                  progressColor: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.split(' ')[0],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (value.contains(' ')) ...[
                const SizedBox(width: 4),
                Text(
                  value.split(' ').sublist(1).join(' '),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7B88FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, size: 8, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    badge!,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
