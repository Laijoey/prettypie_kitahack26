// Simple in-memory user storage for demo purposes
// In production, use shared_preferences, SQLite, or a backend service

class UserData {
  final String email;
  final String password;
  final String name;
  final String staffId;
  final String userType; // 'staff' or 'manager'

  UserData({
    required this.email,
    required this.password,
    required this.name,
    required this.staffId,
    required this.userType,
  });
}

class UserStorage {
  // Singleton instance
  static final UserStorage _instance = UserStorage._internal();
  factory UserStorage() => _instance;
  UserStorage._internal();

  // Store users by email
  final Map<String, UserData> _users = {};

  // Register a new user
  void registerUser(UserData user) {
    _users[user.email.toLowerCase()] = user;
  }

  // Check if user exists
  bool userExists(String email) {
    return _users.containsKey(email.toLowerCase());
  }

  // Get user by email
  UserData? getUser(String email) {
    return _users[email.toLowerCase()];
  }

  // Validate login credentials
  UserData? validateLogin(String email, String password) {
    final user = _users[email.toLowerCase()];
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }
}
