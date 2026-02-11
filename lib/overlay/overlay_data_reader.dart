import 'package:shared_preferences/shared_preferences.dart';

/// Minimal data reader for the overlay - no heavy dependencies.
/// This file is safe to import in the overlay's separate Flutter engine.
class OverlayDataReader {
  // SharedPreferences keys (must match OverlayDataService)
  static const String keyAppPackage = 'overlay_app_package';
  static const String keyAppName = 'overlay_app_name';
  static const String keyScriptureRef = 'overlay_scripture_ref';
  static const String keyScriptureText = 'overlay_scripture_text';
  static const String keyBreathPrayer = 'overlay_breath_prayer';
  static const String keyReflection = 'overlay_reflection';
  static const String keyCompanionName = 'overlay_companion_name';
  static const String keyCompanionQuote = 'overlay_companion_quote';
  static const String keyAttemptCount = 'overlay_attempt_count';
  static const String keyPauseDuration = 'overlay_pause_duration';
  static const String keyTradition = 'overlay_tradition';
  static const String keySubPrompt = 'overlay_sub_prompt';
  static const String keyLentenDay = 'overlay_lenten_day';

  // Result keys
  static const String keyResultPending = 'overlay_result_pending';
  static const String keyResultOutcome = 'overlay_result_outcome';
  static const String keyResultReason = 'overlay_result_reason';
  static const String keyResultOfferingText = 'overlay_result_offering_text';
  static const String keyResultTimestamp = 'overlay_result_timestamp';
  static const String keyResultTimeSavedEst = 'overlay_result_time_saved_est';

  /// Read overlay data from SharedPreferences
  static Future<OverlayDisplayData> readData() async {
    final prefs = await SharedPreferences.getInstance();

    return OverlayDisplayData(
      appPackage: prefs.getString(keyAppPackage) ?? '',
      appName: prefs.getString(keyAppName) ?? 'App',
      scriptureRef: prefs.getString(keyScriptureRef) ?? 'Psalm 51:10',
      scriptureText: prefs.getString(keyScriptureText) ??
          'Create in me a clean heart, O God, and renew a right spirit within me.',
      breathPrayer: prefs.getString(keyBreathPrayer) ?? 'Be still.',
      reflection: prefs.getString(keyReflection) ?? 'What draws you here?',
      companionName: prefs.getString(keyCompanionName) ?? '',
      companionQuote: prefs.getString(keyCompanionQuote) ?? '',
      attemptCount: prefs.getInt(keyAttemptCount) ?? 1,
      pauseDuration: prefs.getInt(keyPauseDuration) ?? 5,
      tradition: prefs.getString(keyTradition) ?? 'exploring',
      subPrompt: prefs.getString(keySubPrompt),
      lentenDay: prefs.getInt(keyLentenDay) ?? 1,
    );
  }

  /// Write intervention result to SharedPreferences
  static Future<void> writeResult({
    required String outcome,
    String? reason,
    String? offeringText,
    int timeSavedEst = 300,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(keyResultPending, true);
    await prefs.setString(keyResultOutcome, outcome);
    await prefs.setString(keyResultTimestamp, DateTime.now().toIso8601String());
    await prefs.setInt(keyResultTimeSavedEst, timeSavedEst);

    if (reason != null) {
      await prefs.setString(keyResultReason, reason);
    } else {
      await prefs.remove(keyResultReason);
    }

    if (offeringText != null) {
      await prefs.setString(keyResultOfferingText, offeringText);
    } else {
      await prefs.remove(keyResultOfferingText);
    }
  }
}

/// Data class for overlay display - minimal, no heavy dependencies
class OverlayDisplayData {
  final String appPackage;
  final String appName;
  final String scriptureRef;
  final String scriptureText;
  final String breathPrayer;
  final String reflection;
  final String companionName;
  final String companionQuote;
  final int attemptCount;
  final int pauseDuration;
  final String tradition;
  final String? subPrompt;
  final int lentenDay;

  OverlayDisplayData({
    required this.appPackage,
    required this.appName,
    required this.scriptureRef,
    required this.scriptureText,
    required this.breathPrayer,
    required this.reflection,
    required this.companionName,
    required this.companionQuote,
    required this.attemptCount,
    required this.pauseDuration,
    required this.tradition,
    required this.subPrompt,
    required this.lentenDay,
  });

  String get offerUpLabel {
    return tradition == 'catholic' ? 'Offer it up' : 'Dedicate this moment';
  }

  bool get isEscalated => attemptCount > 1;
  bool get hasCompanion => companionName.isNotEmpty;
}
