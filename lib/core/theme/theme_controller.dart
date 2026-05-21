import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _key = 'dark_mode';
  final _mode = ThemeMode.system.obs;

  ThemeMode get mode => _mode.value;
  bool get isDark =>
      _mode.value == ThemeMode.dark ||
      (_mode.value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      _mode.value = ThemeMode.dark;
    } else if (saved == 'light') {
      _mode.value = ThemeMode.light;
    } else {
      _mode.value = ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    _mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, isDark ? 'dark' : 'light');
  }
}
