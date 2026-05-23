import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LiveActivityService {
  static const _channel = MethodChannel('com.powerstack.live_activity');

  static bool get _supported => Platform.isIOS;

  static Future<void> start({
    required String routineName,
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required DateTime sessionStart,
  }) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('startActivity', {
        'routineName': routineName,
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'sessionStartMillis': sessionStart.millisecondsSinceEpoch.toDouble(),
      });
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] start error: $e');
    }
  }

  static Future<void> update({
    required String exerciseName,
    required bool isResting,
    DateTime? restEndTime,
    required DateTime sessionStart,
    required int currentSet,
    required int totalSets,
  }) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('updateActivity', {
        'exerciseName': exerciseName,
        'isResting': isResting,
        'restEndMillis': restEndTime?.millisecondsSinceEpoch.toDouble(),
        'sessionStartMillis': sessionStart.millisecondsSinceEpoch.toDouble(),
        'currentSet': currentSet,
        'totalSets': totalSets,
      });
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] update error: $e');
    }
  }

  static Future<void> end() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('endActivity');
    } on PlatformException catch (e) {
      debugPrint('[LiveActivity] end error: $e');
    }
  }
}
