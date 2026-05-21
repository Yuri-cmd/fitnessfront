import 'package:flutter/material.dart';

class CaptureColors {
  final Color bg, text, sub, muted, cardBg, cardBorder;

  const CaptureColors({
    required this.bg,
    required this.text,
    required this.sub,
    required this.muted,
    required this.cardBg,
    required this.cardBorder,
  });

  factory CaptureColors.fromBrightness(bool isDark) => isDark
      ? const CaptureColors(
          bg: Color(0xFF0D1A0A),
          text: Colors.white,
          sub: Color(0xAAFFFFFF),
          muted: Color(0x55FFFFFF),
          cardBg: Color(0xFF1A2E14),
          cardBorder: Color(0x22FFFFFF),
        )
      : const CaptureColors(
          bg: Colors.white,
          text: Color(0xFF1A1A1A),
          sub: Color(0x99000000),
          muted: Color(0x44000000),
          cardBg: Color(0xFFF4F8F0),
          cardBorder: Color(0x22000000),
        );
}
