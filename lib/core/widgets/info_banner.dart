import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;

  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
