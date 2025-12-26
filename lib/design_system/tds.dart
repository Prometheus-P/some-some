import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. DESIGN SYSTEM (Material Design 3 + Kitsch)
// -----------------------------------------------------------------------------

// M3 Seed Color - kitschPink generates the entire tonal palette
const Color _seedColor = Color(0xFFFF0099); // neonPink

// 쫀득한 애니메이션 커브 (게임 피드백용 - M3 하이브리드 모션)
const Curve kSpringCurve = Curves.elasticOut;

// M3 Text Style helpers (Korean-optimized, following M3 type scale)
TextStyle titleBig(ColorScheme cs) => TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: cs.onSurface,
  letterSpacing: -0.5,
  height: 1.3,
);

TextStyle titleMedium(ColorScheme cs) => TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: cs.onSurface,
  letterSpacing: -0.5,
);

TextStyle bodyText(ColorScheme cs) => TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: cs.onSurfaceVariant,
  letterSpacing: -0.2,
);

TextStyle titleSmall(ColorScheme cs) => TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: cs.onSurface,
  letterSpacing: -0.2,
);

TextStyle bodyBig(ColorScheme cs) => TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: cs.onSurface,
  letterSpacing: -0.2,
);

TextStyle bodySmall(ColorScheme cs) => TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: cs.onSurfaceVariant,
  letterSpacing: -0.1,
);

/// Public seed color used across the app.
const Color seedColor = _seedColor;
