import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class StreakService {
  final Dio _dio;

  StreakService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getStreaks() => _dio.get('/streaks');
}
