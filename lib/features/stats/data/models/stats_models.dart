class WeightHistory {
  final double weight;
  final DateTime createdAt;

  const WeightHistory({required this.weight, required this.createdAt});

  factory WeightHistory.fromJson(Map<String, dynamic> json) => WeightHistory(
        weight: double.parse(json['weight'].toString()),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class VolumeByMuscle {
  final String muscleGroup;
  final double totalVolume;

  const VolumeByMuscle({
    required this.muscleGroup,
    required this.totalVolume,
  });

  factory VolumeByMuscle.fromJson(Map<String, dynamic> json) => VolumeByMuscle(
        muscleGroup: json['muscle_group']?.toString() ?? '',
        totalVolume: double.parse(json['total_volume'].toString()),
      );
}

class ActivityDay {
  final String date;
  final int count;

  const ActivityDay({required this.date, required this.count});

  factory ActivityDay.fromJson(Map<String, dynamic> json) => ActivityDay(
        date: json['date'].toString(),
        count: (json['count'] as num).toInt(),
      );
}

class PersonalRecord {
  final int? id;
  final String name;
  final String? muscleGroup;
  final double maxWeight;

  const PersonalRecord({
    this.id,
    required this.name,
    this.muscleGroup,
    required this.maxWeight,
  });

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
        id: json['id'] as int?,
        name: json['name']?.toString() ?? 'Ejercicio',
        muscleGroup: json['muscle_group']?.toString(),
        maxWeight: double.parse(json['max_weight'].toString()),
      );
}

class ExerciseProgressPoint {
  final String date;
  final double maxWeight;
  final int totalReps;
  final double sessionVolume;

  const ExerciseProgressPoint({
    required this.date,
    required this.maxWeight,
    required this.totalReps,
    required this.sessionVolume,
  });

  factory ExerciseProgressPoint.fromJson(Map<String, dynamic> json) =>
      ExerciseProgressPoint(
        date: json['date'].toString(),
        maxWeight: double.parse(json['max_weight'].toString()),
        totalReps: (json['total_reps'] as num).toInt(),
        sessionVolume: double.parse(json['session_volume'].toString()),
      );
}

class RoutineProgressPoint {
  final String date;
  final double totalVolume;
  final int exercisesCount;
  final int totalSets;

  const RoutineProgressPoint({
    required this.date,
    required this.totalVolume,
    required this.exercisesCount,
    required this.totalSets,
  });

  factory RoutineProgressPoint.fromJson(Map<String, dynamic> json) =>
      RoutineProgressPoint(
        date: json['date'].toString(),
        totalVolume: double.parse(json['total_volume'].toString()),
        exercisesCount: (json['exercises_count'] as num).toInt(),
        totalSets: (json['total_sets'] as num).toInt(),
      );
}

class AchievementPivot {
  final DateTime? earnedAt;

  const AchievementPivot({this.earnedAt});

  factory AchievementPivot.fromJson(Map<String, dynamic> json) =>
      AchievementPivot(
        earnedAt: json['earned_at'] != null
            ? DateTime.tryParse(json['earned_at'].toString())
            : null,
      );
}

class Achievement {
  final int? id;
  final String? icon;
  final String name;
  final String? description;
  final AchievementPivot? pivot;

  const Achievement({
    this.id,
    this.icon,
    required this.name,
    this.description,
    this.pivot,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as int?,
        icon: json['icon']?.toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        pivot: json['pivot'] != null
            ? AchievementPivot.fromJson(
                json['pivot'] as Map<String, dynamic>)
            : null,
      );
}
