import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'capture_colors.dart';

class WeekActivityCard extends StatelessWidget {
  final List<bool> trainedDays;
  final CaptureColors colors;

  const WeekActivityCard({
    super.key,
    required this.trainedDays,
    required this.colors,
  });

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  int get _trainedCount => trainedDays.where((d) => d).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final trained = i < trainedDays.length && trainedDays[i];
                return Column(
                  children: [
                    Text(_labels[i],
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                trained ? AppColors.primary : colors.muted)),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: trained
                            ? AppColors.primary
                            : colors.text.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                        border: trained
                            ? null
                            : Border.all(color: colors.cardBorder),
                      ),
                      child: trained
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            Divider(color: colors.cardBorder),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_trainedCount / 7',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(width: 6),
                Text('días esta semana',
                    style: TextStyle(fontSize: 13, color: colors.sub)),
              ],
            ),
            if (_trainedCount < 7) ...[
              const SizedBox(height: 6),
              Text('${7 - _trainedCount} más para semana perfecta 🏆',
                  style: TextStyle(fontSize: 11, color: colors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}
