import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker_app/core/constants/app_constants.dart';
import 'package:fit_tracker_app/core/services/auth_events.dart';
import 'package:fit_tracker_app/features/auth/data/models/auth_response.dart';
import 'package:fit_tracker_app/features/auth/data/services/auth_service.dart';
import 'package:fit_tracker_app/features/auth/data/services/biometric_service.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final BiometricService _biometricService = BiometricService();

  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final isInitialized = false.obs;
  final registerError = Rx<String?>(null);
  final userName = 'Atleta'.obs;
  final isBiometricEnabled = false.obs;
  final isBiometricAvailable = false.obs;

  late final StreamSubscription<void> _unauthorizedSub;

  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    _unauthorizedSub = AuthEvents.onUnauthorized.listen((_) => _forceLogout());
    checkAuth();
  }

  @override
  void onClose() {
    _unauthorizedSub.cancel();
    super.onClose();
  }

  Future<void> _forceLogout() async {
    if (!isAuthenticated.value) return;
    isAuthenticated.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userNameKey);
    userName.value = 'Atleta';
    Get.snackbar(
      'Sesión expirada',
      'Tu sesión expiró. Por favor vuelve a iniciar sesión.',
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    final name = prefs.getString(AppConstants.userNameKey);
    isBiometricEnabled.value =
        prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    isBiometricAvailable.value = await _biometricService.isAvailable();
    if (name != null) userName.value = name;
    final hasBiometric =
        isBiometricEnabled.value && isBiometricAvailable.value;
    isAuthenticated.value = token != null && !hasBiometric;
    isInitialized.value = true;
    if (token != null) debugPrint('🔑 AUTH TOKEN (stored): $token');
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.biometricEnabledKey, enabled);
    isBiometricEnabled.value = enabled;
  }

  Future<bool> loginWithBiometrics() async {
    if (!isBiometricAvailable.value || !isBiometricEnabled.value) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(AppConstants.authTokenKey) == null) return false;
    final authenticated = await _biometricService.authenticate();
    if (authenticated) isAuthenticated.value = true;
    return authenticated;
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String? birthDate,
  }) async {
    isLoading.value = true;
    registerError.value = null;
    try {
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (birthDate != null) payload['birth_date'] = birthDate;
      final response = await _authService.register(payload);
      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        final token = auth.token;
        final loadedName = auth.name;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, token);
        await prefs.setString(AppConstants.userNameKey, loadedName);
        userName.value = loadedName;
        isAuthenticated.value = true;
        isLoading.value = false;
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors =
            (e.response?.data as Map<String, dynamic>?)?['errors'] as Map?;
        registerError.value = errors?['email'] != null
            ? 'Este correo ya está registrado.'
            : 'Datos inválidos. Revisa los campos.';
      } else {
        registerError.value = 'Error de conexión. Intenta de nuevo.';
      }
      debugPrint('Register error: $e');
    } catch (e) {
      registerError.value = 'Error inesperado. Intenta de nuevo.';
      debugPrint('Register error: $e');
    }
    isLoading.value = false;
    return false;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await _authService.login(email, password);
      if (response.statusCode == 200) {
        final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        final token = auth.token;
        final loadedName = auth.name;
        debugPrint('🔑 AUTH TOKEN: $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, token);
        await prefs.setString(AppConstants.userNameKey, loadedName);
        userName.value = loadedName;
        isBiometricAvailable.value = await _biometricService.isAvailable();
        isAuthenticated.value = true;
        isLoading.value = false;
        _registerFcmToken();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = false;
    return false;
  }

  Future<void> logout() async {
    await _unregisterFcmToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userNameKey);
    isAuthenticated.value = false;
    userName.value = 'Atleta';
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null; // null = éxito
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors =
            (e.response?.data as Map<String, dynamic>?)?['errors'] as Map?;
        if (errors?['current_password'] != null) {
          return 'La contraseña actual es incorrecta.';
        }
        return 'La nueva contraseña no cumple los requisitos.';
      }
      return 'Error de conexión. Intenta de nuevo.';
    } catch (e) {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<bool> deleteAccount() async {
    isLoading.value = true;
    try {
      await _authService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      isAuthenticated.value = false;
      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = false;
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
      FirebaseMessaging.instance.onTokenRefresh
          .listen((t) => _authService.saveFcmToken(t));
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
