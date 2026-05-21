import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'capture_colors.dart';

class StreakRing extends StatelessWidget {
  final Animation<double> ringProgress;
  final Animation<int> countAnim;
  final double ringValue;
  final int nextMilestone;
  final int streak;
  final CaptureColors colors;

  const StreakRing({
    super.key,
    required this.ringProgress,
    required this.countAnim,
    required this.ringValue,
    required this.nextMilestone,
    required this.streak,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ringProgress,
      builder: (_, __) => SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: _RingPainter(
                progress: ringProgress.value * ringValue,
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
                  animation: countAnim,
                  builder: (_, __) => Text(
                    '${countAnim.value}',
                    style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: colors.text,
                        height: 1),
                  ),
                ),
                Text(
                  streak == 1 ? 'día' : 'días',
                  style: TextStyle(
                      fontSize: 14,
                      color: colors.sub,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Meta: $nextMilestone días',
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
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = trackColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = progressColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
