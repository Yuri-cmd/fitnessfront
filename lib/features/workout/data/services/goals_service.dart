import 'package:dio/dio.dart';

class GoalsService {
  final Dio _dio;
  GoalsService(this._dio);

  Future<Response> getGoals() async {
    return await _dio.get('/goals');
  }

  Future<Response> createGoal(Map<String, dynamic> data) async {
    return await _dio.post('/goals', data: data);
  }

  Future<Response> updateGoal(int id, Map<String, dynamic> data) async {
    return await _dio.put('/goals/$id', data: data);
  }

  Future<Response> deleteGoal(int id) async {
    return await _dio.delete('/goals/$id');
  }
}
