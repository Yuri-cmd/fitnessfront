import 'package:flutter/material.dart';
import '../../data/services/measurement_service.dart';

class MeasurementController with ChangeNotifier {
  final MeasurementService _service;
  MeasurementController(this._service);

  List<dynamic> _measurements = [];
  bool _isLoading = false;

  List<dynamic> get measurements => _measurements;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final r = await _service.getAll();
      if (r.statusCode == 200) _measurements = r.data;
    } catch (e) {
      debugPrint('Error loading measurements: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      final r = await _service.store(data);
      if (r.statusCode == 201) {
        _measurements.insert(0, r.data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error saving measurement: $e');
    }
    return false;
  }

  Future<void> remove(int id) async {
    try {
      await _service.delete(id);
      _measurements.removeWhere((m) => m['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting measurement: $e');
    }
  }
}
