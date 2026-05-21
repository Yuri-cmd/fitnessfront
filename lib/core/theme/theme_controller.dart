import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _key = 'dark_mode';
  final modeObs = ThemeMode.system.obs;

  ThemeMode get mode => modeObs.value;
  bool get isDark =>
      modeObs.value == ThemeMode.dark ||
      (modeObs.value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      modeObs.value = ThemeMode.dark;
    } else if (saved == 'light') {
      modeObs.value = ThemeMode.light;
    } else {
      modeObs.value = ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    modeObs.value = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, isDark ? 'dark' : 'light');
  }
}
