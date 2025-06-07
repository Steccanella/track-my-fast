import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fasting_session.dart';

class StorageService {
  static const String _sessionsKey = 'fasting_sessions';
  static const String _selectedFastingTypeKey = 'selected_fasting_type';
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Fasting Sessions
  Future<List<FastingSession>> getFastingSessions() async {
    final String? sessionsJson = _prefs.getString(_sessionsKey);
    if (sessionsJson == null) return [];

    final List<dynamic> sessionsList = json.decode(sessionsJson);
    return sessionsList
        .map((session) => FastingSession.fromJson(session))
        .toList();
  }

  Future<void> saveFastingSession(FastingSession session) async {
    final sessions = await getFastingSessions();
    sessions.add(session);
    await _prefs.setString(
      _sessionsKey,
      json.encode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  // Selected Fasting Type
  Future<String?> getSelectedFastingType() async {
    return _prefs.getString(_selectedFastingTypeKey);
  }

  Future<void> saveSelectedFastingType(String typeName) async {
    await _prefs.setString(_selectedFastingTypeKey, typeName);
  }

  // Theme
  Future<String?> getThemeMode() async {
    return _prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  // Notifications
  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }
}
