import 'exercise_model.dart';

class Routine {
  final int id;
  final String name;
  final List<Exercise> exercises;
  final bool isArchived;

  const Routine({
    required this.id,
    required this.name,
    required this.exercises,
    this.isArchived = false,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as int,
        name: json['name'] as String,
        exercises: (json['exercises'] as List<dynamic>? ?? [])
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        isArchived: json['archived_at'] != null,
      );
}
