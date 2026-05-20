import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class WaterService {
  final Dio _dio;

  WaterService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getTodayWater() => _dio.get('/water-logs');

  Future<Response> logGlasses(int glasses) =>
      _dio.post('/water-logs', data: {'glasses': glasses});

  Future<Response> removeLastGlass() => _dio.delete('/water-logs/last');
}
