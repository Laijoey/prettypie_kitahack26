/// Shared data models for GreenPulse.
/// Both manager_dashboard.dart and all staff pages import from here.

// ─────────────────────────────────────────
// ROOM MODELS
// ─────────────────────────────────────────

enum RoomStatus { occupied, empty, waste, critical }

class RoomData {
  final String code;
  final String name;
  final int occupancy;
  final int capacity;
  final RoomStatus status;
  final bool lightsOn;
  final bool acOn;
  final double energy; // kWh
  final double confidence;
  final String source;
  final List<String> devices;
  final String warning;

  const RoomData({
    required this.code,
    required this.name,
    required this.occupancy,
    required this.capacity,
    required this.status,
    required this.lightsOn,
    required this.acOn,
    required this.energy,
    this.confidence = 0.0,
    this.source = 'static',
    this.devices = const [],
    this.warning = '',
  });

  /// Human-readable occupancy string e.g. "8/12"
  String get occupancyLabel => '$occupancy/$capacity';

  /// Status label string matching manager dashboard display
  String get statusLabel {
    switch (status) {
      case RoomStatus.occupied:
        return occupancy >= capacity * 0.85 ? 'HIGH USAGE' : 'OPTIMAL';
      case RoomStatus.empty:
        return 'EMPTY';
      case RoomStatus.waste:
        return 'ENERGY WASTE DETECTED';
      case RoomStatus.critical:
        return 'CRITICAL';
    }
  }

  /// Colour associated with status
  /// (returns a numeric int so this file stays free of Flutter imports)
  int get statusColorValue {
    switch (status) {
      case RoomStatus.occupied:
        return occupancy >= capacity * 0.85
            ? 0xFFFF9800 // orange
            : 0xFF4CAF50; // green
      case RoomStatus.empty:
        return 0xFF9E9E9E; // grey
      case RoomStatus.waste:
        return 0xFFF44336; // red
      case RoomStatus.critical:
        return 0xFFF44336; // red
    }
  }

  /// Energy usage label
  String get energyLabel {
    switch (status) {
      case RoomStatus.waste:
        return 'Wasting';
      case RoomStatus.critical:
        return 'High';
      default:
        return 'Normal';
    }
  }

  RoomData copyWith({
    int? occupancy,
    RoomStatus? status,
    bool? lightsOn,
    bool? acOn,
    double? energy,
    double? confidence,
    String? source,
  }) {
    return RoomData(
      code: code,
      name: name,
      occupancy: occupancy ?? this.occupancy,
      capacity: capacity,
      status: status ?? this.status,
      lightsOn: lightsOn ?? this.lightsOn,
      acOn: acOn ?? this.acOn,
      energy: energy ?? this.energy,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      devices: devices,
      warning: warning,
    );
  }
}

// ─────────────────────────────────────────
// ALERT MODEL
// ─────────────────────────────────────────

class AlertData {
  final String type;      // 'CRITICAL' | 'WARNING' | 'INFO'
  final String message;
  final String time;
  final String roomName;

  const AlertData({
    required this.type,
    required this.message,
    required this.time,
    this.roomName = '',
  });
}

// ─────────────────────────────────────────
// ENERGY STATS MODEL
// ─────────────────────────────────────────

class EnergyStats {
  final double currentKw;
  final double todayCost;
  final double vsYesterdayPct; // negative = saving
  final double co2SavedTons;
  final double co2SavedMonthly;
  final double costSavedMonthly;
  final int treesEquivalent;
  final double energyReducedPct;
  final List<double> hourlyKw;         // 24 values (00:00–23:00)
  final List<double> monthlyKwh;       // 7 values (last 7 months)
  final List<double> monthlyCost;      // 7 values (last 7 months)
  final List<String> monthLabels;

  const EnergyStats({
    required this.currentKw,
    required this.todayCost,
    required this.vsYesterdayPct,
    required this.co2SavedTons,
    required this.co2SavedMonthly,
    required this.costSavedMonthly,
    required this.treesEquivalent,
    required this.energyReducedPct,
    required this.hourlyKw,
    required this.monthlyKwh,
    required this.monthlyCost,
    required this.monthLabels,
  });
}

// ─────────────────────────────────────────
// GAMIFICATION MODEL
// ─────────────────────────────────────────

class TaskItem {
  final String label;
  final bool completed;
  final int points;

  const TaskItem({
    required this.label,
    required this.completed,
    required this.points,
  });
}

class BadgeItem {
  final String emoji;
  final String name;
  final String description;
  final bool earned;

  const BadgeItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.earned,
  });
}

class GamificationData {
  final int totalPoints;
  final int streakDays;
  final List<TaskItem> tasks;
  final List<BadgeItem> badges;

  const GamificationData({
    required this.totalPoints,
    required this.streakDays,
    required this.tasks,
    required this.badges,
  });

  int get completedTasks => tasks.where((t) => t.completed).length;
  int get earnedBadges => badges.where((b) => b.earned).length;
}
