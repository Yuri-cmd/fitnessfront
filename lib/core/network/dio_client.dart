import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker_app/core/constants/app_constants.dart';
import 'package:fit_tracker_app/core/services/auth_events.dart';
import 'package:fit_tracker_app/core/services/app_flags.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.authTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('HTTP ${e.response?.statusCode} → ${e.requestOptions.method} ${e.requestOptions.path}');
        final suppress = e.requestOptions.extra['suppressLogout'] == true ||
            AppFlags.isLogoutSuppressed;
        if (e.response?.statusCode == 401 && !suppress) {
          AuthEvents.notifyUnauthorized();
        }
        return handler.next(e);
      },
    ));
  }
}
