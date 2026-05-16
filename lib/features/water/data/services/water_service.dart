import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class WaterService {
  final Dio _dio;

  WaterService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getTodayWater() => _dio.get('/water-logs');

  Future<Response> logWater(int amountMl) =>
      _dio.post('/water-logs', data: {'amount_ml': amountMl});
}
