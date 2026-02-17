// lib/services/vision_ai_service.dart
// Drop this file into your Flutter project under lib/services/

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ==========================================
// DATA MODELS
// ==========================================

enum RoomStatus { occupied, empty, waste }

class RoomData {
  final String code;
  final String name;
  final int occupancy;
  final int capacity;
  final RoomStatus status;
  final bool lightsOn;
  final bool acOn;
  final int energy;
  final double confidence;
  final String source; // "vision_ai", "static", "demo_simulated"

  RoomData({
    required this.code,
    required this.name,
    required this.occupancy,
    required this.capacity,
    required this.status,
    required this.lightsOn,
    required this.acOn,
    required this.energy,
    required this.confidence,
    required this.source,
  });

  factory RoomData.fromJson(Map<String, dynamic> json) {
    RoomStatus status;
    switch (json['status']) {
      case 'occupied':
        status = RoomStatus.occupied;
        break;
      case 'waste':
        status = RoomStatus.waste;
        break;
      default:
        status = RoomStatus.empty;
    }

    return RoomData(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      occupancy: json['occupancy'] ?? 0,
      capacity: json['capacity'] ?? 0,
      status: status,
      lightsOn: json['lights'] ?? false,
      acOn: json['ac'] ?? false,
      energy: json['energy'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      source: json['source'] ?? 'unknown',
    );
  }

  // Occupancy display string e.g. "8/12"
  String get occupancyDisplay => '$occupancy/$capacity';

  // True if data comes from real Vision AI
  bool get isLiveData => source == 'vision_ai';
}

class AlertData {
  final String type;     // CRITICAL, WARNING, INFO
  final String roomId;
  final String roomName;
  final String message;
  final String time;

  AlertData({
    required this.type,
    required this.roomId,
    required this.roomName,
    required this.message,
    required this.time,
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    return AlertData(
      type: json['type'] ?? 'INFO',
      roomId: json['room_id'] ?? '',
      roomName: json['room_name'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

// ==========================================
// VISION AI SERVICE
// ==========================================

class VisionAIService {
  // ⚠️ Change this to your computer's IP when running on a phone/tablet
  // For emulator use: http://10.0.2.2:5000
  // For physical device: http://YOUR_LOCAL_IP:5000 (e.g. http://192.168.1.100:5000)
  static const String _baseUrl = 'http://localhost:5000';

  static const Duration _pollInterval = Duration(seconds: 5);

  // Streams that the UI subscribes to
  final StreamController<List<RoomData>> _roomsController =
      StreamController<List<RoomData>>.broadcast();
  final StreamController<List<AlertData>> _alertsController =
      StreamController<List<AlertData>>.broadcast();

  Stream<List<RoomData>> get roomsStream => _roomsController.stream;
  Stream<List<AlertData>> get alertsStream => _alertsController.stream;

  Timer? _pollTimer;
  bool _isRunning = false;

  // ==========================================
  // START / STOP POLLING
  // ==========================================

  void startPolling() {
    if (_isRunning) return;
    _isRunning = true;

    // Fetch immediately on start
    _fetchAll();

    // Then keep polling every 5 seconds
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchAll());

    print('[VisionAI] Polling started at $_baseUrl');
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _isRunning = false;
    print('[VisionAI] Polling stopped.');
  }

  void dispose() {
    stopPolling();
    _roomsController.close();
    _alertsController.close();
  }

  // ==========================================
  // FETCH METHODS
  // ==========================================

  Future<void> _fetchAll() async {
    await Future.wait([fetchRooms(), fetchAlerts()]);
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/rooms'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final rooms = data.map((r) => RoomData.fromJson(r)).toList();
        _roomsController.add(rooms);
      }
    } catch (e) {
      print('[VisionAI] fetchRooms error: $e');
    }
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alerts'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final alerts = data.map((a) => AlertData.fromJson(a)).toList();
        _alertsController.add(alerts);
      }
    } catch (e) {
      print('[VisionAI] fetchAlerts error: $e');
    }
  }

  Future<List<RoomData>> getRoomsOnce() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/rooms'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((r) => RoomData.fromJson(r)).toList();
      }
    } catch (e) {
      print('[VisionAI] getRoomsOnce error: $e');
    }
    return [];
  }
}