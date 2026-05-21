import 'dart:math';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/metrics/data/models/user_profile_model.dart';
import 'package:fit_tracker_app/features/metrics/data/models/weight_log_model.dart';
import 'package:fit_tracker_app/features/metrics/data/services/metrics_service.dart';
import 'package:fit_tracker_app/features/auth/data/services/auth_service.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';

class FitnessController extends GetxController {
  final MetricsService _metricsService;
  final AuthService _authService;
  final HealthService _healthService;

  FitnessController(this._metricsService, this._authService, this._healthService);

  final height = Rx<double?>(null);
  final weight = Rx<double?>(null);
  final goalWeight = Rx<double?>(null);
  final bmi = Rx<double?>(null);
  final birthDate = Rx<DateTime?>(null);
  final gender = Rx<String?>(null);
  final activityLevel = Rx<String?>(null);
  final weightLogs = <WeightLog>[].obs;
  final isLoading = false.obs;

  String get bmiCategory {
    final b = bmi.value;
    if (b == null) return 'N/A';
    if (b < 18.5) return 'Bajo peso';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  double get weightToLose {
    final b = bmi.value;
    final h = height.value;
    final w = weight.value;
    if (b == null || b <= 24.9 || h == null || w == null) return 0;
    return w - 24.9 * pow(h / 100, 2);
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadWeightLogs();
  }

  void _calculateBmi() {
    final h = height.value;
    final w = weight.value;
    if (h != null && w != null && h > 0) {
      bmi.value = w / pow(h / 100, 2);
    }
  }

  Future<void> updateProfileMetrics(double h, double w) async {
    isLoading.value = true;
    try {
      await _authService.updateProfile({'height': h, 'current_weight': w});
      await loadProfile();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<bool> updateFullProfile({
    double? height,
    double? weight,
    double? goalWeight,
    DateTime? birthDate,
    String? gender,
    String? activityLevel,
  }) async {
    isLoading.value = true;
    try {
      final payload = <String, dynamic>{};
      if (height != null) payload['height'] = height;
      if (weight != null) payload['current_weight'] = weight;
      if (goalWeight != null) payload['goal_weight'] = goalWeight;
      if (birthDate != null) {
        payload['birth_date'] =
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      }
      if (gender != null) payload['gender'] = gender;
      if (activityLevel != null) payload['activity_level'] = activityLevel;

      final resp = await _authService.updateProfile(payload);
      if (resp.statusCode == 200) {
        await loadProfile();
        isLoading.value = false;
        return true;
      }
    } catch (_) {}
    isLoading.value = false;
    return false;
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200) {
        final profile =
            UserProfile.fromJson(response.data as Map<String, dynamic>);
        height.value = profile.height;
        weight.value = profile.currentWeight;
        goalWeight.value = profile.goalWeight;
        gender.value = profile.gender;
        activityLevel.value = profile.activityLevel;
        birthDate.value = profile.birthDate;
        _calculateBmi();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> addWeight(double w) async {
    try {
      await _metricsService.addWeightLog(w);
      weight.value = w;
      _calculateBmi();
      await loadWeightLogs();
      _healthService.saveWeight(w);
    } catch (_) {}
  }

  Future<double?> getWeightFromHealth() => _healthService.getLatestWeight();

  Future<void> loadWeightLogs() async {
    try {
      final response = await _metricsService.getWeightLogs();
      if (response.statusCode == 200) {
        weightLogs.value = (response.data as List<dynamic>)
            .map((e) => WeightLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }
}
