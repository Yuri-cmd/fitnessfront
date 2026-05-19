import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String? _registerError;
  String? _userName;

  AuthController(this._authService);

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get registerError => _registerError;
  String get userName => _userName ?? 'Atleta';

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.authTokenKey);
    _userName = prefs.getString(AppConstants.userNameKey);
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _registerError = null;
    notifyListeners();
    try {
      final response = await _authService.register({
        'name': name,
        'email': email,
        'password': password,
      });
      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        _token = response.data['token'];
        _userName = response.data['name'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);
        if (_userName != null) await prefs.setString(AppConstants.userNameKey, _userName!);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'] as Map?;
        if (errors?['email'] != null) {
          _registerError = 'Este correo ya está registrado.';
        } else {
          _registerError = 'Datos inválidos. Revisa los campos.';
        }
      } else {
        _registerError = 'Error de conexión. Intenta de nuevo.';
      }
      debugPrint('Register error: $e');
    } catch (e) {
      _registerError = 'Error inesperado. Intenta de nuevo.';
      debugPrint('Register error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      if (response.statusCode == 200) {
        _token = response.data['token'];
        _userName = response.data['name'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);
        if (_userName != null) await prefs.setString(AppConstants.userNameKey, _userName!);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userNameKey);
    _isAuthenticated = false;
    _token = null;
    _userName = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      _isAuthenticated = false;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
