import 'package:get/get.dart';
import 'package:fit_tracker_app/features/metrics/data/models/measurement_model.dart';
import 'package:fit_tracker_app/features/metrics/data/services/measurement_service.dart';

class MeasurementController extends GetxController {
  final MeasurementService _service;

  MeasurementController(this._service);

  final measurements = <Measurement>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final r = await _service.getAll();
      if (r.statusCode == 200) {
        measurements.value = (r.data as List<dynamic>)
            .map((e) => Measurement.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      final r = await _service.store(data);
      if (r.statusCode == 201) {
        measurements.insert(
            0, Measurement.fromJson(r.data as Map<String, dynamic>));
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> remove(int id) async {
    try {
      await _service.delete(id);
      measurements.removeWhere((m) => m.id == id);
    } catch (_) {}
  }
}
