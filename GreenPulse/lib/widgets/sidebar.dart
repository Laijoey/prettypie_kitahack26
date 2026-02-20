import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onLogout;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// APP TITLE
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "GreenPulse",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(color: Colors.white24),

          _SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),

          _SidebarItem(
            icon: Icons.meeting_room,
            label: "Room Monitor",
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),

          _SidebarItem(
            icon: Icons.emoji_events,
            label: "Gamification",
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),

          _SidebarItem(
            icon: Icons.bar_chart,
            label: "Reports",
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),

          const Spacer(),

          const Divider(color: Colors.white24),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Alex Chen\nStaff – Engineering",
              style: TextStyle(color: Colors.white54),
            ),
          ),

          if (onLogout != null)
            InkWell(
              onTap: onLogout,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[500],
                      size: 12,
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? Colors.green.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.greenAccent : Colors.white70,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
