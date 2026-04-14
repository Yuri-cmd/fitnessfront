import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

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
}
