class WeightLog {
  final int? id;
  final double weight;
  final DateTime createdAt;

  const WeightLog({
    this.id,
    required this.weight,
    required this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
        id: json['id'] as int?,
        weight: double.parse(json['weight'].toString()),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
