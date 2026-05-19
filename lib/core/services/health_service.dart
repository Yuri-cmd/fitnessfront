import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._();
  factory HealthService() => _instance;
  HealthService._();

  final Health _health = Health();

  static const _allTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  static const _permissions = [
    HealthDataAccess.READ_WRITE, // WEIGHT
    HealthDataAccess.READ,       // HEIGHT
    HealthDataAccess.READ,       // STEPS
    HealthDataAccess.READ,       // ACTIVE_ENERGY_BURNED
    HealthDataAccess.READ,       // HEART_RATE
    HealthDataAccess.READ_WRITE, // WORKOUT
  ];

  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        _allTypes,
        permissions: _permissions,
      );
      return granted;
    } catch (e) {
      debugPrint('Health permissions error: $e');
      return false;
    }
  }

  // Retorna el peso más reciente en kg, o null si no hay datos
  Future<double?> getLatestWeight() async {
    try {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 30));
      final data = await _health.getHealthDataFromTypes(
        startTime: past,
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );
      if (data.isEmpty) return null;
      data.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      return (data.first.value as NumericHealthValue).numericValue.toDouble();
    } catch (e) {
      debugPrint('Health getLatestWeight error: $e');
      return null;
    }
  }

  // Retorna los pasos del día de hoy
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Health getTodaySteps error: $e');
      return 0;
    }
  }

  // Guarda un peso en Apple Health
  Future<bool> saveWeight(double weightKg) async {
    try {
      return await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        unit: HealthDataUnit.KILOGRAM,
      );
    } catch (e) {
      debugPrint('Health saveWeight error: $e');
      return false;
    }
  }

  // Guarda un entrenamiento en Apple Health
  Future<bool> saveWorkout({
    required DateTime start,
    required DateTime end,
    int? totalEnergyBurned,
  }) async {
    try {
      return await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: start,
        end: end,
        totalEnergyBurned: totalEnergyBurned,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );
    } catch (e) {
      debugPrint('Health saveWorkout error: $e');
      return false;
    }
  }
}
