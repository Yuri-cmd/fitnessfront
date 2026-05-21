import 'package:get/get.dart';
import 'package:fit_tracker_app/features/stats/data/models/stats_models.dart';
import 'package:fit_tracker_app/features/stats/data/services/stats_service.dart';

class StatsController extends GetxController {
  final StatsService _statsService;

  StatsController(this._statsService);

  final weightHistory = <WeightHistory>[].obs;
  final volumeByMuscle = <VolumeByMuscle>[].obs;
  final activityHeatmap = <ActivityDay>[].obs;
  final personalRecords = <PersonalRecord>[].obs;
  final achievements = <Achievement>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _load(() => _statsService.getWeightHistory(), weightHistory,
          WeightHistory.fromJson),
      _load(() => _statsService.getVolumeByMuscle(), volumeByMuscle,
          VolumeByMuscle.fromJson),
      _load(() => _statsService.getActivityHeatmap(), activityHeatmap,
          ActivityDay.fromJson),
      _load(() => _statsService.getPersonalRecords(), personalRecords,
          PersonalRecord.fromJson),
    ]);
    isLoading.value = false;
  }

  Future<void> loadAchievements() async {
    try {
      final r = await _statsService.getAchievements();
      if (r.statusCode == 200) {
        achievements.value = (r.data as List<dynamic>)
            .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _load<T>(
    Future<dynamic> Function() call,
    RxList<T> list,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final r = await call();
      if (r.statusCode == 200) {
        list.value = (r.data as List<dynamic>)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  static String resolveIcon(String? raw) {
    if (raw == null || raw.isEmpty) return '🏆';
    if (!raw.startsWith('fa-')) return raw;
    const map = {
      'fa-trophy': '🏆', 'fa-medal': '🥇', 'fa-star': '⭐',
      'fa-fire': '🔥', 'fa-bolt': '⚡', 'fa-dumbbell': '🏋️',
      'fa-heart': '❤️', 'fa-crown': '👑', 'fa-check': '✅',
      'fa-flag': '🚩', 'fa-running': '🏃', 'fa-bicycle': '🚴',
      'fa-swimmer': '🏊', 'fa-walking': '🚶', 'fa-weight': '⚖️',
      'fa-apple-alt': '🍎', 'fa-bed': '🛏️', 'fa-brain': '🧠',
      'fa-chart-line': '📈', 'fa-calendar-check': '📅',
    };
    for (final e in map.entries) {
      if (raw.contains(e.key)) return e.value;
    }
    return '🏆';
  }

  static String formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
          'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }
}
