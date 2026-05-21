class ExercisePivot {
  final int sets;
  final int reps;

  const ExercisePivot({required this.sets, required this.reps});

  factory ExercisePivot.fromJson(Map<String, dynamic> json) => ExercisePivot(
        sets: (json['sets'] as num).toInt(),
        reps: (json['reps'] as num).toInt(),
      );
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
