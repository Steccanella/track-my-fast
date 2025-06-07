import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fasting_session.dart';
import '../models/weight_entry.dart';
import '../models/daily_entry.dart';

class StorageService {
  static const String _sessionsKey = 'fasting_sessions';
  static const String _selectedFastingTypeKey = 'selected_fasting_type';
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _weightEntriesKey = 'weight_entries';
  static const String _dailyEntriesKey = 'daily_entries';

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

  Future<void> updateFastingSession(FastingSession updatedSession) async {
    final sessions = await getFastingSessions();
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      sessions[index] = updatedSession;
      await _prefs.setString(
        _sessionsKey,
        json.encode(sessions.map((s) => s.toJson()).toList()),
      );
    }
  }

  Future<void> deleteFastingSession(String sessionId) async {
    final sessions = await getFastingSessions();
    sessions.removeWhere((s) => s.id == sessionId);
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

  // Weight Entries
  Future<List<WeightEntry>> getWeightEntries() async {
    final String? entriesJson = _prefs.getString(_weightEntriesKey);
    if (entriesJson == null) return [];

    final List<dynamic> entriesList = json.decode(entriesJson);
    return entriesList.map((entry) => WeightEntry.fromJson(entry)).toList();
  }

  Future<void> saveWeightEntry(WeightEntry entry) async {
    final entries = await getWeightEntries();
    entries.add(entry);
    // Sort by date, most recent first
    entries.sort((a, b) => b.date.compareTo(a.date));
    await _prefs.setString(
      _weightEntriesKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteWeightEntry(WeightEntry entry) async {
    final entries = await getWeightEntries();
    entries.removeWhere(
        (e) => e.date.isAtSameMomentAs(entry.date) && e.weight == entry.weight);
    await _prefs.setString(
      _weightEntriesKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  // Daily Entries
  Future<List<DailyEntry>> getDailyEntries() async {
    final String? entriesJson = _prefs.getString(_dailyEntriesKey);
    if (entriesJson == null) return [];

    final List<dynamic> entriesList = json.decode(entriesJson);
    return entriesList.map((entry) => DailyEntry.fromJson(entry)).toList();
  }

  Future<void> saveDailyEntry(DailyEntry entry) async {
    final entries = await getDailyEntries();

    // Remove existing entry for the same date if any
    entries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);

    entries.add(entry);
    // Sort by date, most recent first
    entries.sort((a, b) => b.date.compareTo(a.date));

    await _prefs.setString(
      _dailyEntriesKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateDailyEntry(DailyEntry updatedEntry) async {
    final entries = await getDailyEntries();
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      await _prefs.setString(
        _dailyEntriesKey,
        json.encode(entries.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<void> deleteDailyEntry(String entryId) async {
    final entries = await getDailyEntries();
    entries.removeWhere((e) => e.id == entryId);
    await _prefs.setString(
      _dailyEntriesKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<DailyEntry?> getDailyEntryForDate(DateTime date) async {
    final entries = await getDailyEntries();
    try {
      return entries.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (e) {
      return null;
    }
  }
}
