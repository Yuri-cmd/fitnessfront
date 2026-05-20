import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_events.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String? _registerError;
  String? _userName;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  late final StreamSubscription<void> _unauthorizedSub;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthController(this._authService) {
    _unauthorizedSub = AuthEvents.onUnauthorized.listen((_) => _forceLogout());
    checkAuth();
  }

  void _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userNameKey);
    _isAuthenticated = false;
    _token = null;
    _userName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _unauthorizedSub.cancel();
    super.dispose();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get registerError => _registerError;
  String get userName => _userName ?? 'Atleta';
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.authTokenKey);
    _userName = prefs.getString(AppConstants.userNameKey);
    _isBiometricEnabled = prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    _isBiometricAvailable = await _biometricService.isAvailable();
    // Si hay token Y biométrico activo → mostrar LoginScreen para que Face ID dispare
    // Si hay token pero sin biométrico → entrar directamente
    final hasBiometric = _isBiometricEnabled && _isBiometricAvailable;
    _isAuthenticated = _token != null && !hasBiometric;
    _isInitialized = true;
    if (_token != null) debugPrint('🔑 AUTH TOKEN (stored): $_token');
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.biometricEnabledKey, enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();
  }

  Future<bool> loginWithBiometrics() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return false;
    if (_token == null) return false;
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return authenticated;
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
        debugPrint('🔑 AUTH TOKEN: $_token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);
        if (_userName != null) await prefs.setString(AppConstants.userNameKey, _userName!);
        _isBiometricAvailable = await _biometricService.isAvailable();
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        _registerFcmToken();
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
    await _unregisterFcmToken();
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
  
  Future<void> _registerFcmToken() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      debugPrint('📲 FCM permission: ${settings.authorizationStatus}');
      if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('📱 FCM TOKEN: $token');
      if (token != null) await _authService.saveFcmToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (t) => _authService.saveFcmToken(t),
      );
    } catch (e) {
      debugPrint('FCM register error: $e');
    }
  }

  Future<void> _unregisterFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _authService.removeFcmToken(token);
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('FCM unregister error: $e');
    }
  }
}
