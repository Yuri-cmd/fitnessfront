import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/services/metrics_service.dart';
import '../../../auth/data/services/auth_service.dart';

class FitnessController with ChangeNotifier {
  final MetricsService _metricsService;
  final AuthService _authService; // Para el perfil

  double? _height;
  double? _weight;
  double? _bmi;
  List<dynamic> _weightLogs = [];
  bool _isLoading = false;

  FitnessController(this._metricsService, this._authService);

  double? get height => _height;
  double? get weight => _weight;
  double? get bmi => _bmi;
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

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200) {
        // Asegurarse de que los valores se extraigan correctamente del objeto user si es necesario
        final data = response.data['user'] ?? response.data;
        _height = double.tryParse(data['height'].toString());
        _weight = double.tryParse(data['current_weight'].toString());
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
    } catch (e) {
      debugPrint(e.toString());
    }
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
