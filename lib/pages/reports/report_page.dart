import 'package:flutter/material.dart';
import 'dart:math';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070F1F),
      body: Stack(
        children: [
          const GridBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Reports",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Historical trends & impact summary",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),

                /// TOP SUMMARY CARDS
                Row(
                  children: const [
                    Expanded(child: SummaryCard(title: "2.4t", subtitle: "CO₂ Saved")),
                    SizedBox(width: 20),
                    Expanded(child: SummaryCard(title: "\$1280", subtitle: "Cost Saved")),
                    SizedBox(width: 20),
                    Expanded(child: SummaryCard(title: "12", subtitle: "Trees Equivalent")),
                    SizedBox(width: 20),
                    Expanded(child: SummaryCard(title: "15.3%", subtitle: "Energy Reduced")),
                  ],
                ),

                const SizedBox(height: 40),

                /// CHARTS
                Row(
                  children: const [
                    Expanded(child: ChartCard(title: "Monthly Energy Usage (kWh)", isBar: true)),
                    SizedBox(width: 20),
                    Expanded(child: ChartCard(title: "Monthly Cost (\$)", isBar: false)),
                  ],
                ),

                const SizedBox(height: 40),

                /// AI SECTION
                const Text(
                  "AI Comments & Suggestions",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                const SuggestionCard(
                  text:
                      "Shift heavy computing tasks to off-peak hours (22:00–06:00) to reduce peak demand charges by ~18%",
                  savings: "Save \$340/month",
                ),
                const SizedBox(height: 15),
                const SuggestionCard(
                  text:
                      "Enable adaptive HVAC scheduling based on room occupancy — detected 35% idle runtime",
                  savings: "Save \$220/month",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// GRID BACKGROUND
//////////////////////////////////////////////////////////////

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      size: Size.infinite,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.08)
      ..strokeWidth = 1;

    const double gridSize = 40;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//////////////////////////////////////////////////////////////
/// SUMMARY CARD
//////////////////////////////////////////////////////////////

class SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const SummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// CHART CARD
//////////////////////////////////////////////////////////////

class ChartCard extends StatelessWidget {
  final String title;
  final bool isBar;

  const ChartCard({
    super.key,
    required this.title,
    required this.isBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: isBar ? BarChartPainter() : LineChartPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// BAR CHART
//////////////////////////////////////////////////////////////

class BarChartPainter extends CustomPainter {
  final List<double> values = [22000, 24000, 21000, 19500, 18000, 20000, 17500];

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = Colors.greenAccent;

    double barWidth = size.width / (values.length * 2);

    for (int i = 0; i < values.length; i++) {
      double height = (values[i] / 26000) * size.height;
      double x = i * barWidth * 2 + barWidth / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - height, barWidth, height),
          const Radius.circular(6),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//////////////////////////////////////////////////////////////
/// LINE CHART
//////////////////////////////////////////////////////////////

class LineChartPainter extends CustomPainter {
  final List<double> values = [2600, 2900, 2500, 2300, 2100, 2400, 2000];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      double x = (i / (values.length - 1)) * size.width;
      double y = size.height - (values[i] / 3000) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//////////////////////////////////////////////////////////////
/// SUGGESTION CARD
//////////////////////////////////////////////////////////////

class SuggestionCard extends StatelessWidget {
  final String text;
  final String savings;

  const SuggestionCard({
    super.key,
    required this.text,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            savings,
            style: const TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
