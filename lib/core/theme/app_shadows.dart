import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card({bool dark = false}) => [
        BoxShadow(
          color: (dark ? Colors.black : Colors.black).withValues(
            alpha: dark ? 0.24 : 0.06,
          ),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> glow(Color color, {double alpha = 0.28}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}
