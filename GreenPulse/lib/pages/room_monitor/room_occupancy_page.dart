import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomOccupancyPage extends StatefulWidget {
  const RoomOccupancyPage({super.key});

  @override
  State<RoomOccupancyPage> createState() => _RoomOccupancyPageState();
}

class _RoomOccupancyPageState extends State<RoomOccupancyPage> {

  // ─────────────────────────────────────────
  // CAMERA VIEW FUNCTIONALITY
  // ─────────────────────────────────────────

  // Change IP to match your vision_ai_service.dart setting
  static const String _serverBase = 'http://localhost:5000';

  // Fetches snapshot from Python server
  Future<Map<String, dynamic>?> _fetchRoomSnapshot(String roomId) async {
    try {
      final response = await http
          .get(Uri.parse('$_serverBase/snapshot/$roomId'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('[Snapshot] Error fetching $roomId: $e');
    }
    return null;
  }

  // Opens the camera view popup when eye icon is tapped
  void _showCameraViewDialog(String roomCode, String roomName, bool isLive) {
    showDialog(
      context: context,
      builder: (_) => _CameraViewDialog(
        roomCode: roomCode,
        roomName: roomName,
        isLiveCamera: isLive,
        fetchSnapshot: _fetchRoomSnapshot,
      ),
    );
  }

  // Eye icon button — add this wherever you want the button
  // Pass: roomCode e.g. "B2", roomName, isLive (true only for B2)
  Widget _buildEyeButton(String roomCode, String roomName, bool isLive) {
    return GestureDetector(
      onTap: () => _showCameraViewDialog(roomCode, roomName, isLive),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Icon(
          Icons.visibility_outlined,
          color: isLive ? Colors.green[400] : Colors.grey[400],
          size: 15,
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> rooms = [
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

  Timer? _b2Timer;

  @override
  void initState() {
    super.initState();
    _startB2Polling();
  }

  void _startB2Polling() {
    _updateB2FromSnapshot();
    _b2Timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _updateB2FromSnapshot();
    });
  }

  @override
  void dispose() {
    _b2Timer?.cancel();
    super.dispose();
  }

  Future<void> _updateB2FromSnapshot() async {
    final data = await _fetchRoomSnapshot('B2');
    if (!mounted || data == null) return;

    final index = rooms.indexWhere((r) => r['id'] == 'B2');
    if (index == -1) return;

    final occ = (data['occupancy'] ?? 0) as int;
    final cap = (data['capacity'] ?? 0) as int;
    final status = (data['status'] ?? '').toString();

    final room = rooms[index];
    room['occupancy'] = '$occ/$cap';
    room['energy'] = status == 'waste'
        ? 'Wasting'
        : status == 'occupied'
            ? 'High'
            : 'Normal';
    room['warning'] = _buildB2Warning(status, occ);

    setState(() {});
  }

  String _buildB2Warning(String status, int occupancy) {
    if (status == 'waste' && occupancy == 0) {
      return '⚠ Devices active in empty room — AI recommends auto-shutdown';
    }
    if (status == 'occupied' && occupancy > 0) {
      return 'Room currently occupied — AI reports usage within expected range.';
    }
    if (status == 'occupied' && occupancy == 0) {
      return '⚠ AI detected occupancy mismatch — please verify on camera.';
    }
    return '';
  }

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
                    return RoomCard(
                      room: room,
                      onEyeTap: (roomCode, roomName, isLive) {
                        _showCameraViewDialog(roomCode, roomName, isLive);
                      },
                    );
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
  final Function(String, String, bool) onEyeTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.onEyeTap,
  });

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
              Row(
                children: [
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final roomCode = room['id'] as String;
                      final roomName = room['name'] as String;
                      final isLive = roomCode == 'B2'; // Only B2 is live
                      onEyeTap(roomCode, roomName, isLive);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: (room['id'] as String) == 'B2' ? Colors.green[400] : Colors.grey[400],
                        size: 15,
                      ),
                    ),
                  ),
                ],
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
          GestureDetector(
            onTap: () {
              final roomCode = room['id'] as String;
              final roomName = room['name'] as String;
              final isLive = roomCode == 'B2'; // Only B2 is live
              onEyeTap(roomCode, roomName, isLive);
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: room['statusColor']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: (room['id'] as String) == 'B2' ? Colors.greenAccent : Colors.grey[600],
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to view camera',
                      style: TextStyle(
                        color: (room['id'] as String) == 'B2' ? Colors.greenAccent : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

// ─────────────────────────────────────────
// CAMERA VIEW DIALOG
// ─────────────────────────────────────────

class _CameraViewDialog extends StatefulWidget {
  final String roomCode;
  final String roomName;
  final bool isLiveCamera;
  final Future<Map<String, dynamic>?> Function(String) fetchSnapshot;

  const _CameraViewDialog({
    required this.roomCode,
    required this.roomName,
    required this.isLiveCamera,
    required this.fetchSnapshot,
  });

  @override
  State<_CameraViewDialog> createState() => _CameraViewDialogState();
}

class _CameraViewDialogState extends State<_CameraViewDialog> {
  bool _isLoading = true;
  String? _imageBase64;
  String? _timestamp;
  String? _errorMessage;
  int _occupancy = 0;
  int _capacity = 0;
  String _status = '';
  double _confidence = 0;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageBase64 = null;
    });

    final data = await widget.fetchSnapshot(widget.roomCode);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (data != null && data['image_base64'] != null) {
        _imageBase64   = data['image_base64'];
        _timestamp     = data['timestamp'];
        _occupancy     = data['occupancy'] ?? 0;
        _capacity      = data['capacity'] ?? 0;
        _status        = data['status'] ?? '';
        _confidence    = (data['confidence'] ?? 0.0).toDouble();
      } else {
        _errorMessage =
            'Could not load camera feed.\n\nMake sure server_v3.py is running\non your computer.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _status == 'occupied'
        ? Colors.green
        : _status == 'waste'
            ? Colors.orange
            : Colors.grey;

    return Dialog(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF30363D)),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.videocam,
                  color: widget.isLiveCamera ? Colors.green : Colors.grey[400],
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // LIVE / SIMULATED badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.isLiveCamera
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isLiveCamera ? Colors.green : Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.isLiveCamera ? 'LIVE WEBCAM' : 'SIMULATED FEED',
                                  style: TextStyle(
                                    color: widget.isLiveCamera ? Colors.green : Colors.grey[400],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_timestamp != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _timestamp!,
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Refresh
                IconButton(
                  onPressed: _loadSnapshot,
                  icon: Icon(Icons.refresh, color: Colors.grey[400], size: 20),
                  tooltip: 'Refresh',
                ),
                // Close
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Camera Image ─────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 270,
                color: const Color(0xFF0D1117),
                child: _buildImageArea(),
              ),
            ),
            const SizedBox(height: 16),

            // ── AI Analysis Stats ────────────────────
            if (!_isLoading && _errorMessage == null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statBlock(
                      icon: Icons.people_outline,
                      label: 'People',
                      value: '$_occupancy/$_capacity',
                      color: Colors.white,
                    ),
                    _divider(),
                    _statBlock(
                      icon: Icons.circle,
                      label: 'Status',
                      value: _status.toUpperCase(),
                      color: statusColor,
                    ),
                    // Show confidence only for live room
                    if (widget.isLiveCamera) ...[
                      _divider(),
                      _statBlock(
                        icon: Icons.psychology_outlined,
                        label: 'AI Confidence',
                        value: '${(_confidence * 100).toInt()}%',
                        color: _confidence > 0.8 ? Colors.green : Colors.orange,
                      ),
                    ],
                  ],
                ),
              ),

            // ── Disclaimer for simulated rooms ───────
            if (!widget.isLiveCamera && !_isLoading && _errorMessage == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[600], size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Simulated feed. In production, a real IP camera '
                        'would be mounted in ${widget.roomName}.',
                        style: TextStyle(color: Colors.amber[700], fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Image area: loading / error / image ──
  Widget _buildImageArea() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
            SizedBox(height: 14),
            Text('Loading camera feed...', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, color: Colors.grey[700], size: 42),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // For simulated rooms (all except B2), draw a fake crowd image
    // that visually matches the detected occupancy instead of
    // relying on a real camera frame.
    if (!widget.isLiveCamera) {
      return _buildSimulatedOccupancyImage();
    }

    // Show live image with HUD overlay for B2
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(base64Decode(_imageBase64!), fit: BoxFit.cover),

        // Top-left: LIVE / CAM label
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isLiveCamera ? Colors.red : Colors.grey,
                  ),
                ),
                Text(
                  widget.isLiveCamera ? 'LIVE' : 'CAM ${widget.roomCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom-right: timestamp
        if (_timestamp != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _timestamp!,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  /// Simple fake image for non-B2 rooms that reflects people detected.
  Widget _buildSimulatedOccupancyImage() {
    final String? assetPath = _assetForSimulatedRoom(widget.roomCode);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (assetPath != null)
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
          )
        else
          Container(
            color: const Color(0xFF020617),
          ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'SIM ${widget.roomCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$_occupancy people detected',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  String? _assetForSimulatedRoom(String roomCode) {
    switch (roomCode) {
      case 'A1':
        return 'assets/images/conference_A1.jpg';
      case 'A2':
        return 'assets/images/office_A2.jpg';
      case 'B1':
        return 'assets/images/server_B1.jpg';
      case 'C1':
        return 'assets/images/lab_C1.jpg';
      case 'C2':
        return 'assets/images/training_C2.jpg';
      default:
        return null;
    }
  }

  Widget _statBlock({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: const Color(0xFF30363D));
  }
}
