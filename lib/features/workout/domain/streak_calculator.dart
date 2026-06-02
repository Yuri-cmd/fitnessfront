import 'package:fit_tracker_app/features/workout/data/models/workout_log_model.dart';

/// Pure function — no GetX, no DateTime.now(). Fully testable.
///
/// [logs]            Historical workout logs for the current user.
/// [routineCount]    Number of active (non-archived) routines. Used to derive
///                   the max allowed gap between sessions before the streak
///                   breaks: more routines → higher expected frequency →
///                   shorter allowed gap.
/// [now]             The current moment (injectable so tests are deterministic).
/// [insertRoutineId] The routine just completed. If today has no log yet, a
///                   synthetic one is inserted so the streak counts the
///                   session being celebrated right now.
({int streak, List<bool> trainedDays}) calculateStreak({
  required List<WorkoutLog> logs,
  required int routineCount,
  required DateTime now,
  required int insertRoutineId,
}) {
  final mutableLogs = List<WorkoutLog>.from(logs);
  final today = DateTime(now.year, now.month, now.day);

  // Optimistically insert today if not already logged.
  final todayLogged = mutableLogs.any((log) {
    final d = log.completedAt;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  });
  if (!todayLogged) {
    mutableLogs.insert(0, WorkoutLog(completedAt: now, routineId: insertRoutineId));
  }

  // Allowed gap scales with training frequency:
  //   1 routine  → maxGap = 7 (can skip 6 days between sessions)
  //   3 routines → maxGap = 3 (can skip 2 days)
  //   7 routines → maxGap = 1 (must train every day)
  final frequency = routineCount.clamp(1, 7);
  final maxGapDays = (7.0 / frequency).ceil();

  // Unique training days, newest first.
  final uniqueDays = mutableLogs
      .map((log) {
        final d = log.completedAt;
        return DateTime(d.year, d.month, d.day);
      })
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  int streak = 0;
  if (uniqueDays.isNotEmpty &&
      today.difference(uniqueDays.first).inDays <= maxGapDays) {
    streak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      final gap = uniqueDays[i - 1].difference(uniqueDays[i]).inDays;
      if (gap <= maxGapDays) {
        streak++;
      } else {
        break;
      }
    }
  }

  // Which days of the current ISO week (Mon=0 … Sun=6) had at least one session.
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final trainedDays = List.generate(7, (i) {
    final day = monday.add(Duration(days: i));
    return mutableLogs.any((log) {
      final d = log.completedAt;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    });
  });

  return (streak: streak, trainedDays: trainedDays);
}
