import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070F1F),
      body: Stack(
        children: [
          const ReportGridBackground(),
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
                    Expanded(
                        child: SummaryCard(
                            title: "2.4t", subtitle: "CO₂ Saved")),
                    SizedBox(width: 20),
                    Expanded(
                        child: SummaryCard(
                            title: "\$1280", subtitle: "Cost Saved")),
                    SizedBox(width: 20),
                    Expanded(
                        child: SummaryCard(
                            title: "12", subtitle: "Trees Equivalent")),
                    SizedBox(width: 20),
                    Expanded(
                        child: SummaryCard(
                            title: "15.3%", subtitle: "Energy Reduced")),
                  ],
                ),

                const SizedBox(height: 40),

                /// CHARTS — FIX: given explicit height so CustomPaint has a real size
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                        child: ChartCard(
                            title: "Monthly Energy Usage (kWh)",
                            isBar: true)),
                    SizedBox(width: 20),
                    Expanded(
                        child: ChartCard(
                            title: "Monthly Cost (\$)",
                            isBar: false)),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// GRID BACKGROUND — renamed to avoid class name conflict
//////////////////////////////////////////////////////////////

class ReportGridBackground extends StatelessWidget {
  const ReportGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ReportGridPainter(),
      size: Size.infinite,
    );
  }
}

class ReportGridPainter extends CustomPainter {
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
/// FIX: CustomPaint now wrapped in SizedBox.expand() so it
/// receives real constraints and actually paints content.
//////////////////////////////////////////////////////////////

class ChartCard extends StatelessWidget {
  final String title;
  final bool isBar;

  const ChartCard({
    super.key,
    required this.title,
    required this.isBar,
  });

  static const List<String> _months = [
    'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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
          const SizedBox(height: 16),

          /// FIX: LayoutBuilder explicitly passes real pixel dimensions to
          /// CustomPaint so it never gets a 0×0 canvas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: isBar ? BarChartPainter() : LineChartPainter(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Month labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _months
                .map((m) => Text(m,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// BAR CHART — also draws subtle grid lines for readability
//////////////////////////////////////////////////////////////

class BarChartPainter extends CustomPainter {
  final List<double> values = [
    22000, 24000, 21000, 19500, 18000, 20000, 17500
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bars
    final barPaint = Paint()..color = Colors.greenAccent;
    final dimBarPaint = Paint()..color = Colors.greenAccent.withOpacity(0.5);

    final double totalBars = values.length.toDouble();
    final double barWidth = (size.width / totalBars) * 0.55;
    final double gap = (size.width / totalBars) * 0.45;

    for (int i = 0; i < values.length; i++) {
      final double barH = (values[i] / 26000) * size.height;
      final double x = i * (barWidth + gap) + gap / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barH, barWidth, barH),
          const Radius.circular(5),
        ),
        // Highlight the most recent bar
        i == values.length - 1 ? barPaint : dimBarPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//////////////////////////////////////////////////////////////
/// LINE CHART — adds dot markers and a gradient fill
//////////////////////////////////////////////////////////////

class LineChartPainter extends CustomPainter {
  final List<double> values = [2600, 2900, 2500, 2300, 2100, 2400, 2000];

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Build list of points
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = (i / (values.length - 1)) * size.width;
      final double y = size.height - (values[i] / 3000) * size.height;
      points.add(Offset(x, y));
    }

    // Gradient fill under line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.tealAccent.withOpacity(0.3),
          Colors.tealAccent.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dot markers
    final dotPaint = Paint()..color = Colors.tealAccent;
    final dotBg = Paint()..color = const Color(0xFF0E1628);

    for (final p in points) {
      canvas.drawCircle(p, 5, dotBg);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 12),
            child: Icon(Icons.lightbulb_outline,
                color: Colors.tealAccent, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: const TextStyle(color: Colors.white, height: 1.5)),
                const SizedBox(height: 8),
                Text(
                  savings,
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
