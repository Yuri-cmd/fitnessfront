import 'package:dio/dio.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';

class StatsService {
  final Dio _dio;

  StatsService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getWeightHistory() => _dio.get('/stats/weight-history');
  Future<Response> getVolumeByMuscle() => _dio.get('/stats/volume-by-muscle');
  Future<Response> getActivityHeatmap() => _dio.get('/stats/activity-heatmap');
  Future<Response> getPersonalRecords() => _dio.get('/stats/personal-records');
  Future<Response> getAchievements() => _dio.get('/achievements');
  Future<Response> getProgressByExercise(int exerciseId) =>
      _dio.get('/stats/progress-by-exercise', queryParameters: {'exercise_id': exerciseId});
  Future<Response> getProgressByRoutine(int routineId) =>
      _dio.get('/stats/progress-by-routine', queryParameters: {'routine_id': routineId});
}
