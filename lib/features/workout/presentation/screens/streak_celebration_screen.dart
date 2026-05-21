import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';

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
  late AnimationController _enterCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _countCtrl;

  final _shareKey = GlobalKey();
  final _captureKey = GlobalKey();

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _ringProgress;
  late Animation<int> _countAnim;

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

  int get _trainedCount => widget.trainedDaysThisWeek.where((d) => d).length;
  int get _nextMilestone {
    const milestones = [3, 7, 14, 21, 30, 60, 100, 180, 365];
    return milestones.firstWhere((m) => m > widget.streak,
        orElse: () => widget.streak + 365);
  }

  Future<void> _share() async {
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromCenter(
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height - 80,
            ),
            width: 56,
            height: 56,
          );

    try {
      final boundary = _captureKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final file =
          File('${Directory.systemTemp.path}/powerstack_racha.png');
      await file.writeAsBytes(pngBytes);

      final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
      final dayName = days[DateTime.now().weekday - 1];
      final dayCapitalized = '${dayName[0].toUpperCase()}${dayName.substring(1)}';
      final rachaText = '${widget.streak} día${widget.streak == 1 ? '' : 's'} de racha consecutiv${widget.streak == 1 ? 'o' : 'os'}';
      final text =
          '💪 ¡Completé mi entrenamiento de hoy!\n'
          '🔥 $rachaText\n'
          '📅 $dayCapitalized\n\n'
          'Entrenando con Power Stack 🏋️';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      // Fallback a solo texto si falla la captura
      final days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
      final dayName = days[DateTime.now().weekday - 1];
      final dayCapitalized = '${dayName[0].toUpperCase()}${dayName.substring(1)}';
      final rachaText = '${widget.streak} día${widget.streak == 1 ? '' : 's'} de racha consecutiv${widget.streak == 1 ? 'o' : 'os'}';
      Share.share(
        '💪 ¡Completé mi entrenamiento de hoy!\n'
        '🔥 $rachaText\n'
        '📅 $dayCapitalized\n\n'
        'Entrenando con Power Stack 🏋️',
        sharePositionOrigin: origin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final ringTarget = _nextMilestone.toDouble();
    final ringValue = (widget.streak / ringTarget).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Colores sólidos para la tarjeta capturada (se ven bien al compartir en ambos temas)
    final captureBg = isDark ? const Color(0xFF0D1A0A) : Colors.white;
    final captureText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final captureSub = isDark ? const Color(0xAAFFFFFF) : const Color(0x99000000);
    final captureMuted = isDark ? const Color(0x55FFFFFF) : const Color(0x44000000);
    final captureCardBg = isDark ? const Color(0xFF1A2E14) : const Color(0xFFF4F8F0);
    final captureCardBorder = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                // ── Área capturable (sin botones) ─────────────────────────
                Expanded(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      color: captureBg,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Cabecera
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text('POWER STACK',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Anillo de racha
                          AnimatedBuilder(
                            animation: _ringProgress,
                            builder: (_, __) => SizedBox(
                              width: 220,
                              height: 220,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(220, 220),
                                    painter: _RingPainter(
                                      progress: _ringProgress.value * ringValue,
                                      trackColor: AppColors.primary.withValues(alpha: 0.12),
                                      progressColor: AppColors.primary,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 32)),
                                      const SizedBox(height: 4),
                                      AnimatedBuilder(
                                        animation: _countAnim,
                                        builder: (_, __) => Text(
                                          '${_countAnim.value}',
                                          style: TextStyle(
                                            fontSize: 72,
                                            fontWeight: FontWeight.w900,
                                            color: captureText,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.streak == 1 ? 'día' : 'días',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: captureSub,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Meta: $_nextMilestone días',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'de racha',
                            style: TextStyle(
                              fontSize: 18,
                              color: captureSub,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const Spacer(),

                          // Card semana
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: captureCardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: captureCardBorder),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(7, (i) {
                                      final trained = i < widget.trainedDaysThisWeek.length &&
                                          widget.trainedDaysThisWeek[i];
                                      return Column(
                                        children: [
                                          Text(
                                            days[i],
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: trained ? AppColors.primary : captureMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: trained
                                                  ? AppColors.primary
                                                  : captureText.withValues(alpha: 0.07),
                                              shape: BoxShape.circle,
                                              border: trained
                                                  ? null
                                                  : Border.all(color: captureCardBorder),
                                            ),
                                            child: trained
                                                ? const Icon(Icons.check, size: 15, color: Colors.white)
                                                : null,
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(color: captureCardBorder),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$_trainedCount / 7',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'días esta semana',
                                        style: TextStyle(fontSize: 13, color: captureSub),
                                      ),
                                    ],
                                  ),
                                  if (_trainedCount < 7) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '${7 - _trainedCount} más para semana perfecta 🏆',
                                      style: TextStyle(fontSize: 11, color: captureMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Botones (fuera del área de captura) ───────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _share,
                        child: Container(
                          key: _shareKey,
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: onSurface.withValues(alpha: 0.1)),
                          ),
                          child: Icon(Icons.ios_share,
                              color: onSurface.withValues(alpha: 0.6), size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              '¡VAMOS, ${widget.userName.split(' ').first.toUpperCase()}!',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Painter del anillo de progreso ────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
