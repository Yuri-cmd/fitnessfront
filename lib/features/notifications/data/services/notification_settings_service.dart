import 'package:dio/dio.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';

class NotificationSettingsService {
  final Dio _dio;

  NotificationSettingsService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> getSettings() => _dio.get('/notification-settings');

  Future<Response> updateSettings(Map<String, dynamic> data) =>
      _dio.put('/notification-settings', data: data);
}
