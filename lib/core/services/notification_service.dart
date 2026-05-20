import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init(Dio dio) async {
    // Pedir permiso al usuario
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Obtener el token y enviarlo al backend
    final token = await _fcm.getToken();
    if (token != null) {
      await _sendTokenToBackend(dio, token);
    }

    // Cuando el token se renueva, actualizar el backend
    _fcm.onTokenRefresh.listen((newToken) => _sendTokenToBackend(dio, newToken));

    // Manejar notificaciones cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Notificación recibida: ${message.notification?.title}');
    });
  }

  Future<void> removeToken(Dio dio) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await dio.delete('/fcm-token', data: {'token': token});
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  Future<void> _sendTokenToBackend(Dio dio, String token) async {
    try {
      await dio.post('/fcm-token', data: {
        'token': token,
        'platform': 'ios',
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}
