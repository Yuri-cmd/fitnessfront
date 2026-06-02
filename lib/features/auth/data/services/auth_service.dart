import 'package:dio/dio.dart';
import 'package:fit_tracker_app/core/network/dio_client.dart';

class AuthService {
  final Dio _dio;

  AuthService(DioClient dioClient) : _dio = dioClient.dio;

  Future<Response> login(String email, String password) async {
    return await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/register', data: data);
  }

  Future<Response> getProfile() async {
    return await _dio.get('/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.post('/profile', data: data);
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _dio.put('/password', data: {
      'current_password':      currentPassword,
      'new_password':          newPassword,
      'new_password_confirmation': newPassword,
    });
  }

  Future<Response> deleteAccount() async {
    return await _dio.delete('/account');
  }
  
  Future<void> saveFcmToken(String token) async {
    await _dio.post('/fcm-token', data: {'token': token, 'platform': 'ios'});
  }

  Future<void> removeFcmToken(String token) async {
    await _dio.delete('/fcm-token', data: {'token': token});
  }
}
