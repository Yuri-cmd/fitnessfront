class Measurement {
  final int id;
  final DateTime measuredAt;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftLegCm;
  final double? rightLegCm;

  const Measurement({
    required this.id,
    required this.measuredAt,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftLegCm,
    this.rightLegCm,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        id: json['id'] as int,
        measuredAt: DateTime.parse(json['measured_at'] as String),
        waistCm: _toDouble(json['waist_cm']),
        chestCm: _toDouble(json['chest_cm']),
        hipsCm: _toDouble(json['hips_cm']),
        leftArmCm: _toDouble(json['left_arm_cm']),
        rightArmCm: _toDouble(json['right_arm_cm']),
        leftLegCm: _toDouble(json['left_leg_cm']),
        rightLegCm: _toDouble(json['right_leg_cm']),
      );

  static double? _toDouble(dynamic v) =>
      v != null ? (v as num).toDouble() : null;

  /// Returns the value for the given snake_case field key (e.g., 'waist_cm').
  double? field(String key) {
    switch (key) {
      case 'waist_cm': return waistCm;
      case 'chest_cm': return chestCm;
      case 'hips_cm': return hipsCm;
      case 'left_arm_cm': return leftArmCm;
      case 'right_arm_cm': return rightArmCm;
      case 'left_leg_cm': return leftLegCm;
      case 'right_leg_cm': return rightLegCm;
      default: return null;
    }
  }
}
