class WorkoutLog {
  final int? id;
  final int? routineId;
  final DateTime completedAt;
  final String? routineName;

  const WorkoutLog({
    this.id,
    this.routineId,
    required this.completedAt,
    this.routineName,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as int?,
        routineId: json['routine_id'] as int?,
        completedAt: DateTime.parse(json['completed_at'] as String).toLocal(),
        routineName:
            (json['routine'] as Map<String, dynamic>?)?['name'] as String?,
      );
}
