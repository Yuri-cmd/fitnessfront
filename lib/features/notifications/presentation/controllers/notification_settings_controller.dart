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
  bool _isLoading = false;
  bool _isSaving = false;

  bool get workoutEnabled => _workoutEnabled;
  TimeOfDay get workoutTime => _workoutTime;
  bool get waterEnabled => _waterEnabled;
  List<TimeOfDay> get waterTimes => List.unmodifiable(_waterTimes);
  int get waterGoal => _waterGoal;
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

  void setWorkoutEnabled(bool value) {
    _workoutEnabled = value;
    notifyListeners();
  }

  void setWorkoutTime(TimeOfDay time) {
    _workoutTime = time;
    notifyListeners();
  }

  void setWaterEnabled(bool value) {
    _waterEnabled = value;
    notifyListeners();
  }

  void setWaterTime(int index, TimeOfDay time) {
    _waterTimes[index] = time;
    notifyListeners();
  }

  void addWaterTime(TimeOfDay time) {
    if (_waterTimes.length >= 6) return;
    _waterTimes.add(time);
    notifyListeners();
  }

  void removeWaterTime(int index) {
    if (_waterTimes.length <= 1) return;
    _waterTimes.removeAt(index);
    notifyListeners();
  }

  void setWaterGoal(int value) {
    _waterGoal = value.clamp(1, 20);
    notifyListeners();
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
