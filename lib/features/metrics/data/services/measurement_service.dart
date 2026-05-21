import 'package:dio/dio.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';

class MeasurementService {
  final Dio _dio;
  MeasurementService(DioClient client) : _dio = client.dio;

  Future<Response> getAll() => _dio.get('/measurements');
  Future<Response> store(Map<String, dynamic> data) =>
      _dio.post('/measurements', data: data);
  Future<Response> delete(int id) => _dio.delete('/measurements/$id');
}
