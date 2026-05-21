class WeightHistory {
  final double weight;
  final DateTime createdAt;

  const WeightHistory({required this.weight, required this.createdAt});

  factory WeightHistory.fromJson(Map<String, dynamic> json) => WeightHistory(
        weight: (json['weight'] as num).toDouble(),
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
        totalVolume: (json['total_volume'] as num).toDouble(),
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
        maxWeight: (json['max_weight'] as num).toDouble(),
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
