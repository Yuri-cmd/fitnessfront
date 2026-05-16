import 'package:flutter/material.dart';
import '../../data/services/stats_service.dart';

class StatsController with ChangeNotifier {
  final StatsService _statsService;

  StatsController(this._statsService);

  List<dynamic> _weightHistory = [];
  List<dynamic> _volumeByMuscle = [];
  List<dynamic> _activityHeatmap = [];
  List<dynamic> _personalRecords = [];
  List<dynamic> _achievements = [];
  bool _isLoading = false;

  List<dynamic> get weightHistory => _weightHistory;
  List<dynamic> get volumeByMuscle => _volumeByMuscle;
  List<dynamic> get activityHeatmap => _activityHeatmap;
  List<dynamic> get personalRecords => _personalRecords;
  List<dynamic> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _loadWeightHistory(),
      _loadVolumeByMuscle(),
      _loadActivityHeatmap(),
      _loadPersonalRecords(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAchievements() async {
    try {
      final response = await _statsService.getAchievements();
      if (response.statusCode == 200) {
        _achievements = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  Future<void> _loadWeightHistory() async {
    try {
      final response = await _statsService.getWeightHistory();
      if (response.statusCode == 200) _weightHistory = response.data;
    } catch (e) {
      debugPrint('Error loading weight history: $e');
    }
  }

  Future<void> _loadVolumeByMuscle() async {
    try {
      final response = await _statsService.getVolumeByMuscle();
      if (response.statusCode == 200) _volumeByMuscle = response.data;
    } catch (e) {
      debugPrint('Error loading volume by muscle: $e');
    }
  }

  Future<void> _loadActivityHeatmap() async {
    try {
      final response = await _statsService.getActivityHeatmap();
      if (response.statusCode == 200) _activityHeatmap = response.data;
    } catch (e) {
      debugPrint('Error loading activity heatmap: $e');
    }
  }

  Future<void> _loadPersonalRecords() async {
    try {
      final response = await _statsService.getPersonalRecords();
      if (response.statusCode == 200) _personalRecords = response.data;
    } catch (e) {
      debugPrint('Error loading personal records: $e');
    }
  }
}
