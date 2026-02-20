import 'package:flutter/material.dart';

class GamificationPage extends StatelessWidget {
  const GamificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          /// GRADIENT BACKGROUND
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

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                const Text(
                  "Gamification",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Complete tasks, earn points & badges",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 30),

                /// TOP STATS
                Row(
                  children: const [
                    Expanded(
                      child: StatCard(
                        icon: Icons.star_border,
                        value: "30",
                        label: "Points Earned",
                        color: Colors.greenAccent,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department_outlined,
                        value: "7",
                        label: "Day Streak",
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        icon: Icons.emoji_events_outlined,
                        value: "3/6",
                        label: "Badges Earned",
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// MAIN CONTENT
                Expanded(
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: ChecklistPanel()),
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: BadgesPanel()),
                    ],
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

///////////////////////////////////////////////////////////////
/// STAT CARD
///////////////////////////////////////////////////////////////

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// CHECKLIST PANEL
///////////////////////////////////////////////////////////////

class ChecklistPanel extends StatefulWidget {
  const ChecklistPanel({super.key});

  @override
  State<ChecklistPanel> createState() => _ChecklistPanelState();
}

class _ChecklistPanelState extends State<ChecklistPanel> {
  final List<List<dynamic>> _tasks = [
    ["Turn off monitors before leaving", true, "+10"],
    ["Use natural light when possible", true, "+15"],
    ["Report any energy waste you notice", false, "+20"],
    ["Unplug chargers when not in use", false, "+10"],
    ["Use stairs instead of elevator (below 3 floors)", true, "+5"],
    ["Set thermostat to eco mode", false, "+25"],
  ];

  int get _completedCount =>
      _tasks.where((t) => (t[1] as bool)).length;

  double get _progress =>
      _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

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
          /// TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Energy-Saving Checklist",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                "${_completedCount}/${_tasks.length}",
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1E293B),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),

          const SizedBox(height: 20),

          /// TASK LIST
          Expanded(
            child: ListView.separated(
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final bool done = task[1] as bool;

                return InkWell(
                  onTap: () {
                    setState(() {
                      task[1] = !done;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFF052E1F)
                          : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: done
                            ? Colors.greenAccent.withOpacity(0.6)
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done
                              ? Colors.greenAccent
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task[0] as String,
                            style: TextStyle(
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: done
                                  ? Colors.greenAccent
                                  : Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          task[2] as String,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// BADGES PANEL
///////////////////////////////////////////////////////////////

class BadgesPanel extends StatelessWidget {
  const BadgesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      ["🌱", "First Saver", "✓ Earned", true],
      ["⚡", "Week Warrior", "✓ Earned", true],
      ["🏆", "Eco Champion", "Earn 500+ points", false],
      ["🔥", "Green Streak", "30-day streak", false],
      ["👑", "Team Leader", "✓ Earned", true],
      ["🌍", "Carbon Zero", "Reduce emissions", false],
    ];

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
            "Badges",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              itemCount: badges.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final bool earned = badge[3] as bool;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: earned
                        ? const Color(0xFF052E1F)
                        : const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: earned
                          ? Colors.greenAccent.withOpacity(0.6)
                          : Colors.white10,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        badge[0] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge[1] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge[2] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: earned
                              ? Colors.greenAccent
                              : const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              },
            ),
          )
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
