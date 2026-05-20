import 'package:flutter/material.dart';
import '../../data/services/notification_settings_service.dart';

class NotificationSettingsController with ChangeNotifier {
  final NotificationSettingsService _service;

  NotificationSettingsController(this._service);

  bool _workoutEnabled = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 20, minute: 0);
  bool _waterEnabled = true;
  List<TimeOfDay> _waterTimes = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
  ];
  int _waterGoal = 8;
  bool _morningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  bool _eveningEnabled = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);
  bool _birthdayEnabled = true;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get workoutEnabled => _workoutEnabled;
  TimeOfDay get workoutTime => _workoutTime;
  bool get waterEnabled => _waterEnabled;
  List<TimeOfDay> get waterTimes => List.unmodifiable(_waterTimes);
  int get waterGoal => _waterGoal;
  bool get morningEnabled => _morningEnabled;
  TimeOfDay get morningTime => _morningTime;
  bool get eveningEnabled => _eveningEnabled;
  TimeOfDay get eveningTime => _eveningTime;
  bool get birthdayEnabled => _birthdayEnabled;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getSettings();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _workoutEnabled = data['workout_reminder_enabled'] as bool;
        _workoutTime = _parseTime(data['workout_reminder_time'] as String);
        _waterEnabled = data['water_reminder_enabled'] as bool;
        _waterTimes = (data['water_reminder_times'] as List)
            .map((t) => _parseTime(t as String))
            .toList();
        _waterGoal = (data['water_goal_glasses'] as num).toInt();
        _morningEnabled = data['morning_motivation_enabled'] as bool? ?? true;
        _morningTime = _parseTime(data['morning_motivation_time'] as String? ?? '07:00');
        _eveningEnabled = data['evening_motivation_enabled'] as bool? ?? true;
        _eveningTime = _parseTime(data['evening_motivation_time'] as String? ?? '21:00');
        _birthdayEnabled = data['birthday_notification_enabled'] as bool? ?? true;
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> save() async {
    _isSaving = true;
    notifyListeners();
    try {
      final response = await _service.updateSettings({
        'workout_reminder_enabled': _workoutEnabled,
        'workout_reminder_time': _formatTime(_workoutTime),
        'water_reminder_enabled': _waterEnabled,
        'water_reminder_times': _waterTimes.map(_formatTime).toList(),
        'water_goal_glasses': _waterGoal,
        'morning_motivation_enabled': _morningEnabled,
        'morning_motivation_time': _formatTime(_morningTime),
        'evening_motivation_enabled': _eveningEnabled,
        'evening_motivation_time': _formatTime(_eveningTime),
        'birthday_notification_enabled': _birthdayEnabled,
      });
      if (response.statusCode == 200) {
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
    _isSaving = false;
    notifyListeners();
    return false;
  }

  void setWorkoutEnabled(bool v) { _workoutEnabled = v; notifyListeners(); }
  void setWorkoutTime(TimeOfDay t) { _workoutTime = t; notifyListeners(); }
  void setWaterEnabled(bool v) { _waterEnabled = v; notifyListeners(); }
  void setWaterTime(int i, TimeOfDay t) { _waterTimes[i] = t; notifyListeners(); }
  void addWaterTime(TimeOfDay t) {
    if (_waterTimes.length >= 6) return;
    _waterTimes.add(t);
    notifyListeners();
  }
  void removeWaterTime(int i) {
    if (_waterTimes.length <= 1) return;
    _waterTimes.removeAt(i);
    notifyListeners();
  }
  void setWaterGoal(int v) { _waterGoal = v.clamp(1, 20); notifyListeners(); }
  void setMorningEnabled(bool v) { _morningEnabled = v; notifyListeners(); }
  void setMorningTime(TimeOfDay t) { _morningTime = t; notifyListeners(); }
  void setEveningEnabled(bool v) { _eveningEnabled = v; notifyListeners(); }
  void setEveningTime(TimeOfDay t) { _eveningTime = t; notifyListeners(); }
  void setBirthdayEnabled(bool v) { _birthdayEnabled = v; notifyListeners(); }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
