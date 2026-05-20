import 'package:flutter/material.dart';
import '../../data/services/water_service.dart';

class WaterController with ChangeNotifier {
  final WaterService _waterService;

  WaterController(this._waterService);

  int _glasses = 0;
  int _goalGlasses = 8;
  bool _isLoading = false;

  int get glasses => _glasses;
  int get goalGlasses => _goalGlasses;
  bool get isLoading => _isLoading;
  bool get goalReached => _glasses >= _goalGlasses;
  double get progress => (_glasses / _goalGlasses).clamp(0.0, 1.0);
  String get statusText => goalReached
      ? '¡Meta alcanzada! 🎉'
      : '${_goalGlasses - _glasses} vasos más para tu meta';

  Future<void> loadTodayWater() async {
    try {
      final response = await _waterService.getTodayWater();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _glasses = (data['glasses'] as num).toInt();
        _goalGlasses = (data['goal_glasses'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading water: $e');
    }
  }

  Future<void> addGlass() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _waterService.logGlasses(1);
      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        _glasses = (data['glasses'] as num).toInt();
        _goalGlasses = (data['goal_glasses'] as num).toInt();
      }
    } catch (e) {
      debugPrint('Error logging water: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeGlass() async {
    if (_glasses <= 0) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _waterService.removeLastGlass();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _glasses = (data['glasses'] as num).toInt();
        _goalGlasses = (data['goal_glasses'] as num).toInt();
      }
    } catch (e) {
      debugPrint('Error removing water: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
