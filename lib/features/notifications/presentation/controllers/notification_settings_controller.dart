import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/notifications/data/models/notification_settings_model.dart';
import 'package:fit_tracker_app/features/notifications/data/services/notification_settings_service.dart';

class NotificationSettingsController extends GetxController {
  final NotificationSettingsService _service;
  NotificationSettingsController(this._service);

  final workoutEnabled = true.obs;
  final workoutTime = const TimeOfDay(hour: 20, minute: 0).obs;
  final waterEnabled = true.obs;
  final waterTimes = <TimeOfDay>[
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
  ].obs;
  final waterGoal = 8.obs;
  final morningEnabled = true.obs;
  final morningTime = const TimeOfDay(hour: 7, minute: 0).obs;
  final eveningEnabled = true.obs;
  final eveningTime = const TimeOfDay(hour: 21, minute: 0).obs;
  final birthdayEnabled = true.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final response = await _service.getSettings();
      if (response.statusCode == 200) {
        final s = NotificationSettings.fromJson(
            response.data as Map<String, dynamic>);
        workoutEnabled.value = s.workoutEnabled;
        workoutTime.value = _parseTime(s.workoutTime);
        waterEnabled.value = s.waterEnabled;
        waterTimes.value = s.waterTimes.map(_parseTime).toList();
        waterGoal.value = s.waterGoalGlasses;
        morningEnabled.value = s.morningEnabled;
        morningTime.value = _parseTime(s.morningTime);
        eveningEnabled.value = s.eveningEnabled;
        eveningTime.value = _parseTime(s.eveningTime);
        birthdayEnabled.value = s.birthdayEnabled;
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
    isLoading.value = false;
  }

  Future<bool> save() async {
    isSaving.value = true;
    try {
      final response = await _service.updateSettings({
        'workout_reminder_enabled': workoutEnabled.value,
        'workout_reminder_time': formatTime(workoutTime.value),
        'water_reminder_enabled': waterEnabled.value,
        'water_reminder_times': waterTimes.map(formatTime).toList(),
        'water_goal_glasses': waterGoal.value,
        'morning_motivation_enabled': morningEnabled.value,
        'morning_motivation_time': formatTime(morningTime.value),
        'evening_motivation_enabled': eveningEnabled.value,
        'evening_motivation_time': formatTime(eveningTime.value),
        'birthday_notification_enabled': birthdayEnabled.value,
      });
      isSaving.value = false;
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
    isSaving.value = false;
    return false;
  }

  void setWorkoutEnabled(bool v) => workoutEnabled.value = v;
  void setWorkoutTime(TimeOfDay t) => workoutTime.value = t;
  void setWaterEnabled(bool v) => waterEnabled.value = v;
  void setWaterTime(int i, TimeOfDay t) => waterTimes[i] = t;
  void addWaterTime(TimeOfDay t) { if (waterTimes.length < 6) waterTimes.add(t); }
  void removeWaterTime(int i) { if (waterTimes.length > 1) waterTimes.removeAt(i); }
  void setWaterGoal(int v) => waterGoal.value = v.clamp(1, 20);
  void setMorningEnabled(bool v) => morningEnabled.value = v;
  void setMorningTime(TimeOfDay t) => morningTime.value = t;
  void setEveningEnabled(bool v) => eveningEnabled.value = v;
  void setEveningTime(TimeOfDay t) => eveningTime.value = t;
  void setBirthdayEnabled(bool v) => birthdayEnabled.value = v;

  static TimeOfDay parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay _parseTime(String hhmm) => parseTime(hhmm);
}
