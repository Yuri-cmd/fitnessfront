class ExercisePivot {
  final int sets;
  final int reps;
  final int? repsMax;
  final int warmupSets;
  final String? warmupReps;

  const ExercisePivot({
    required this.sets,
    required this.reps,
    this.repsMax,
    this.warmupSets = 0,
    this.warmupReps,
  });

  factory ExercisePivot.fromJson(Map<String, dynamic> json) => ExercisePivot(
        sets: (json['sets'] as num).toInt(),
        reps: (json['reps'] as num).toInt(),
        repsMax: json['reps_max'] != null ? (json['reps_max'] as num).toInt() : null,
        warmupSets: json['warmup_sets'] != null ? (json['warmup_sets'] as num).toInt() : 0,
        warmupReps: json['warmup_reps'] as String?,
      );

  /// "8-12" when repsMax is set, otherwise "12".
  String get repsDisplay => repsMax != null ? '$reps-$repsMax' : '$reps';

  int get totalSets => warmupSets + sets;
}

class Exercise {
  final int id;
  final String name;
  final String? muscleGroup;
  final ExercisePivot? pivot;

  const Exercise({
    required this.id,
    required this.name,
    this.muscleGroup,
    this.pivot,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as int,
        name: json['name'] as String,
        muscleGroup: json['muscle_group'] as String?,
        pivot: json['pivot'] != null
            ? ExercisePivot.fromJson(json['pivot'] as Map<String, dynamic>)
            : null,
      );
}
