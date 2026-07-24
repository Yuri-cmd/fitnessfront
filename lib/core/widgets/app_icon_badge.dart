import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_shadows.dart';

/// Insignia circular "hero" — consolida las 4 reimplementaciones dispersas
/// en splash/onboarding/login/register (cada una con tamaño/relleno distinto).
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double iconScale;

  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 88,
    this.color = const Color(0xFFA1CD35),
    this.iconScale = 0.42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppShadows.glow(color, alpha: 0.22),
      ),
      child: Icon(icon, size: size * iconScale, color: color),
    );
  }
}
