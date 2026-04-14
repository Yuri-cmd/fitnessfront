import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class MetricsService {
  final Dio _dio;

  MetricsService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getWeightLogs() async {
    return await _dio.get('/weight-logs');
  }

  Future<Response> addWeightLog(double weight) async {
    return await _dio.post('/weight-logs', data: {'weight': weight});
  }
}
