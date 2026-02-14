import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_page.dart';
import '../main.dart' show themeController;

class ManagerDashboard extends StatefulWidget {
  final String email;
  final String name;

  const ManagerDashboard({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedNavIndex = 0;
  bool _aiAutomationEnabled = true;
  bool _autoTakeoverEnabled = false;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF161B22),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GreenPulse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ENERGY MONITOR',
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Navigation Items
          _buildNavItem(0, Icons.dashboard, 'Dashboard'),
          _buildNavItem(1, Icons.emoji_events_outlined, 'Gamification'),
          _buildNavItem(2, Icons.bar_chart, 'Reports & Analytics'),
          const Spacer(),
          // User Profile
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[700],
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Manager · Operations',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sign Out
          InkWell(
            onTap: _logout,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.green.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildGamificationContent();
      case 2:
        return _buildReportsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),
          // Stats Cards
          _buildStatsCards(),
          const SizedBox(height: 24),
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Energy Usage Chart
              Expanded(
                flex: 2,
                child: _buildEnergyChart(),
              ),
              const SizedBox(width: 24),
              // Department Progress
              Expanded(
                flex: 1,
                child: _buildDepartmentProgress(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // AI Anomaly Alerts and AI Suggestions Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildAIAnomalyAlerts(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildAISuggestions(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Department Energy Targets
          _buildDepartmentEnergyTargets(),
          const SizedBox(height: 24),
          // Room Occupancy & Energy Waste Map
          _buildRoomOccupancyMap(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manager Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Department overview & AI controls',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
        // AI Controls
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.green[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Automation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                _buildToggleSwitch(_aiAutomationEnabled, (value) {
                  setState(() {
                    _aiAutomationEnabled = value;
                  });
                }),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.grey[500],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-takeover if no response',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                _buildToggleSwitch(_autoTakeoverEnabled, (value) {
                  setState(() {
                    _autoTakeoverEnabled = value;
                  });
                }, small: true),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(bool value, Function(bool) onChanged, {bool small = false}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: small ? 36 : 44,
        height: small ? 18 : 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? Colors.green : Colors.grey[700],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: small ? 14 : 20,
            height: small ? 14 : 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.bolt,
            iconColor: Colors.green,
            value: '12,400',
            unit: 'kW',
            label: 'Total Usage',
            sublabel: 'All departments today',
            change: '-5%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            iconColor: Colors.grey,
            value: '\$1,488',
            unit: '',
            label: 'Total Cost',
            sublabel: 'Projected this month',
            change: '-8%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.business,
            iconColor: Colors.grey,
            value: '5',
            unit: '',
            label: 'Departments',
            sublabel: 'All reporting',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.track_changes,
            iconColor: Colors.orange,
            value: '3/5',
            unit: 'On Track',
            label: 'Target Status',
            sublabel: '2 departments above target',
            isTarget: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
    required String sublabel,
    String? change,
    bool isPositive = false,
    bool isTarget = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change.replaceAll('-', ''),
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: isTarget ? Colors.white : Colors.grey[500],
                      fontSize: isTarget ? 18 : 14,
                      fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Energy Usage (kW)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 35,
                  verticalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 1) text = '01:00';
                        if (value == 3) text = '03:00';
                        if (value == 5) text = '05:00';
                        if (value == 7) text = '07:00';
                        if (value == 9) text = '09:00';
                        if (value == 11) text = '11:00';
                        if (value == 13) text = '13:00';
                        if (value == 15) text = '15:00';
                        if (value == 17) text = '17:00';
                        if (value == 19) text = '19:00';
                        if (value == 21) text = '21:00';
                        if (value == 23) text = '23:00';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: 140,
                lineBarsData: [
                  // Dashed line (predicted/target)
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 70),
                      FlSpot(3, 50),
                      FlSpot(5, 85),
                      FlSpot(7, 95),
                      FlSpot(9, 120),
                      FlSpot(11, 105),
                      FlSpot(13, 90),
                      FlSpot(15, 100),
                      FlSpot(17, 115),
                      FlSpot(19, 90),
                      FlSpot(21, 70),
                      FlSpot(23, 80),
                    ],
                    isCurved: true,
                    color: Colors.green.withOpacity(0.5),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  // Solid line (actual)
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 65),
                      FlSpot(3, 45),
                      FlSpot(5, 80),
                      FlSpot(7, 100),
                      FlSpot(9, 130),
                      FlSpot(11, 110),
                      FlSpot(13, 85),
                      FlSpot(15, 95),
                      FlSpot(17, 105),
                      FlSpot(19, 85),
                      FlSpot(21, 60),
                      FlSpot(23, 75),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
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

  Widget _buildDepartmentProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressItem('Engineering', 4200, 4000, 0.87, Colors.orange),
          const SizedBox(height: 20),
          _buildProgressItem('Marketing', 1800, 2000, 0.94, Colors.green),
          const SizedBox(height: 20),
          _buildProgressItem('Operations', 3500, 3200, 0.82, Colors.orange),
          const SizedBox(height: 20),
          _buildProgressItem('Sales', 2100, 2200, 0.91, Colors.green),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String name,
    int current,
    int target,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFF30363D),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$current / $target kWh',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnomalyAlerts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Anomaly Alerts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildAlertItem(
            type: 'CRITICAL',
            time: '14:23',
            message: 'Unusual energy spike detected in Building A, Floor 3 — 240% above baseline',
            color: Colors.red,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            type: 'WARNING',
            time: '11:45',
            message: 'HVAC running at full capacity in unoccupied zone B2',
            color: Colors.orange,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            type: 'INFO',
            time: '09:15',
            message: 'Consistent after-hours usage pattern in Marketing dept — consider scheduled shutdown',
            color: Colors.green,
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String type,
    required String time,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSuggestionItem(
            priority: 'HIGH',
            suggestion: 'Shift heavy computing tasks to off-peak hours (22:00-06:00) to reduce peak demand charges by ~18%',
            savings: '\$340/month',
            priorityColor: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSuggestionItem(
            priority: 'HIGH',
            suggestion: 'Enable adaptive HVAC scheduling based on room occupancy — detected 35% idle runtime',
            savings: '\$220/month',
            priorityColor: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSuggestionItem(
            priority: 'MEDIUM',
            suggestion: 'Replace fluorescent lighting in zones C1-C4 with smart LED — ROI in 8 months',
            savings: '\$150/month',
            priorityColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem({
    required String priority,
    required String suggestion,
    required String savings,
    required Color priorityColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Save $savings',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          suggestion,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentEnergyTargets() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department Energy Targets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF21262D),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final departments = ['Engineering', 'Marketing', 'Operations', 'Sales', 'HR'];
                      return BarTooltipItem(
                        '${departments[group.x]}\n${rod.toY.toInt()} kWh',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const departments = ['Engineering', 'Marketing', 'Operations', 'Sales', 'HR'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            departments[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 4500, 4000),
                  _buildBarGroup(1, 2200, 2000),
                  _buildBarGroup(2, 3800, 3200),
                  _buildBarGroup(3, 2100, 2200),
                  _buildBarGroup(4, 800, 1000),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Current Usage', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Target', Colors.green.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double current, double target) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: current,
          color: current > target ? Colors.orange : Colors.green,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: target,
            color: Colors.green.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomOccupancyMap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room Occupancy & Energy Waste Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top-down floor view — click a room for details',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMapLegendItem('Occupied', Colors.green),
                  const SizedBox(width: 16),
                  _buildMapLegendItem('Empty', Colors.grey),
                  const SizedBox(width: 16),
                  _buildMapLegendItem('Waste', Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: _buildFloorPlan(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFloorPlan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Stack(
            children: [
              // Grid lines
              CustomPaint(
                size: Size(constraints.maxWidth, 300),
                painter: GridPainter(),
              ),
              // Rooms
              Positioned(
                left: 20,
                top: 20,
                child: _buildRoom('Conf A', 120, 80, RoomStatus.occupied),
              ),
              Positioned(
                left: 160,
                top: 20,
                child: _buildRoom('Conf B', 100, 80, RoomStatus.waste),
              ),
              Positioned(
                left: 280,
                top: 20,
                child: _buildRoom('Meeting 1', 90, 80, RoomStatus.empty),
              ),
              Positioned(
                left: 390,
                top: 20,
                child: _buildRoom('Meeting 2', 90, 80, RoomStatus.occupied),
              ),
              Positioned(
                left: 20,
                top: 120,
                child: _buildRoom('Open Office A', 200, 100, RoomStatus.occupied),
              ),
              Positioned(
                left: 240,
                top: 120,
                child: _buildRoom('Open Office B', 160, 100, RoomStatus.occupied),
              ),
              Positioned(
                left: 420,
                top: 120,
                child: _buildRoom('Break Room', 80, 100, RoomStatus.empty),
              ),
              Positioned(
                left: 20,
                top: 240,
                child: _buildRoom('Server Room', 100, 50, RoomStatus.waste),
              ),
              Positioned(
                left: 140,
                top: 240,
                child: _buildRoom('Storage', 80, 50, RoomStatus.empty),
              ),
              Positioned(
                left: 240,
                top: 240,
                child: _buildRoom('Kitchen', 100, 50, RoomStatus.occupied),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoom(String name, double width, double height, RoomStatus status) {
    Color borderColor;
    Color bgColor;
    
    switch (status) {
      case RoomStatus.occupied:
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      case RoomStatus.empty:
        borderColor = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.1);
        break;
      case RoomStatus.waste:
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.15);
        break;
    }
    
    return GestureDetector(
      onTap: () {
        _showRoomDetails(name, status);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (status == RoomStatus.waste) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red[400],
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomDetails(String roomName, RoomStatus status) {
    String statusText;
    String details;
    Color statusColor;
    
    switch (status) {
      case RoomStatus.occupied:
        statusText = 'Occupied';
        statusColor = Colors.green;
        details = 'Room is currently in use. Energy usage is optimized.';
        break;
      case RoomStatus.empty:
        statusText = 'Empty';
        statusColor = Colors.grey;
        details = 'Room is unoccupied. All systems are in standby mode.';
        break;
      case RoomStatus.waste:
        statusText = 'Energy Waste Detected';
        statusColor = Colors.red;
        details = 'Room is unoccupied but systems are running at full capacity. Consider automated shutdown.';
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
        title: Text(
          roomName,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              details,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GAMIFICATION PAGE ====================

  Widget _buildGamificationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Gamification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track energy-saving achievements across departments',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Department Leaderboard
          _buildDepartmentLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildDepartmentLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.amber[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Department Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLeaderboardItem(
            rank: 1,
            department: 'HR',
            efficiency: 96,
            points: 3400,
            stars: 3,
            badges: [
              BadgeInfo('First Saver', '🌱', 'Achieved first energy saving milestone'),
              BadgeInfo('Week Warrior', '⚡', '7 consecutive days under target'),
              BadgeInfo('Eco Champion', '🏆', 'Top performer for the month'),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(
            rank: 2,
            department: 'Marketing',
            efficiency: 94,
            points: 3100,
            stars: 3,
            badges: [
              BadgeInfo('First Saver', '🌱', 'Achieved first energy saving milestone'),
              BadgeInfo('Green Streak', '🔥', '30 days of consistent savings'),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(
            rank: 3,
            department: 'Sales',
            efficiency: 91,
            points: 2780,
            stars: 2,
            badges: [
              BadgeInfo('First Saver', '🌱', 'Achieved first energy saving milestone'),
              BadgeInfo('Team Leader', '👑', 'Led department to top 3'),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(
            rank: 4,
            department: 'Engineering',
            efficiency: 87,
            points: 2450,
            stars: 2,
            badges: [
              BadgeInfo('Week Warrior', '⚡', '7 consecutive days under target'),
            ],
          ),
          const SizedBox(height: 12),
          _buildLeaderboardItem(
            rank: 5,
            department: 'Operations',
            efficiency: 82,
            points: 1980,
            stars: 1,
            badges: [
              BadgeInfo('First Saver', '🌱', 'Achieved first energy saving milestone'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String department,
    required int efficiency,
    required int points,
    required int stars,
    required List<BadgeInfo> badges,
  }) {
    final isSelected = _selectedDepartment == department;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDepartment = department;
        });
        _showDepartmentBadges(department, badges, efficiency, points, stars);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.withOpacity(0.3) : const Color(0xFF30363D),
          ),
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.withOpacity(0.2) : const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: isSelected
                    ? Icon(
                        Icons.workspace_premium,
                        color: Colors.green[400],
                        size: 20,
                      )
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Department info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Efficiency: $efficiency%',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(points),
                  style: TextStyle(
                    color: Colors.green[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Stars
            Row(
              children: List.generate(
                3,
                (index) => Icon(
                  Icons.star,
                  color: index < stars ? Colors.amber : Colors.grey[700],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showDepartmentBadges(
    String department,
    List<BadgeInfo> badges,
    int efficiency,
    int points,
    int stars,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: Colors.green[400],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$department Department',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Efficiency: $efficiency%',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${_formatNumber(points)} points',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Icon(
                        Icons.star,
                        color: index < stars ? Colors.amber : Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFF30363D)),
              const SizedBox(height: 16),
              // Badges section
              const Text(
                'Earned Badges',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (badges.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No badges earned yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges.map((badge) => _buildBadgeCard(badge, earned: true)).toList(),
                ),
              const SizedBox(height: 24),
              // Available badges to earn
              Text(
                'Available to Earn',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _getUnearnedBadges(badges)
                    .map((badge) => _buildBadgeCard(badge, earned: false))
                    .toList(),
              ),
              const SizedBox(height: 24),
              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BadgeInfo> _getUnearnedBadges(List<BadgeInfo> earnedBadges) {
    final allBadges = [
      BadgeInfo('First Saver', '🌱', 'Achieved first energy saving milestone'),
      BadgeInfo('Week Warrior', '⚡', '7 consecutive days under target'),
      BadgeInfo('Eco Champion', '🏆', 'Top performer for the month'),
      BadgeInfo('Green Streak', '🔥', '30 days of consistent savings'),
      BadgeInfo('Team Leader', '👑', 'Led department to top 3'),
      BadgeInfo('Carbon Zero', '🌍', 'Achieved net-zero carbon for a week'),
    ];
    
    return allBadges.where((badge) => 
      !earnedBadges.any((earned) => earned.name == badge.name)
    ).toList();
  }

  Widget _buildBadgeCard(BadgeInfo badge, {required bool earned}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned ? Colors.green.withOpacity(0.1) : const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: earned ? Colors.green.withOpacity(0.3) : const Color(0xFF30363D),
        ),
      ),
      child: Column(
        children: [
          Text(
            badge.emoji,
            style: TextStyle(
              fontSize: 32,
              color: earned ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              color: earned ? Colors.white : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!earned) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.lock_outline,
              color: Colors.grey[700],
              size: 14,
            ),
          ],
        ],
      ),
    );
  }

  // ==================== REPORTS PAGE ====================

  Widget _buildReportsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reports & Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Department-level insights, cost predictions & AI analysis',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Cards
          _buildReportStatsCards(),
          const SizedBox(height: 24),
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Historical Energy Trends
              Expanded(
                flex: 1,
                child: _buildHistoricalEnergyTrends(),
              ),
              const SizedBox(width: 24),
              // Cost & Prediction Report
              Expanded(
                flex: 1,
                child: _buildCostPredictionReport(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Department Efficiency and AI Comments Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Efficiency Radar Chart
              Expanded(
                flex: 1,
                child: _buildDepartmentEfficiencyRadar(),
              ),
              const SizedBox(width: 24),
              // AI Comments & Analysis
              Expanded(
                flex: 1,
                child: _buildAICommentsAnalysis(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildReportStatCard(
            icon: Icons.cloud_outlined,
            iconColor: Colors.green,
            value: '2.4t',
            label: 'CO₂ Saved',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildReportStatCard(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            value: '\$1280',
            label: 'Cost Saved',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildReportStatCard(
            icon: Icons.park_outlined,
            iconColor: Colors.green,
            value: '12',
            label: 'Trees Equivalent',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildReportStatCard(
            icon: Icons.trending_down,
            iconColor: Colors.green,
            value: '15.3%',
            label: 'Energy Reduced',
          ),
        ),
      ],
    );
  }

  Widget _buildReportStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalEnergyTrends() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historical Energy Trends (kWh)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 26000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF21262D),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                      return BarTooltipItem(
                        '${months[group.x]}\n${_formatNumber(rod.toY.toInt())} kWh',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 6500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 6500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildHistoryBarGroup(0, 22000),
                  _buildHistoryBarGroup(1, 21000),
                  _buildHistoryBarGroup(2, 21500),
                  _buildHistoryBarGroup(3, 18000),
                  _buildHistoryBarGroup(4, 17500),
                  _buildHistoryBarGroup(5, 17000),
                  _buildHistoryBarGroup(6, 18500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildHistoryBarGroup(int x, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: Colors.green,
          width: 40,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildCostPredictionReport() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.green[400],
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cost & Prediction Report (\$)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 750,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 750,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 3000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2700),
                      FlSpot(1, 2900),
                      FlSpot(2, 2650),
                      FlSpot(3, 2500),
                      FlSpot(4, 2400),
                      FlSpot(5, 2550),
                      FlSpot(6, 2300),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF161B22),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
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

  Widget _buildDepartmentEfficiencyRadar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department Efficiency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: CustomPaint(
              size: const Size(double.infinity, 300),
              painter: RadarChartPainter(
                data: [0.87, 0.94, 0.82, 0.91, 0.96], // Engineering, Marketing, Operations, Sales, HR
                labels: ['Engineering', 'Marketing', 'Operations', 'Sales', 'HR'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICommentsAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_outlined,
                color: Colors.green[400],
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Comments & Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAICommentItem(
            icon: Icons.check_box,
            iconColor: Colors.green,
            text: 'Overall energy consumption has decreased by 20.6% over the past 6 months, primarily driven by HVAC optimization in Marketing and HR departments.',
          ),
          const SizedBox(height: 12),
          _buildAICommentItem(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
            text: 'Engineering department consistently exceeds targets. Recommend server consolidation and off-peak scheduling to reduce baseline by ~15%.',
          ),
          const SizedBox(height: 12),
          _buildAICommentItem(
            icon: Icons.flag,
            iconColor: Colors.purple,
            text: 'At current trajectory, organization will meet Q2 sustainability goals 2 weeks ahead of schedule. Projected annual savings: \$15,360.',
          ),
          const SizedBox(height: 12),
          _buildAISuggestionItem(
            text: 'Shift heavy computing tasks to off-peak hours (22:00-06:00) to reduce peak demand charges by ~18%',
            savings: '\$340/month',
          ),
          const SizedBox(height: 12),
          _buildAISuggestionItem(
            text: 'Enable adaptive HVAC scheduling based on room occupancy — detected 35% idle runtime',
            savings: '\$220/month',
          ),
        ],
      ),
    );
  }

  Widget _buildAICommentItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionItem({
    required String text,
    required String savings,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber[400],
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save $savings',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

// Badge Info class
class BadgeInfo {
  final String name;
  final String emoji;
  final String description;

  BadgeInfo(this.name, this.emoji, this.description);
}

enum RoomStatus { occupied, empty, waste }

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF30363D).withOpacity(0.3)
      ..strokeWidth = 1;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  RadarChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final angleStep = (2 * pi) / data.length;
    
    // Draw grid lines (pentagon shapes)
    final gridPaint = Paint()
      ..color = const Color(0xFF30363D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int level = 1; level <= 5; level++) {
      final levelRadius = radius * (level / 5);
      final path = Path();
      for (int i = 0; i <= data.length; i++) {
        final angle = (i % data.length) * angleStep - pi / 2;
        final x = center.dx + levelRadius * cos(angle);
        final y = center.dy + levelRadius * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    
    // Draw axis lines
    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }
    
    // Draw data polygon
    final dataPath = Path();
    final dataPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final dataStrokePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i <= data.length; i++) {
      final index = i % data.length;
      final angle = index * angleStep - pi / 2;
      final value = data[index];
      final x = center.dx + radius * value * cos(angle);
      final y = center.dy + radius * value * sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, dataStrokePaint);
    
    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - pi / 2;
      final value = data[i];
      final x = center.dx + radius * value * cos(angle);
      final y = center.dy + radius * value * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final labelRadius = radius + 25;
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);
      
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 11,
        ),
      );
      textPainter.layout();
      
      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
