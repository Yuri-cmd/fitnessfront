import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/services/metrics_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../../core/services/health_service.dart';

class FitnessController with ChangeNotifier {
  final MetricsService _metricsService;
  final AuthService _authService;
  final HealthService _healthService;

  double? _height;
  double? _weight;
  double? _goalWeight;
  double? _bmi;
  DateTime? _birthDate;
  String? _gender;
  String? _activityLevel;
  List<dynamic> _weightLogs = [];
  bool _isLoading = false;

  FitnessController(this._metricsService, this._authService, this._healthService);

  double? get height => _height;
  double? get weight => _weight;
  double? get goalWeight => _goalWeight;
  double? get bmi => _bmi;
  DateTime? get birthDate => _birthDate;
  String? get gender => _gender;
  String? get activityLevel => _activityLevel;
  List<dynamic> get weightLogs => _weightLogs;
  bool get isLoading => _isLoading;

  void calculateBmi() {
    if (_height != null && _weight != null && _height! > 0) {
      _bmi = _weight! / pow(_height! / 100, 2);
      notifyListeners();
    }
  }

  String get bmiCategory {
    if (_bmi == null) return 'N/A';
    if (_bmi! < 18.5) return 'Bajo peso';
    if (_bmi! < 25) return 'Normal';
    if (_bmi! < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  double get weightToLose {
    if (_bmi == null || _bmi! <= 24.9) return 0;
    double idealWeight = 24.9 * pow(_height! / 100, 2);
    return _weight! - idealWeight;
  }

  Future<void> updateProfileMetrics(double height, double weight) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateProfile({
        'height': height,
        'current_weight': weight,
      });
      await loadProfile();
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateFullProfile({
    double? height,
    double? weight,
    double? goalWeight,
    DateTime? birthDate,
    String? gender,
    String? activityLevel,
  }) async {
    _isLoading = true;
    notifyListeners();
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
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200) {
        final data = response.data['user'] ?? response.data;
        _height = double.tryParse(data['height'].toString());
        _weight = double.tryParse(data['current_weight'].toString());
        _goalWeight = double.tryParse(data['goal_weight'].toString());
        _gender = data['gender'] as String?;
        _activityLevel = data['activity_level'] as String?;
        final bd = data['birth_date'];
        _birthDate = bd != null && bd != 'null' ? DateTime.tryParse(bd.toString()) : null;
        calculateBmi();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWeight(double weight) async {
    try {
      await _metricsService.addWeightLog(weight);
      _weight = weight;
      calculateBmi();
      await loadWeightLogs();
      _healthService.saveWeight(weight);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<double?> getWeightFromHealth() async {
    return _healthService.getLatestWeight();
  }

  Future<void> loadWeightLogs() async {
    try {
      final response = await _metricsService.getWeightLogs();
      if (response.statusCode == 200) {
        _weightLogs = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
