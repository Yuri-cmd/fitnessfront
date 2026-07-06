import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/streak/capture_colors.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/streak/app_badge.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/streak/streak_ring.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/streak/week_activity_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/streak/streak_bottom_actions.dart';

class StreakCelebrationScreen extends StatefulWidget {
  final int streak;
  final List<bool> trainedDaysThisWeek;
  final String userName;

  const StreakCelebrationScreen({
    super.key,
    required this.streak,
    required this.trainedDaysThisWeek,
    required this.userName,
  });

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _countCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _ringProgress;
  late final Animation<int> _countAnim;

  final _shareKey = GlobalKey();
  final _captureKey = GlobalKey();

  int get _nextMilestone {
    const milestones = [3, 7, 14, 21, 30, 60, 100, 180, 365];
    return milestones.firstWhere((m) => m > widget.streak,
        orElse: () => widget.streak + 365);
  }

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringProgress =
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut);

    _countCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _countAnim = IntTween(begin: 0, end: widget.streak)
        .animate(CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut));

    _enterCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 300), () => _ringCtrl.forward());
    Future.delayed(
        const Duration(milliseconds: 200), () => _countCtrl.forward());
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _ringCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromCenter(
            center: Offset(Get.width / 2, Get.height - 80),
            width: 56,
            height: 56);
    final text = _buildShareText();
    try {
      final ctx = _captureKey.currentContext;
      final boundary = ctx?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Share.share(text, sharePositionOrigin: origin);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List();
      final file =
          File('${Directory.systemTemp.path}/powerstack_racha.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: text, sharePositionOrigin: origin);
    } catch (_) {
      Share.share(text, sharePositionOrigin: origin);
    }
  }

  String _buildShareText() {
    final days = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];
    final dayName = days[DateTime.now().weekday - 1];
    final day = '${dayName[0].toUpperCase()}${dayName.substring(1)}';
    final s = widget.streak;
    return '💪 ¡Completé mi entrenamiento de hoy!\n'
        '🔥 $s día${s == 1 ? '' : 's'} de racha consecutiv${s == 1 ? 'o' : 'os'}\n'
        '📅 $day\n\nEntrenando con Power Stack 🏋️';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = CaptureColors.fromBrightness(isDark);
    final cs = Theme.of(context).colorScheme;
    final ringValue =
        (widget.streak / _nextMilestone.toDouble()).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      color: colors.bg,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const AppBadge(),
                          const Spacer(),
                          StreakRing(
                            ringProgress: _ringProgress,
                            countAnim: _countAnim,
                            ringValue: ringValue,
                            nextMilestone: _nextMilestone,
                            streak: widget.streak,
                            colors: colors,
                          ),
                          const SizedBox(height: 8),
                          Text('de racha',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: colors.sub,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                          const Spacer(),
                          WeekActivityCard(
                            trainedDays: widget.trainedDaysThisWeek,
                            colors: colors,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                StreakBottomActions(
                  shareKey: _shareKey,
                  onShare: _share,
                  userName: widget.userName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
