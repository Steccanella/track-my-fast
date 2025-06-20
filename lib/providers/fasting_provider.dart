import 'package:flutter/material.dart';
import 'dart:async';
import '../models/fasting_type.dart';
import '../models/fasting_session.dart';
import '../models/weight_entry.dart';
import '../models/daily_entry.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class FastingProvider extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;

  FastingSession? _currentSession;
  List<FastingSession> _history = [];
  List<WeightEntry> _weightEntries = [];
  List<DailyEntry> _dailyEntries = [];
  FastingType _selectedType = FastingType.presetTypes[0];
  bool _notificationsEnabled = true;
  Timer? _timer;

  FastingProvider(this._storage, this._notifications) {
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  FastingSession? get currentSession => _currentSession;
  List<FastingSession> get history => _history;
  List<WeightEntry> get weightEntries => _weightEntries;
  List<DailyEntry> get dailyEntries => _dailyEntries;
  FastingType get selectedType => _selectedType;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadData() async {
    _history = await _storage.getFastingSessions();
    _weightEntries = await _storage.getWeightEntries();
    _dailyEntries = await _storage.getDailyEntries();
    final selectedTypeName = await _storage.getSelectedFastingType();
    if (selectedTypeName != null) {
      try {
        _selectedType = FastingType.presetTypes.firstWhere(
          (type) => type.name == selectedTypeName,
        );
      } catch (e) {
        // If the selected type is not found (maybe old data), default to first one
        _selectedType = FastingType.presetTypes[0];
        // Save the new default selection
        await _storage.saveSelectedFastingType(_selectedType.name);
      }
    } else {
      // No stored selection, use default and save it
      _selectedType = FastingType.presetTypes[0];
      await _storage.saveSelectedFastingType(_selectedType.name);
    }
    _notificationsEnabled = await _storage.getNotificationsEnabled();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null) {
        // Just notify listeners, don't auto-stop the timer
        // User manually decides when to stop
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> startFasting() async {
    if (_currentSession != null) return;

    _currentSession = FastingSession(
      startTime: DateTime.now(),
      fastingTypeName: _selectedType.name,
      targetDuration: _selectedType.fastingDuration,
    );

    _startTimer();

    if (_notificationsEnabled) {
      // Schedule notifications at 25%, 50%, 75%, and completion
      final milestones = [0.25, 0.5, 0.75, 1.0];
      for (final milestone in milestones) {
        final duration = Duration(
          minutes:
              (_selectedType.fastingDuration.inMinutes * milestone).round(),
        );
        final scheduledTime = DateTime.now().add(duration);

        await _notifications.scheduleFastingMilestone(
          scheduledTime: scheduledTime,
          title: 'Fasting Milestone',
          body: '${(milestone * 100).round()}% of your fast completed!',
        );
      }
    }

    notifyListeners();
  }

  Future<void> stopFasting({bool completed = false}) async {
    if (_currentSession == null) return;

    _timer?.cancel();

    final session = FastingSession(
      startTime: _currentSession!.startTime,
      endTime: DateTime.now(),
      fastingTypeName: _currentSession!.fastingTypeName,
      targetDuration: _currentSession!.targetDuration,
      completed: completed,
    );

    await _storage.saveFastingSession(session);
    _history.add(session);
    _currentSession = null;
    notifyListeners();
  }

  Future<void> setSelectedType(FastingType type) async {
    _selectedType = type;
    await _storage.saveSelectedFastingType(type.name);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storage.saveNotificationsEnabled(enabled);
    notifyListeners();
  }

  String get currentProgress {
    if (_currentSession == null) return '0%';
    return '${(_currentSession!.progressPercentage * 100).round()}%';
  }

  Duration get remainingTime {
    if (_currentSession == null) return Duration.zero;
    final remaining =
        _currentSession!.targetDuration - _currentSession!.actualDuration;
    return remaining;
  }

  Duration get overtimeAmount {
    if (_currentSession == null) return Duration.zero;
    final remaining = remainingTime;
    return remaining.isNegative ? remaining.abs() : Duration.zero;
  }

  bool get isOvertime {
    return remainingTime.isNegative;
  }

  Duration get elapsedTime {
    if (_currentSession == null) return Duration.zero;
    return _currentSession!.actualDuration;
  }

  double get progressPercentage {
    if (_currentSession == null) return 0.0;
    return _currentSession!.progressPercentage;
  }

  // Weight tracking methods
  Future<void> addWeightEntry(WeightEntry entry) async {
    await _storage.saveWeightEntry(entry);
    _weightEntries = await _storage.getWeightEntries();
    notifyListeners();
  }

  Future<void> deleteWeightEntry(WeightEntry entry) async {
    await _storage.deleteWeightEntry(entry);
    _weightEntries = await _storage.getWeightEntries();
    notifyListeners();
  }

  WeightEntry? get latestWeightEntry {
    if (_weightEntries.isEmpty) return null;
    return _weightEntries.first;
  }

  Future<void> updateFastingSession(FastingSession session) async {
    await _storage.updateFastingSession(session);
    _history = await _storage.getFastingSessions();
    notifyListeners();
  }

  Future<void> deleteFastingSession(String sessionId) async {
    await _storage.deleteFastingSession(sessionId);
    _history = await _storage.getFastingSessions();
    notifyListeners();
  }

  // Daily entry methods
  Future<void> saveDailyEntry(DailyEntry entry) async {
    await _storage.saveDailyEntry(entry);
    _dailyEntries = await _storage.getDailyEntries();
    notifyListeners();
  }

  Future<void> updateDailyEntry(DailyEntry entry) async {
    await _storage.updateDailyEntry(entry);
    _dailyEntries = await _storage.getDailyEntries();
    notifyListeners();
  }

  Future<void> deleteDailyEntry(String entryId) async {
    await _storage.deleteDailyEntry(entryId);
    _dailyEntries = await _storage.getDailyEntries();
    notifyListeners();
  }

  DailyEntry? getDailyEntryForDate(DateTime date) {
    try {
      return _dailyEntries.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (e) {
      return null;
    }
  }

  DailyEntry? get todaysDailyEntry {
    return getDailyEntryForDate(DateTime.now());
  }
}
