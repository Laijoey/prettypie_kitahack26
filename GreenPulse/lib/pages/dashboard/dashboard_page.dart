import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          /// BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050816), Color(0xFF0B1120)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// GRID OVERLAY
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),

          /// MAIN CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                const Text(
                  "Energy Dashboard",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Real-time monitoring · AI-powered insights",
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),

                const SizedBox(height: 30),

                /// SUMMARY CARDS (UNCHANGED)
                GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    SummaryCard(
                      title: "Current Usage",
                      value: "72 kW",
                      subtitle: "Live reading",
                      percentage: "8%",
                      icon: Icons.flash_on,
                    ),
                    SummaryCard(
                      title: "Today's Cost",
                      value: "\$48.20",
                      subtitle: "Est. monthly: \$1,446",
                      percentage: "12%",
                      icon: Icons.attach_money,
                    ),
                    SummaryCard(
                      title: "vs. Yesterday",
                      value: "-15%",
                      subtitle: "You're saving energy",
                      percentage: "15%",
                      icon: Icons.trending_down,
                    ),
                    SummaryCard(
                      title: "CO₂ Saved",
                      value: "2.4 tons",
                      subtitle: "This month",
                      percentage: "6%",
                      icon: Icons.eco,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// CHART + ALERTS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 3, child: RealTimeChartPanel()),
                    SizedBox(width: 24),
                    Expanded(flex: 2, child: AlertsPanel()),
                  ],
                ),

                const SizedBox(height: 30),

                /// SUGGESTIONS (room occupancy removed for staff dashboard)
                const SuggestionsPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


///////////////////////////////////////////////////////////////
/// REAL TIME CHART PANEL
///////////////////////////////////////////////////////////////

class RealTimeChartPanel extends StatelessWidget {
  const RealTimeChartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Real-Time Energy Usage (kW)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "● LIVE",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => const FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 30 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          "${value.toInt()}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        if (value % 4 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          "${value.toInt()}h",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.white24),
                    bottom: BorderSide(color: Colors.white24),
                  ),
                ),
                minX: 0,
                maxX: 23,
                minY: 0,
                maxY: 140,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 40),
                      FlSpot(4, 55),
                      FlSpot(8, 80),
                      FlSpot(12, 95),
                      FlSpot(16, 70),
                      FlSpot(20, 60),
                      FlSpot(23, 45),
                    ],
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.greenAccent.withOpacity(0.18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


///////////////////////////////////////////////////////////////
/// ALERTS PANEL
///////////////////////////////////////////////////////////////

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "AI Anomaly Alerts",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          AlertCard(
            color: Colors.red,
            title: "CRITICAL",
            message:
                "Unusual energy spike detected in Building A, Floor 3",
          ),
          SizedBox(height: 16),
          AlertCard(
            color: Colors.orange,
            title: "WARNING",
            message: "HVAC running in unoccupied zone B2",
          ),
          SizedBox(height: 16),
          AlertCard(
            color: Colors.green,
            title: "INFO",
            message: "Consistent after-hours usage detected",
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ALERT CARD
///////////////////////////////////////////////////////////////

class AlertCard extends StatelessWidget {
  final Color color;
  final String title;
  final String message;

  const AlertCard({
    super.key,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// SUGGESTIONS PANEL
///////////////////////////////////////////////////////////////

class SuggestionsPanel extends StatelessWidget {
  const SuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "AI Suggestions",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SuggestionCard(
            priority: "HIGH PRIORITY",
            text:
                "Shift heavy computing tasks to off-peak hours to reduce peak demand charges.",
          ),
          SizedBox(height: 16),
          SuggestionCard(
            priority: "MEDIUM PRIORITY",
            text:
                "Replace fluorescent lighting with smart LED systems.",
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// SUGGESTION CARD
///////////////////////////////////////////////////////////////

class SuggestionCard extends StatelessWidget {
  final String priority;
  final String text;

  const SuggestionCard({
    super.key,
    required this.priority,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(priority,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(text,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ROOM PANEL
///////////////////////////////////////////////////////////////

class RoomPanel extends StatelessWidget {
  const RoomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Room Occupancy",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          // ✅ GRID STARTS HERE
          GridView.count(
            crossAxisCount: 2, // 2 cards per row
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3, // controls height
            children: const [
              RoomCard(
                title: "Conference Room A",
                value: "8/12",
                status: "OPTIMAL",
                color: Colors.green,
              ),
              RoomCard(
                title: "Open Office A",
                value: "24/40",
                status: "HIGH",
                color: Colors.orange,
              ),
              RoomCard(
                title: "Server Room",
                value: "0/4",
                status: "CRITICAL",
                color: Colors.red,
              ),
              RoomCard(
                title: "Break Room",
                value: "0/20",
                status: "ENERGY WASTE",
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


///////////////////////////////////////////////////////////////
/// ROOM CARD
///////////////////////////////////////////////////////////////

class RoomCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final Color color;

  const RoomCard({
    Key? key,
    required this.title,
    required this.value,
    required this.status,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


///////////////////////////////////////////////////////////////
/// GRID BACKGROUND
///////////////////////////////////////////////////////////////

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String percentage;
  final IconData icon;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.percentage,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(
              icon,
              color: Colors.green,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Main Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 35,
                    color: Color.fromARGB(255, 90, 230, 111),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Percentage Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
