import 'package:flutter/material.dart';
import 'login_page.dart';
import '../main.dart' show themeController;

class StaffDashboard extends StatefulWidget {
  final String email;
  final String name;

  const StaffDashboard({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
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
    final isDarkMode = themeController.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              themeController.toggleTheme();
            },
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome, Staff!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Title
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Quick Action Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  icon: Icons.add_shopping_cart,
                  title: 'New Order',
                  color: Colors.blue,
                  cardColor: cardColor!,
                  textColor: textColor,
                  onTap: () {
                    // TODO: Navigate to new order
                  },
                ),
                _buildActionCard(
                  icon: Icons.list_alt,
                  title: 'View Orders',
                  color: Colors.orange,
                  cardColor: cardColor,
                  textColor: textColor,
                  onTap: () {
                    // TODO: Navigate to orders list
                  },
                ),
                _buildActionCard(
                  icon: Icons.inventory,
                  title: 'Inventory',
                  color: Colors.green,
                  cardColor: cardColor,
                  textColor: textColor,
                  onTap: () {
                    // TODO: Navigate to inventory
                  },
                ),
                _buildActionCard(
                  icon: Icons.schedule,
                  title: 'Schedule',
                  color: Colors.purple,
                  cardColor: cardColor,
                  textColor: textColor,
                  onTap: () {
                    // TODO: Navigate to schedule
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Tasks
            Text(
              "Today's Tasks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Task List
            _buildTaskItem('Prepare morning pastries', true, cardColor, textColor),
            _buildTaskItem('Check inventory levels', false, cardColor, textColor),
            _buildTaskItem('Clean display counter', false, cardColor, textColor),
            _buildTaskItem('Update product labels', false, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, bool isCompleted, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[600] : Colors.transparent,
              border: Border.all(
                color: isCompleted ? Colors.green[600]! : Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
