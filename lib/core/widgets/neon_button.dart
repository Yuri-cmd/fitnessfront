import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final List<Color>? colors;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? [AppColors.primary, AppColors.secondary];

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: effectiveColors),
        boxShadow: [
          BoxShadow(
            color: effectiveColors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.background, // Texto oscuro sobre fondo lima/azul
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
