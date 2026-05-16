import 'package:flutter/material.dart';
import '../../data/services/water_service.dart';

class WaterController with ChangeNotifier {
  final WaterService _waterService;

  WaterController(this._waterService);

  int _todayMl = 0;
  bool _isLoading = false;

  int get todayMl => _todayMl;
  bool get isLoading => _isLoading;
  double get progress => (_todayMl / 2000).clamp(0.0, 1.0);
  String get statusText =>
      _todayMl >= 2000 ? '¡Meta alcanzada!' : '${2000 - _todayMl} ml restantes';

  Future<void> loadTodayWater() async {
    try {
      final response = await _waterService.getTodayWater();
      if (response.statusCode == 200) {
        _todayMl = (response.data['total_ml'] as num).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading water: $e');
    }
  }

  Future<void> logWater(int amountMl) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _waterService.logWater(amountMl);
      if (response.statusCode == 201) {
        _todayMl += amountMl;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error logging water: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
