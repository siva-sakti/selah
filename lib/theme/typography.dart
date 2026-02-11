import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Selah typography system
/// Serif = tradition (Cormorant Garamond for Scripture)
/// Sans-serif = modern (System font for UI)
class SelahTypography {
  SelahTypography._();

  /// Scripture display - large, gold, Cormorant Garamond
  /// Used for Scripture verses on intervention screens
  static TextStyle get scriptureDisplay => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: SelahColors.sacredGold,
        height: 1.4,
        letterSpacing: 0.5,
      );

  /// Scripture reference - smaller attribution
  static TextStyle get scriptureReference => GoogleFonts.cormorantGaramond(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: SelahColors.sacredGold.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
        height: 1.4,
      );

  /// Reflection text - italic, contemplative
  /// Used for sub-prompts and reflections
  static TextStyle get reflection => GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: SelahColors.warmCream.withValues(alpha: 0.9),
        fontStyle: FontStyle.italic,
        height: 1.5,
      );

  /// Breath prayer - centered, simple
  static TextStyle get breathPrayer => GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: SelahColors.sacredGold,
        letterSpacing: 2.0,
        height: 1.6,
      );

  /// Heading 1 - large headings
  static TextStyle get heading1 => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: SelahColors.charcoal,
        height: 1.3,
      );

  /// Heading 2 - section headings
  static TextStyle get heading2 => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: SelahColors.charcoal,
        height: 1.3,
      );

  /// Heading 3 - subsection headings
  static TextStyle get heading3 => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: SelahColors.charcoal,
        height: 1.4,
      );

  /// Body text - standard readable text
  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: SelahColors.charcoal,
        height: 1.5,
      );

  /// Body text on dark backgrounds
  static TextStyle get bodyLight => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: SelahColors.warmCream,
        height: 1.5,
      );

  /// Small text - metadata, captions
  static TextStyle get caption => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: SelahColors.subduedGray,
        height: 1.4,
      );

  /// Button label - primary buttons
  static TextStyle get buttonPrimary => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: SelahColors.deepNavy,
        letterSpacing: 0.5,
      );

  /// Button label - secondary/subdued buttons
  static TextStyle get buttonSecondary => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: SelahColors.subduedGray,
        letterSpacing: 0.3,
      );

  /// Navigation label
  static TextStyle get navLabel => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: SelahColors.subduedGray,
      );

  /// Stats display - numbers
  static TextStyle get statsNumber => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: SelahColors.sacredGold,
      );

  /// Stats label
  static TextStyle get statsLabel => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: SelahColors.warmCream,
        letterSpacing: 0.5,
      );
}
