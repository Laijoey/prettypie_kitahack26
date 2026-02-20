import 'package:flutter/material.dart';

import '../pages/dashboard/dashboard_page.dart';
import '../pages/room_monitor/room_occupancy_page.dart';
import '../pages/gamification/gamification_page.dart';
import '../pages/reports/report_page.dart';
import '../widgets/sidebar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    DashboardPage(),
    RoomOccupancyPage(),
    GamificationPage(),
    ReportsPage(),
  ];

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onMenuSelected,
          ),

          /// MAIN CONTENT
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
