class Goal {
  final int id;
  final String type;
  final double targetValue;
  final double currentValue;
  final DateTime? deadline;

  const Goal({
    required this.id,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    this.deadline,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as int,
        type: json['type'] as String,
        targetValue: (json['target_value'] as num).toDouble(),
        currentValue: (json['current_value'] as num? ?? 0).toDouble(),
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
      );
}
