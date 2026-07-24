import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double padding;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = 32,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // El efecto vidrio necesita un tinte claro sobre fondos oscuros y uno
    // oscuro sobre fondos claros para seguir siendo visible en ambos temas.
    final tint = isDark ? Colors.white : Colors.black;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: isDark ? 0.05 : 0.035),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: tint.withValues(alpha: isDark ? 0.1 : 0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
