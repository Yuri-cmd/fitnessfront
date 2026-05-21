import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class MeasureChip extends StatelessWidget {
  final String label;
  final double value;
  final double? diff;

  const MeasureChip({
    super.key,
    required this.label,
    required this.value,
    this.diff,
  });

  @override
  Widget build(BuildContext context) {
    Color? diffColor;
    String? diffText;
    if (diff != null && diff!.abs() >= 0.1) {
      diffColor = diff! < 0 ? AppColors.primary : AppColors.alert;
      diffText = '${diff! > 0 ? '+' : ''}${diff!.toStringAsFixed(1)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Text(' cm',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              if (diffText != null) ...[
                const SizedBox(width: 4),
                Text(diffText,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: diffColor)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
