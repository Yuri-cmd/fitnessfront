class NotificationSettings {
  final bool workoutEnabled;
  final String workoutTime;
  final bool waterEnabled;
  final List<String> waterTimes;
  final int waterGoalGlasses;
  final bool morningEnabled;
  final String morningTime;
  final bool eveningEnabled;
  final String eveningTime;
  final bool birthdayEnabled;

  const NotificationSettings({
    required this.workoutEnabled,
    required this.workoutTime,
    required this.waterEnabled,
    required this.waterTimes,
    required this.waterGoalGlasses,
    required this.morningEnabled,
    required this.morningTime,
    required this.eveningEnabled,
    required this.eveningTime,
    required this.birthdayEnabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        workoutEnabled: json['workout_reminder_enabled'] as bool,
        workoutTime: json['workout_reminder_time'] as String,
        waterEnabled: json['water_reminder_enabled'] as bool,
        waterTimes: List<String>.from(
            (json['water_reminder_times'] as List).cast<String>()),
        waterGoalGlasses: (json['water_goal_glasses'] as num).toInt(),
        morningEnabled:
            json['morning_motivation_enabled'] as bool? ?? true,
        morningTime:
            json['morning_motivation_time'] as String? ?? '07:00',
        eveningEnabled:
            json['evening_motivation_enabled'] as bool? ?? true,
        eveningTime:
            json['evening_motivation_time'] as String? ?? '21:00',
        birthdayEnabled:
            json['birthday_notification_enabled'] as bool? ?? true,
      );
}
