import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_scaffold.dart';
import 'custom_plan_ready.dart';

class LongTermResultsPage extends StatelessWidget {
  final String goal;
  final String targetWeight;
  final double currentWeight;
  final bool isImperial;
  final double speed;

  const LongTermResultsPage({
    super.key,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.isImperial,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: "Cal AI creates long-term results",
      subtitle: "", // No subtitle in design
      progress: 0.80,
      isContinueEnabled: true,
      onContinue: () {
        Get.to(() => CustomPlanReadyPage(
          goal: goal,
          targetWeight: targetWeight,
          currentWeight: currentWeight,
          isImperial: isImperial,
          speed: speed,
        ));
      },
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your weight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ResultsGraphPainter(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "80% of Cal AI users maintain their weight loss even 6 months later",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final pathRed = Path();
    final pathBlack = Path();

    // Start points
    final startY = size.height * 0.2;
    final endY = size.height * 0.8;
    
    // Black line (Cal AI) - going down
    paint.color = Colors.black;
    pathBlack.moveTo(0, startY);
    pathBlack.cubicTo(
      size.width * 0.4, startY, 
      size.width * 0.4, endY, 
      size.width, endY
    );
    canvas.drawPath(pathBlack, paint);

    // Red line (Traditional diet) - going down then up
    paint.color = Colors.red.shade300;
    pathRed.moveTo(0, startY);
    pathRed.cubicTo(
      size.width * 0.4, startY, 
      size.width * 0.5, endY * 0.6, // Dip
      size.width, startY * 0.8 // Rebound
    );
    canvas.drawPath(pathRed, paint);

    // Draw dots
    final paintDot = Paint()..style = PaintingStyle.fill;
    
    // Start dot
    paintDot.color = Colors.white;
    canvas.drawCircle(Offset(0, startY), 6, paintDot);
    paintDot.color = Colors.black;
    paintDot.style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(0, startY), 6, paintDot);

    // End dot Black
    paintDot.style = PaintingStyle.fill;
    paintDot.color = Colors.white;
    canvas.drawCircle(Offset(size.width, endY), 6, paintDot);
    paintDot.style = PaintingStyle.stroke;
    paintDot.color = Colors.black;
    canvas.drawCircle(Offset(size.width, endY), 6, paintDot);

    // Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Cal AI Label - simple mock pill
    // Mocking label drawing is complex with painting, simpler to use Stack in Widget but Painter is cleaner for lines.
    // I will skip complex label drawing inside painter for now to keep it simple, main visual is the lines.
    
    // Month labels
    textPainter.text = TextSpan(
      text: "Month 1",
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height - 15));

    textPainter.text = TextSpan(
      text: "Month 6",
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, size.height - 15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
