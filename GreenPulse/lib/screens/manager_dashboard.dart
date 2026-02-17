import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_page.dart';
import '../main.dart' show themeController;
import '../services/vision_ai_service.dart';

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

class _ManagerDashboardState extends State<ManagerDashboard> with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  bool _aiAutomationEnabled = true;
  bool _autoTakeoverEnabled = false;
  String? _selectedDepartment;
  AnimationController? _blinkController;
  Animation<double>? _blinkAnimation;
  String _selectedEnergyView = 'All Office';
  String _selectedHistoricalView = 'All Office';
  final VisionAIService _visionService = VisionAIService();
  List<RoomData> _liveRooms = [];
  List<AlertData> _liveAlerts = [];


  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);
    _initBlinkAnimation();

    _visionService.startPolling();
    _visionService.roomsStream.listen((rooms) {
      setState(() => _liveRooms = rooms);
    });
    _visionService.alertsStream.listen((alerts) {
      setState(() => _liveAlerts = alerts);
    });
  }

  void _initBlinkAnimation() {
    _blinkController?.dispose();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController!);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _blinkController?.dispose();
    themeController.removeListener(_onThemeChanged);
    _visionService.dispose();
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
                child: buildLiveAIAlerts(_liveAlerts),
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
          buildLiveRoomOccupancyMap(_liveRooms),
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
            value: 'RM1,488',
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
              Row(
                children: [
                  const Text(
                    'Live Energy Usage (kW)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF30363D)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedEnergyView,
                        isDense: true,
                        dropdownColor: const Color(0xFF161B22),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'All Office', child: Text('All Office')),
                          DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                          DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                          DropdownMenuItem(value: 'Operations', child: Text('Operations')),
                          DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                          DropdownMenuItem(value: 'HR', child: Text('HR')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEnergyView = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (_blinkAnimation != null)
                AnimatedBuilder(
                  animation: _blinkAnimation!,
                  builder: (context, child) {
                    final animValue = _blinkAnimation?.value ?? 1.0;
                    return Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(animValue),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(animValue * 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.green.withOpacity(0.7 + animValue * 0.3),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    );
                  },
                )
              else
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Container(
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Actual Usage',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Predicted Baseline',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 400,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _getYInterval(),
                  verticalInterval: 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D).withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D).withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [4, 4],
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
                    axisNameWidget: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Time (24h)',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ),
                    axisNameSize: 24,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        if (value % 4 != 0 || value < 0 || value > 24) return const SizedBox.shrink();
                        String text = '${value.toInt().toString().padLeft(2, '0')}:00';
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'kW',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: _getYInterval(),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[700]!, width: 1),
                    left: BorderSide(color: Colors.grey[700]!, width: 1),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isActual = spot.barIndex == 1;
                        return LineTooltipItem(
                          '${spot.y.toInt()} kW',
                          TextStyle(
                            color: isActual ? const Color(0xFF4ADE80) : const Color(0xFF22D3EE),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: const Color(0xFF4ADE80).withOpacity(0.4),
                          strokeWidth: 2,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: const Color(0xFF4ADE80),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: _getChartData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    switch (_selectedEnergyView) {
      case 'All Office':
        return 150;
      case 'Engineering':
        return 60;
      case 'Marketing':
        return 30;
      case 'Operations':
        return 50;
      case 'Sales':
        return 35;
      case 'HR':
        return 20;
      default:
        return 150;
    }
  }

  double _getYInterval() {
    switch (_selectedEnergyView) {
      case 'All Office':
        return 25;
      case 'Engineering':
        return 10;
      case 'Marketing':
        return 5;
      case 'Operations':
        return 10;
      case 'Sales':
        return 5;
      case 'HR':
        return 5;
      default:
        return 25;
    }
  }

  List<LineChartBarData> _getChartData() {
    switch (_selectedEnergyView) {
      case 'Engineering':
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 20), FlSpot(2, 15), FlSpot(4, 12),
              FlSpot(6, 25), FlSpot(8, 40), FlSpot(10, 52),
              FlSpot(12, 48), FlSpot(14, 42), FlSpot(16, 45),
              FlSpot(18, 30), FlSpot(20, 18), FlSpot(22, 22), FlSpot(24, 25),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 22), FlSpot(2, 12), FlSpot(4, 10),
              FlSpot(6, 28), FlSpot(8, 45), FlSpot(10, 55),
              FlSpot(12, 50), FlSpot(14, 38), FlSpot(16, 48),
              FlSpot(18, 32), FlSpot(20, 15), FlSpot(22, 25), FlSpot(24, 28),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ];
      case 'Marketing':
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 8), FlSpot(2, 5), FlSpot(4, 4),
              FlSpot(6, 10), FlSpot(8, 18), FlSpot(10, 24),
              FlSpot(12, 22), FlSpot(14, 20), FlSpot(16, 23),
              FlSpot(18, 15), FlSpot(20, 8), FlSpot(22, 10), FlSpot(24, 9),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 7), FlSpot(2, 4), FlSpot(4, 3),
              FlSpot(6, 9), FlSpot(8, 16), FlSpot(10, 22),
              FlSpot(12, 20), FlSpot(14, 18), FlSpot(16, 21),
              FlSpot(18, 12), FlSpot(20, 6), FlSpot(22, 8), FlSpot(24, 8),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ];
      case 'Operations':
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 15), FlSpot(2, 12), FlSpot(4, 10),
              FlSpot(6, 18), FlSpot(8, 32), FlSpot(10, 42),
              FlSpot(12, 38), FlSpot(14, 35), FlSpot(16, 40),
              FlSpot(18, 25), FlSpot(20, 14), FlSpot(22, 18), FlSpot(24, 16),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 18), FlSpot(2, 10), FlSpot(4, 8),
              FlSpot(6, 22), FlSpot(8, 38), FlSpot(10, 45),
              FlSpot(12, 42), FlSpot(14, 32), FlSpot(16, 44),
              FlSpot(18, 28), FlSpot(20, 12), FlSpot(22, 20), FlSpot(24, 18),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ];
      case 'Sales':
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 10), FlSpot(2, 7), FlSpot(4, 6),
              FlSpot(6, 12), FlSpot(8, 22), FlSpot(10, 28),
              FlSpot(12, 25), FlSpot(14, 24), FlSpot(16, 27),
              FlSpot(18, 18), FlSpot(20, 10), FlSpot(22, 12), FlSpot(24, 11),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 9), FlSpot(2, 6), FlSpot(4, 5),
              FlSpot(6, 11), FlSpot(8, 20), FlSpot(10, 30),
              FlSpot(12, 27), FlSpot(14, 22), FlSpot(16, 25),
              FlSpot(18, 15), FlSpot(20, 8), FlSpot(22, 10), FlSpot(24, 10),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ];
      case 'HR':
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 5), FlSpot(2, 3), FlSpot(4, 2),
              FlSpot(6, 6), FlSpot(8, 12), FlSpot(10, 15),
              FlSpot(12, 14), FlSpot(14, 13), FlSpot(16, 14),
              FlSpot(18, 9), FlSpot(20, 5), FlSpot(22, 6), FlSpot(24, 5),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 4), FlSpot(2, 2), FlSpot(4, 2),
              FlSpot(6, 5), FlSpot(8, 10), FlSpot(10, 14),
              FlSpot(12, 12), FlSpot(14, 11), FlSpot(16, 13),
              FlSpot(18, 7), FlSpot(20, 4), FlSpot(22, 5), FlSpot(24, 5),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ];
      default: // All Office
        return [
          LineChartBarData(
            spots: const [
              FlSpot(0, 55), FlSpot(2, 40), FlSpot(4, 35),
              FlSpot(6, 50), FlSpot(8, 85), FlSpot(10, 110),
              FlSpot(12, 100), FlSpot(14, 95), FlSpot(16, 105),
              FlSpot(18, 75), FlSpot(20, 50), FlSpot(22, 60), FlSpot(24, 55),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF22D3EE),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [8, 6],
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 60), FlSpot(2, 35), FlSpot(4, 30),
              FlSpot(6, 65), FlSpot(8, 95), FlSpot(10, 125),
              FlSpot(12, 115), FlSpot(14, 90), FlSpot(16, 110),
              FlSpot(18, 70), FlSpot(20, 45), FlSpot(22, 65), FlSpot(24, 75),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF4ADE80),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4ADE80).withOpacity(0.3),
                  const Color(0xFF4ADE80).withOpacity(0.05),
                ],
              ),
            ),
            shadow: Shadow(
              color: const Color(0xFF4ADE80).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ),
        ];
    }
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
          const SizedBox(height: 8),
          Text(
            'Shows each department\'s energy usage vs. target. Green indicates on track, orange means attention needed.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressItem('Engineering', 4200, 4000, 0.87, Colors.orange),
          const SizedBox(height: 20),
          _buildProgressItem('Marketing', 1800, 2000, 0.94, Colors.green),
          const SizedBox(height: 20),
          _buildProgressItem('Operations', 3500, 3200, 0.82, Colors.orange),
          const SizedBox(height: 20),
          _buildProgressItem('Sales', 2100, 2200, 0.91, Colors.green),
          const SizedBox(height: 20),
          _buildProgressItem('HR', 1200, 1300, 0.96, Colors.green),
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
            savings: 'RM340/month',
            priorityColor: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSuggestionItem(
            priority: 'HIGH',
            suggestion: 'Enable adaptive HVAC scheduling based on room occupancy — detected 35% idle runtime',
            savings: 'RM220/month',
            priorityColor: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSuggestionItem(
            priority: 'MEDIUM',
            suggestion: 'Replace fluorescent lighting in zones C1-C4 with smart LED — ROI in 8 months',
            savings: 'RM150/month',
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
    final departmentData = [
      {'name': 'Engineering', 'current': 4500.0, 'target': 4000.0},
      {'name': 'Marketing', 'current': 2200.0, 'target': 2000.0},
      {'name': 'Operations', 'current': 3800.0, 'target': 3200.0},
      {'name': 'Sales', 'current': 2100.0, 'target': 2200.0},
      {'name': 'HR', 'current': 800.0, 'target': 1000.0},
    ];
    const double maxValue = 5000;
    
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
          // Horizontal bars
          ...departmentData.map((dept) => _buildHorizontalBar(
            name: dept['name'] as String,
            current: dept['current'] as double,
            target: dept['target'] as double,
            maxValue: maxValue,
          )),
          const SizedBox(height: 16),
          // X-axis labels
          Padding(
            padding: const EdgeInsets.only(left: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text('1000', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text('2000', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text('3000', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text('4000', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text('5000 kWh', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Current Usage', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Over Target', Colors.orange),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Target',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar({
    required String name,
    required double current,
    required double target,
    required double maxValue,
  }) {
    final isOverTarget = current > target;
    final barColor = isOverTarget ? Colors.orange : Colors.green;
    final currentPercent = (current / maxValue).clamp(0.0, 1.0);
    final targetPercent = (target / maxValue).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          decoration: BoxDecoration(
            color: const Color(0xFF21262D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          richMessage: TextSpan(
            children: [
              TextSpan(
                text: '$name\n',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: 'Actual: ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: '${current.toInt()} kWh\n',
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: 'Target: ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: '${target.toInt()} kWh',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              // Department name
              SizedBox(
                width: 100,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Bar container
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    return Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          // Current usage bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: barWidth * currentPercent,
                            height: 18,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                colors: [
                                  barColor,
                                  barColor.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          // Target line indicator
                          Positioned(
                            left: barWidth * targetPercent - 1,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
    final rooms = [
      {
        'code': 'A1',
        'name': 'Conference Room A',
        'status': RoomStatus.occupied,
        'occupancy': '8/12',
        'energy': 18,
        'lightsOn': true,
        'acOn': true,
        'hasCamera': true,
        'hasLight': true,
        'hasHvac': true,
      },
      {
        'code': 'A2',
        'name': 'Open Office A',
        'status': RoomStatus.occupied,
        'occupancy': '24/40',
        'energy': 32,
        'lightsOn': true,
        'acOn': true,
        'hasCamera': true,
        'hasLight': true,
        'hasHvac': true,
      },
      {
        'code': 'B1',
        'name': 'Server Room',
        'status': RoomStatus.empty,
        'occupancy': '0/4',
        'energy': 45,
        'lightsOn': false,
        'acOn': true,
        'hasCamera': true,
        'hasLight': false,
        'hasHvac': true,
      },
      {
        'code': 'B2',
        'name': 'Break Room',
        'status': RoomStatus.waste,
        'occupancy': '0/20',
        'energy': 12,
        'lightsOn': true,
        'acOn': true,
        'hasCamera': true,
        'hasLight': true,
        'hasHvac': true,
      },
      {
        'code': 'C1',
        'name': 'Lab Space',
        'status': RoomStatus.occupied,
        'occupancy': '6/15',
        'energy': 28,
        'lightsOn': true,
        'acOn': true,
        'hasCamera': true,
        'hasLight': true,
        'hasHvac': true,
      },
      {
        'code': 'C2',
        'name': 'Training Room',
        'status': RoomStatus.waste,
        'occupancy': '0/30',
        'energy': 22,
        'lightsOn': true,
        'acOn': true,
        'hasCamera': true,
        'hasLight': true,
        'hasHvac': true,
      },
    ];

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
          // Room cards grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomCard(room);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final status = room['status'] as RoomStatus;
    Color borderColor;
    Color bgColor;
    
    switch (status) {
      case RoomStatus.occupied:
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.08);
        break;
      case RoomStatus.empty:
        borderColor = const Color(0xFF30363D);
        bgColor = const Color(0xFF0D1117);
        break;
      case RoomStatus.waste:
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.08);
        break;
    }

    return GestureDetector(
      onTap: () => _showRoomDetailsDialog(room),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Code and icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      room['code'] as String,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        if (room['hasCamera'] == true)
                          Icon(Icons.videocam_outlined, color: Colors.grey[600], size: 14),
                        if (room['hasLight'] == true) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.lightbulb_outline, color: Colors.grey[600], size: 14),
                        ],
                        if (room['hasHvac'] == true) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.tune, color: Colors.grey[600], size: 14),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Room name
                Text(
                  room['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Status and occupancy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status == RoomStatus.occupied ? 'OCCUPIED' : 'EMPTY',
                      style: TextStyle(
                        color: status == RoomStatus.occupied ? Colors.green : Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey[500], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          room['occupancy'] as String,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Device badges
                Row(
                  children: [
                    if (room['lightsOn'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == RoomStatus.waste 
                              ? Colors.orange.withOpacity(0.2) 
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: status == RoomStatus.waste 
                                ? Colors.orange.withOpacity(0.5) 
                                : Colors.green.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              size: 10,
                              color: status == RoomStatus.waste ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lights ON',
                              style: TextStyle(
                                color: status == RoomStatus.waste ? Colors.orange : Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (room['acOn'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == RoomStatus.waste && status != RoomStatus.occupied
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: status == RoomStatus.waste && status != RoomStatus.occupied
                                ? Colors.orange.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ac_unit,
                              size: 10,
                              color: status == RoomStatus.waste ? Colors.orange : Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AC ON',
                              style: TextStyle(
                                color: status == RoomStatus.waste ? Colors.orange : Colors.grey[400],
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Waste indicator dot
          if (status == RoomStatus.waste)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF161B22), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRoomDetailsDialog(Map<String, dynamic> room) {
    final status = room['status'] as RoomStatus;
    Color statusColor;
    String aiComment;
    
    switch (status) {
      case RoomStatus.occupied:
        statusColor = Colors.green;
        aiComment = 'Energy usage is within normal range for current occupancy level.';
        break;
      case RoomStatus.empty:
        statusColor = Colors.grey;
        aiComment = 'Room is unoccupied. Systems are in standby mode.';
        break;
      case RoomStatus.waste:
        statusColor = Colors.red;
        aiComment = 'High energy draw relative to occupancy — monitor closely';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['code'] as String,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Occupancy and Energy row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Occupancy',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            status == RoomStatus.occupied ? 'Occupied' : 'Empty',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            room['occupancy'] as String,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Energy Usage',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${room['energy']} kW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Estimated',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Device Status
              Text(
                'DEVICE STATUS',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              // Device chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDeviceChip('HVAC', room['hasHvac'] == true),
                  _buildDeviceChip('Lights', room['hasLight'] == true),
                  _buildDeviceChip('Workstations', true),
                ],
              ),
              const SizedBox(height: 12),
              // Active device badges
              Row(
                children: [
                  if (room['lightsOn'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb, size: 14, color: Colors.yellow[600]),
                          const SizedBox(width: 6),
                          const Text(
                            'Lights ON',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (room['acOn'] == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ac_unit, size: 14, color: Colors.blue[300]),
                          const SizedBox(width: 6),
                          const Text(
                            'AC ON',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // AI Comment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status == RoomStatus.waste 
                      ? Colors.orange.withOpacity(0.1) 
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: status == RoomStatus.waste 
                        ? Colors.orange.withOpacity(0.3) 
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: status == RoomStatus.waste ? Colors.orange : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI COMMENT',
                            style: TextStyle(
                              color: status == RoomStatus.waste ? Colors.orange : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            aiComment,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Vision AI monitoring
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.videocam_outlined, color: Colors.grey[500], size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Vision AI monitoring active',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 12,
        ),
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
            value: 'RM1280',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historical Energy Trends (kWh)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedHistoricalView,
                    isDense: true,
                    dropdownColor: const Color(0xFF161B22),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All Office', child: Text('All Office')),
                      DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                      DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                      DropdownMenuItem(value: 'Operations', child: Text('Operations')),
                      DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                      DropdownMenuItem(value: 'HR', child: Text('HR')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedHistoricalView = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getHistoricalMaxY(),
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
                      interval: _getHistoricalInterval(),
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
                  horizontalInterval: _getHistoricalInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF30363D),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getHistoricalBarData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getHistoricalMaxY() {
    switch (_selectedHistoricalView) {
      case 'All Office':
        return 26000;
      case 'Engineering':
        return 8000;
      case 'Marketing':
        return 4000;
      case 'Operations':
        return 6000;
      case 'Sales':
        return 5000;
      case 'HR':
        return 2500;
      default:
        return 26000;
    }
  }

  double _getHistoricalInterval() {
    switch (_selectedHistoricalView) {
      case 'All Office':
        return 6500;
      case 'Engineering':
        return 2000;
      case 'Marketing':
        return 1000;
      case 'Operations':
        return 1500;
      case 'Sales':
        return 1250;
      case 'HR':
        return 625;
      default:
        return 6500;
    }
  }

  List<BarChartGroupData> _getHistoricalBarData() {
    switch (_selectedHistoricalView) {
      case 'Engineering':
        return [
          _buildHistoryBarGroup(0, 6500),
          _buildHistoryBarGroup(1, 6800),
          _buildHistoryBarGroup(2, 7000),
          _buildHistoryBarGroup(3, 5800),
          _buildHistoryBarGroup(4, 5500),
          _buildHistoryBarGroup(5, 5200),
          _buildHistoryBarGroup(6, 5600),
        ];
      case 'Marketing':
        return [
          _buildHistoryBarGroup(0, 3200),
          _buildHistoryBarGroup(1, 3000),
          _buildHistoryBarGroup(2, 2900),
          _buildHistoryBarGroup(3, 2500),
          _buildHistoryBarGroup(4, 2400),
          _buildHistoryBarGroup(5, 2600),
          _buildHistoryBarGroup(6, 2700),
        ];
      case 'Operations':
        return [
          _buildHistoryBarGroup(0, 5000),
          _buildHistoryBarGroup(1, 4800),
          _buildHistoryBarGroup(2, 5200),
          _buildHistoryBarGroup(3, 4200),
          _buildHistoryBarGroup(4, 4000),
          _buildHistoryBarGroup(5, 3900),
          _buildHistoryBarGroup(6, 4300),
        ];
      case 'Sales':
        return [
          _buildHistoryBarGroup(0, 4000),
          _buildHistoryBarGroup(1, 3800),
          _buildHistoryBarGroup(2, 3900),
          _buildHistoryBarGroup(3, 3200),
          _buildHistoryBarGroup(4, 3100),
          _buildHistoryBarGroup(5, 3000),
          _buildHistoryBarGroup(6, 3400),
        ];
      case 'HR':
        return [
          _buildHistoryBarGroup(0, 2000),
          _buildHistoryBarGroup(1, 1900),
          _buildHistoryBarGroup(2, 1850),
          _buildHistoryBarGroup(3, 1600),
          _buildHistoryBarGroup(4, 1550),
          _buildHistoryBarGroup(5, 1500),
          _buildHistoryBarGroup(6, 1700),
        ];
      default: // All Office
        return [
          _buildHistoryBarGroup(0, 22000),
          _buildHistoryBarGroup(1, 21000),
          _buildHistoryBarGroup(2, 21500),
          _buildHistoryBarGroup(3, 18000),
          _buildHistoryBarGroup(4, 17500),
          _buildHistoryBarGroup(5, 17000),
          _buildHistoryBarGroup(6, 18500),
        ];
    }
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
                'Cost & Prediction Report (RM)',
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                      return touchedSpots.map((spot) {
                        final monthIndex = spot.x.toInt();
                        final month = monthIndex >= 0 && monthIndex < months.length 
                            ? months[monthIndex] 
                            : '';
                        return LineTooltipItem(
                          '$month\nCost: RM${spot.y.toInt()}',
                          const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.green.withOpacity(0.5),
                          strokeWidth: 2,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.green,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
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
            height: 350,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CustomPaint(
                size: const Size(double.infinity, 330),
                painter: RadarChartPainter(
                  data: [0.87, 0.94, 0.82, 0.91, 0.96], // Engineering, Marketing, Operations, Sales, HR
                  labels: ['Engineering', 'Marketing', 'Operations', 'Sales', 'HR'],
                ),
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
            text: 'At current trajectory, organization will meet Q2 sustainability goals 2 weeks ahead of schedule. Projected annual savings: RM15,360.',
          ),
          const SizedBox(height: 12),
          _buildAISuggestionItem(
            text: 'Shift heavy computing tasks to off-peak hours (22:00-06:00) to reduce peak demand charges by ~18%',
            savings: 'RM340/month',
          ),
          const SizedBox(height: 12),
          _buildAISuggestionItem(
            text: 'Enable adaptive HVAC scheduling based on room occupancy — detected 35% idle runtime',
            savings: 'RM220/month',
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

  Widget buildLiveRoomOccupancyMap(List<RoomData> liveRooms) {
  // Fall back to the static room list if live data hasn't loaded yet
  final rooms = liveRooms.isNotEmpty ? liveRooms : _staticRooms();

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
        // --- Header ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Room Occupancy & Energy Waste Map',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Vision AI Live  •  Updated every 5s',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    // Show how many rooms have live Vision AI data
                    if (liveRooms.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${liveRooms.where((r) => r.isLiveData).length} live',
                          style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
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

        // --- Room grid ---
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            return _buildLiveRoomCard(rooms[index]);
          },
        ),
      ],
    ),
  );
}

// ==========================================
// LIVE ROOM CARD  (replaces _buildRoomCard)
// ==========================================
Widget _buildLiveRoomCard(RoomData room) {
  Color borderColor;
  Color bgColor;

  switch (room.status) {
    case RoomStatus.occupied:
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.08);
      break;
    case RoomStatus.waste:
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.08);
      break;
    default:
      borderColor = const Color(0xFF30363D);
      bgColor = const Color(0xFF0D1117);
  }

  return GestureDetector(
    onTap: () {/* keep your existing _showRoomDetailsDialog logic */},
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: code + Vision AI badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.code,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  // Show LIVE badge only for Vision AI rooms
                  if (room.isLiveData)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '● AI',
                        style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Room name
              Text(
                room.name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),

              // Status + occupancy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.status == RoomStatus.occupied ? 'OCCUPIED' : 'EMPTY',
                    style: TextStyle(
                      color: room.status == RoomStatus.occupied ? Colors.green : Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.people_outline, color: Colors.grey[500], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        room.occupancyDisplay,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // Confidence bar (only for Vision AI rooms)
              if (room.isLiveData) ...[
                Row(
                  children: [
                    Text(
                      'AI: ${(room.confidence * 100).toInt()}%',
                      style: TextStyle(color: Colors.grey[600], fontSize: 9),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: room.confidence,
                          backgroundColor: const Color(0xFF30363D),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            room.confidence > 0.8 ? Colors.green : Colors.orange,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Device badges for static rooms
                Row(
                  children: [
                    if (room.lightsOn)
                      _miniDeviceBadge('Lights ON', Icons.lightbulb, room.status == RoomStatus.waste),
                    if (room.acOn) ...[
                      const SizedBox(width: 6),
                      _miniDeviceBadge('AC ON', Icons.ac_unit, room.status == RoomStatus.waste),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),

        // Waste warning dot
        if (room.status == RoomStatus.waste)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF161B22), width: 2),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _miniDeviceBadge(String label, IconData icon, bool isWaste) {
  final color = isWaste ? Colors.orange : Colors.green;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ==========================================
// LIVE ALERTS BUILDER
// Uses _liveAlerts list streamed from VisionAIService
// Replace your _buildAIAnomalyAlerts() with this:
// ==========================================
Widget buildLiveAIAlerts(List<AlertData> liveAlerts) {
  // Merge Vision AI alerts on top of static hardcoded alerts
  final staticAlerts = [
    AlertData(type: 'CRITICAL', roomId: 'A', roomName: 'Building A Floor 3',
        message: 'Unusual energy spike — 240% above baseline', time: '14:23'),
    AlertData(type: 'INFO', roomId: 'MKT', roomName: 'Marketing',
        message: 'Consistent after-hours usage — consider scheduled shutdown', time: '09:15'),
  ];

  final allAlerts = [...liveAlerts, ...staticAlerts].take(5).toList();

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
            const Text('AI Anomaly Alerts',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (liveAlerts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${liveAlerts.length} new',
                  style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ...allAlerts.map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertFromData(alert),
        )),
      ],
    ),
  );
}

Widget _buildAlertFromData(AlertData alert) {
  Color color;
  IconData icon;
  switch (alert.type) {
    case 'CRITICAL':
      color = Colors.red;
      icon = Icons.error_outline;
      break;
    case 'WARNING':
      color = Colors.orange;
      icon = Icons.warning_amber_rounded;
      break;
    default:
      color = Colors.green;
      icon = Icons.info_outline;
  }

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
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(alert.type, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(alert.time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                if (alert.roomName.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('• ${alert.roomName}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ]),
              const SizedBox(height: 4),
              Text(alert.message, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==========================================
// STATIC FALLBACK ROOMS (used before API loads)
// ==========================================
List<RoomData> _staticRooms() {
  return [
    RoomData(code: 'A1', name: 'Conference Room A', occupancy: 8,  capacity: 12, status: RoomStatus.occupied, lightsOn: true,  acOn: true,  energy: 18, confidence: 0.0, source: 'static'),
    RoomData(code: 'A2', name: 'Open Office A',     occupancy: 24, capacity: 40, status: RoomStatus.occupied, lightsOn: true,  acOn: true,  energy: 32, confidence: 0.0, source: 'static'),
    RoomData(code: 'B1', name: 'Server Room',       occupancy: 0,  capacity: 4,  status: RoomStatus.empty,    lightsOn: false, acOn: true,  energy: 45, confidence: 0.0, source: 'static'),
    RoomData(code: 'B2', name: 'Break Room',        occupancy: 0,  capacity: 20, status: RoomStatus.waste,    lightsOn: true,  acOn: true,  energy: 12, confidence: 0.0, source: 'static'),
    RoomData(code: 'C1', name: 'Lab Space',         occupancy: 6,  capacity: 15, status: RoomStatus.occupied, lightsOn: true,  acOn: true,  energy: 28, confidence: 0.0, source: 'static'),
    RoomData(code: 'C2', name: 'Training Room',     occupancy: 0,  capacity: 30, status: RoomStatus.waste,    lightsOn: true,  acOn: true,  energy: 22, confidence: 0.0, source: 'static'),
  ];
}
}

// Badge Info class
class BadgeInfo {
  final String name;
  final String emoji;
  final String description;

  BadgeInfo(this.name, this.emoji, this.description);
}

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
    final radius = (size.height / 2) - 40; // Use height-based radius with margin for labels
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
