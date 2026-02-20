import 'dart:async';
import '../models/app_models.dart';

/// AppDataService — singleton that acts as the single source of truth
/// for all live data in GreenPulse.
///
/// Flow:
///   Manager side  →  VisionAIService  →  AppDataService.updateRooms / updateAlerts
///   Staff side    →  AppDataService.roomsStream / alertsStream / energyStream / gamificationStream
///
/// Usage:
///   final svc = AppDataService();
///   svc.roomsStream.listen((rooms) { ... });
class AppDataService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;
  AppDataService._internal() {
    // Pre-seed streams with static defaults so staff pages
    // always have data even before VisionAI first responds.
    _currentRooms = _defaultRooms();
    _currentAlerts = _defaultAlerts();
    _currentEnergy = _defaultEnergy();
    _currentGamification = _defaultGamification();
  }

  // ─── Rooms ────────────────────────────────────────────────────────────────
  late List<RoomData> _currentRooms;
  final _roomsController =
      StreamController<List<RoomData>>.broadcast();

  Stream<List<RoomData>> get roomsStream => _roomsController.stream;
  List<RoomData> get currentRooms => _currentRooms;

  /// Called by the manager side (VisionAIService listener) to push live data.
  void updateRooms(List<RoomData> rooms) {
    _currentRooms = rooms;
    _roomsController.add(rooms);
  }

  // ─── Alerts ───────────────────────────────────────────────────────────────
  late List<AlertData> _currentAlerts;
  final _alertsController =
      StreamController<List<AlertData>>.broadcast();

  Stream<List<AlertData>> get alertsStream => _alertsController.stream;
  List<AlertData> get currentAlerts => _currentAlerts;

  void updateAlerts(List<AlertData> alerts) {
    _currentAlerts = alerts;
    _alertsController.add(alerts);
  }

  // ─── Energy Stats ─────────────────────────────────────────────────────────
  late EnergyStats _currentEnergy;
  final _energyController =
      StreamController<EnergyStats>.broadcast();

  Stream<EnergyStats> get energyStream => _energyController.stream;
  EnergyStats get currentEnergy => _currentEnergy;

  void updateEnergy(EnergyStats stats) {
    _currentEnergy = stats;
    _energyController.add(stats);
  }

  // ─── Gamification ─────────────────────────────────────────────────────────
  late GamificationData _currentGamification;
  final _gamificationController =
      StreamController<GamificationData>.broadcast();

  Stream<GamificationData> get gamificationStream =>
      _gamificationController.stream;
  GamificationData get currentGamification => _currentGamification;

  void updateGamification(GamificationData data) {
    _currentGamification = data;
    _gamificationController.add(data);
  }

  /// Toggle a single task completion for the current user.
  void toggleTask(int index) {
    final tasks = List<TaskItem>.from(_currentGamification.tasks);
    final old = tasks[index];
    tasks[index] = TaskItem(
      label: old.label,
      completed: !old.completed,
      points: old.points,
    );
    final totalPoints = tasks
        .where((t) => t.completed)
        .fold(0, (sum, t) => sum + t.points);
    final updated = GamificationData(
      totalPoints: totalPoints,
      streakDays: _currentGamification.streakDays,
      tasks: tasks,
      badges: _currentGamification.badges,
    );
    updateGamification(updated);
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────
  void dispose() {
    _roomsController.close();
    _alertsController.close();
    _energyController.close();
    _gamificationController.close();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEFAULT DATA  (matches manager_dashboard._staticRooms() exactly)
  // ═══════════════════════════════════════════════════════════════════════════

  static List<RoomData> _defaultRooms() => [
        const RoomData(
          code: 'A1',
          name: 'Conference Room A',
          occupancy: 8,
          capacity: 12,
          status: RoomStatus.occupied,
          lightsOn: true,
          acOn: true,
          energy: 18,
          devices: ['HVAC', 'Lights', 'Display'],
        ),
        const RoomData(
          code: 'A2',
          name: 'Open Office A',
          occupancy: 24,
          capacity: 40,
          status: RoomStatus.occupied,
          lightsOn: true,
          acOn: true,
          energy: 32,
          devices: ['HVAC', 'Lights', 'Workstations'],
        ),
        const RoomData(
          code: 'B1',
          name: 'Server Room',
          occupancy: 0,
          capacity: 4,
          status: RoomStatus.critical,
          lightsOn: false,
          acOn: true,
          energy: 45,
          devices: ['Cooling', 'Servers', 'UPS'],
        ),
        const RoomData(
          code: 'B2',
          name: 'Break Room',
          occupancy: 0,
          capacity: 20,
          status: RoomStatus.waste,
          lightsOn: true,
          acOn: true,
          energy: 12,
          devices: ['HVAC', 'Lights', 'Appliances'],
          warning:
              '⚠ Devices active in empty room — AI recommends auto-shutdown',
        ),
        const RoomData(
          code: 'C1',
          name: 'Lab Space',
          occupancy: 6,
          capacity: 15,
          status: RoomStatus.occupied,
          lightsOn: true,
          acOn: true,
          energy: 28,
          devices: ['HVAC', 'Lights', 'Equipment'],
        ),
        const RoomData(
          code: 'C2',
          name: 'Training Room',
          occupancy: 0,
          capacity: 30,
          status: RoomStatus.waste,
          lightsOn: true,
          acOn: true,
          energy: 22,
          devices: ['HVAC', 'Lights', 'Projector'],
          warning:
              '⚠ Devices active in empty room — AI recommends auto-shutdown',
        ),
      ];

  static List<AlertData> _defaultAlerts() => [
        const AlertData(
          type: 'CRITICAL',
          message: 'Unusual energy spike detected in Building A, Floor 3',
          time: 'Just now',
          roomName: 'A1',
        ),
        const AlertData(
          type: 'WARNING',
          message: 'HVAC running in unoccupied zone B2',
          time: '5m ago',
          roomName: 'B2',
        ),
        const AlertData(
          type: 'INFO',
          message: 'Consistent after-hours usage detected',
          time: '12m ago',
          roomName: '',
        ),
      ];

  static EnergyStats _defaultEnergy() => const EnergyStats(
        currentKw: 72,
        todayCost: 48.20,
        vsYesterdayPct: -15,
        co2SavedTons: 2.4,
        co2SavedMonthly: 2.4,
        costSavedMonthly: 1280,
        treesEquivalent: 12,
        energyReducedPct: 15.3,
        hourlyKw: [
          45, 42, 38, 35, 33, 36, 50, 68, 82, 88,
          85, 80, 76, 79, 83, 87, 90, 84, 72, 60,
          52, 50, 48, 45,
        ],
        monthlyKwh: [22000, 24000, 21000, 19500, 18000, 20000, 17500],
        monthlyCost: [2600, 2900, 2500, 2300, 2100, 2400, 2000],
        monthLabels: ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      );

  static GamificationData _defaultGamification() => const GamificationData(
        totalPoints: 30,
        streakDays: 7,
        tasks: [
          TaskItem(label: 'Turn off monitors before leaving',            completed: true,  points: 10),
          TaskItem(label: 'Use natural light when possible',             completed: true,  points: 15),
          TaskItem(label: 'Report any energy waste you notice',          completed: false, points: 20),
          TaskItem(label: 'Unplug chargers when not in use',             completed: false, points: 10),
          TaskItem(label: 'Use stairs instead of elevator (below 3 fl)', completed: true,  points: 5),
          TaskItem(label: 'Set thermostat to eco mode',                  completed: false, points: 25),
        ],
        badges: [
          BadgeItem(emoji: '🌱', name: 'First Saver',   description: '✓ Earned',        earned: true),
          BadgeItem(emoji: '⚡', name: 'Week Warrior',   description: '✓ Earned',        earned: true),
          BadgeItem(emoji: '🏆', name: 'Eco Champion',  description: 'Earn 500+ points', earned: false),
          BadgeItem(emoji: '🔥', name: 'Green Streak',  description: '30-day streak',    earned: false),
          BadgeItem(emoji: '👑', name: 'Team Leader',   description: '✓ Earned',         earned: true),
          BadgeItem(emoji: '🌍', name: 'Carbon Zero',   description: 'Reduce emissions', earned: false),
        ],
      );
}
