class UserProfile {
  final double? height;
  final double? currentWeight;
  final double? goalWeight;
  final String? gender;
  final String? activityLevel;
  final DateTime? birthDate;

  const UserProfile({
    this.height,
    this.currentWeight,
    this.goalWeight,
    this.gender,
    this.activityLevel,
    this.birthDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = (json['user'] ?? json) as Map<String, dynamic>;
    return UserProfile(
      height: double.tryParse(data['height']?.toString() ?? ''),
      currentWeight:
          double.tryParse(data['current_weight']?.toString() ?? ''),
      goalWeight: double.tryParse(data['goal_weight']?.toString() ?? ''),
      gender: data['gender'] as String?,
      activityLevel: data['activity_level'] as String?,
      birthDate: data['birth_date'] != null && data['birth_date'] != 'null'
          ? DateTime.tryParse(data['birth_date'].toString())
          : null,
    );
  }
}
