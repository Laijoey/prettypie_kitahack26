import 'package:flutter/material.dart';

class RoomOccupancyPage extends StatelessWidget {
  const RoomOccupancyPage({super.key});

  final List<Map<String, dynamic>> rooms = const [
    {
      "id": "A1",
      "name": "Conference Room A",
      "status": "OPTIMAL",
      "statusColor": Colors.green,
      "visionFeed": true,
      "occupancy": "8/12",
      "energy": "Normal",
      "devices": ["HVAC", "Lights", "Display"],
      "warning": ""
    },
    {
      "id": "A2",
      "name": "Open Office A",
      "status": "HIGH USAGE",
      "statusColor": Colors.orange,
      "visionFeed": true,
      "occupancy": "24/40",
      "energy": "Normal",
      "devices": ["HVAC", "Lights", "Workstations"],
      "warning": ""
    },
    {
      "id": "B1",
      "name": "Server Room",
      "status": "CRITICAL",
      "statusColor": Colors.red,
      "visionFeed": true,
      "occupancy": "0/4",
      "energy": "High",
      "devices": ["Cooling", "Servers", "UPS"],
      "warning": ""
    },
    {
      "id": "B2",
      "name": "Break Room",
      "status": "ENERGY WASTE DETECTED",
      "statusColor": Colors.red,
      "visionFeed": true,
      "occupancy": "0/20",
      "energy": "Wasting",
      "devices": ["HVAC", "Lights", "Appliances"],
      "warning":
          "⚠ Devices active in empty room — AI recommends auto-shutdown"
    },
    {
      "id": "C1",
      "name": "Lab Space",
      "status": "OPTIMAL",
      "statusColor": Colors.green,
      "visionFeed": true,
      "occupancy": "6/15",
      "energy": "Normal",
      "devices": ["HVAC", "Lights", "Equipment"],
      "warning": ""
    },
    {
      "id": "C2",
      "name": "Training Room",
      "status": "OPTIMAL",
      "statusColor": Colors.green,
      "visionFeed": true,
      "occupancy": "0/30",
      "energy": "Normal",
      "devices": ["HVAC", "Lights", "Projector"],
      "warning": ""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Room Monitor",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Vision AI — Occupancy & Energy Waste Detection",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),

                /// ROOM GRID
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: rooms.map((room) {
                    return RoomCard(room: room);
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF070F1F),
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
/// ROOM CARD
//////////////////////////////////////////////////////////////

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: room['statusColor'].withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${room['id']}",
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: room['statusColor'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  room['status'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(room['name'],
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),

          /// VISION FEED
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: room['statusColor']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Icon(Icons.remove_red_eye,
                    color: Colors.greenAccent, size: 30)),
          ),

          const SizedBox(height: 12),

          /// OCCUPANCY / ENERGY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(room['occupancy'],
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.flash_on, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(room['energy'],
                      style: TextStyle(color: room['statusColor'])),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// DEVICES
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (room['devices'] as List<String>).map((device) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  device,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          /// WARNING TEXT
          if ((room['warning'] as String).isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                room['warning'],
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
