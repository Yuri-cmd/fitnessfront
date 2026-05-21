import 'package:dio/dio.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';

class WorkoutService {
  final Dio _dio;

  WorkoutService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getRoutines() async {
    return await _dio.get('/routines');
  }

  Future<Response> completeRoutine(
    int routineId, [
    List<Map<String, dynamic>>? sets,
  ]) async {
    return await _dio.post(
      '/routines/$routineId/complete',
      data: sets != null && sets.isNotEmpty ? {'sets': sets} : null,
    );
  }

  Future<Response> getExercises() async {
    return await _dio.get('/exercises');
  }

  Future<Response> createExercise(Map<String, dynamic> data) async {
    return await _dio.post('/exercises', data: data);
  }

  Future<Response> updateExercise(int id, Map<String, dynamic> data) async {
    return await _dio.put('/exercises/$id', data: data);
  }

  Future<Response> createRoutine(String name, List<Map<String, dynamic>> exercises) async {
    return await _dio.post('/routines', data: {
      'name': name,
      'exercises': exercises,
    });
  }

  Future<Response> updateRoutine(int id, String name, List<Map<String, dynamic>> exercises) async {
    return await _dio.put('/routines/$id', data: {
      'name': name,
      'exercises': exercises,
    });
  }

  Future<Response> deleteRoutine(int id) async {
    return await _dio.delete('/routines/$id');
  }

  Future<Response> getWeeklyProgress() async {
    return await _dio.get('/workouts/weekly-progress');
  }

  Future<Response> getWorkoutHistory() async {
    return await _dio.get('/workouts/history');
  }
}
