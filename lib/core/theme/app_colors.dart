import 'package:flutter/material.dart';

class AppColors {
  // Paleta "Power Stack Light"
  static const Color primary        = Color(0xFFA1CD35); // Verde Lima Fit
  static const Color onPrimary      = Color(0xFF1A1A00); // Negro cálido — ratio 11.7:1 sobre primary
  static const Color background     = Color(0xFFF8F9FA); // Off-White / Light Grey
  static const Color surface        = Color(0xFFFFFFFF); // Pure White
  static const Color textTitle      = Color(0xFF121212); // Deep Charcoal
  static const Color textBody       = Color(0xFF616161); // Grey
  static const Color secondary      = Color(0xFF2D9CDB); // Electric Blue
  static const Color warning        = Color(0xFFF2994A); // Vivid Orange (warmup / alertas)
  static const Color supersetAccent = Color(0xFF7B61FF); // Morado superserie
  static const Color alert          = Color(0xFFF2994A); // alias de warning (retrocompat.)
  static const Color error          = Color(0xFFD32F2F); // Red
  static const Color white          = Color(0xFFFFFFFF);

  // Roles semánticos añadidos para el sistema de diseño (evitar Colors.* crudo)
  static const Color textMutedLight = Color(0xFF757575); // reemplaza Colors.grey en tema claro
  static const Color textMutedDark  = Color(0xFFA0A0A0); // reemplaza Colors.grey en tema oscuro
  static const Color gold           = Color(0xFFC9A227); // medallas / logros (reemplaza Colors.amber)
  static const Color silver         = Color(0xFFA8ADB4); // 2º lugar en rankings
  static const Color bronze         = Color(0xFFB07A4E); // 3er lugar en rankings
}
