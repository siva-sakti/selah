import 'package:flutter/material.dart';

/// Selah color palette
/// "Church, not spa" — sacred and modern
class SelahColors {
  SelahColors._();

  /// Primary background, intervention screen
  static const Color deepNavy = Color(0xFF1B2340);

  /// Scripture text, crosses, primary buttons, accents
  static const Color sacredGold = Color(0xFFC9A84C);

  /// Card backgrounds, secondary surfaces
  static const Color warmCream = Color(0xFFF5F0E8);

  /// Body text on light backgrounds
  static const Color charcoal = Color(0xFF2D2D2D);

  /// "Proceed" button, metadata, secondary text
  static const Color subduedGray = Color(0xFF666666);

  /// Pure white for contrast
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Transparent
  static const Color transparent = Colors.transparent;

  /// Gold with reduced opacity for subtle accents
  static Color get sacredGoldFaded => sacredGold.withValues(alpha: 0.3);

  /// Navy with slight transparency for overlays
  static Color get deepNavyOverlay => deepNavy.withValues(alpha: 0.95);
}
