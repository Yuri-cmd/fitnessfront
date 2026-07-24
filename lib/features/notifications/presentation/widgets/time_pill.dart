import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';

/// Pill de hora — misma receta visual que [AppPill] (radio/alpha),
/// mantenida como widget propio porque agrega padding/tipografía específicos
/// para el selector de hora.
class TimePill extends StatelessWidget {
  final String label;
  final Color color;

  const TimePill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
