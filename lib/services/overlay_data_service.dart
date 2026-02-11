import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../database/seed_data.dart';
import '../models/lenten_day.dart';

/// Service for preparing and passing data to the overlay via SharedPreferences.
///
/// The overlay runs in a separate Flutter engine and cannot access the main app's
/// state directly. SharedPreferences is used as the bridge to pass data.
class OverlayDataService {
  static final OverlayDataService _instance = OverlayDataService._internal();
  factory OverlayDataService() => _instance;
  OverlayDataService._internal();

  final DatabaseHelper _db = DatabaseHelper();

  // SharedPreferences keys for overlay data (Main App → Overlay)
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

  // SharedPreferences keys for intervention result (Overlay → Main App)
  static const String keyResultPending = 'overlay_result_pending';
  static const String keyResultOutcome = 'overlay_result_outcome';
  static const String keyResultReason = 'overlay_result_reason';
  static const String keyResultOfferingText = 'overlay_result_offering_text';
  static const String keyResultTimestamp = 'overlay_result_timestamp';
  static const String keyResultTimeSavedEst = 'overlay_result_time_saved_est';

  /// Map of package names to display names
  static const Map<String, String> appDisplayNames = {
    'com.instagram.android': 'Instagram',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.google.android.youtube': 'YouTube',
    'com.twitter.android': 'X (Twitter)',
    'com.reddit.frontpage': 'Reddit',
    'com.facebook.katana': 'Facebook',
    'com.snapchat.android': 'Snapchat',
    'com.pinterest': 'Pinterest',
  };

  /// Escalating sub-prompts based on attempt count
  static const Map<int, String> subPrompts = {
    2: 'What are you looking for right now?',
    3: "You've come back three times today. What is your heart telling you?",
    4: 'He sees you here. He loves you here. Do you want to stay?',
    5: "You've been here five times. That's okay. But what would it feel like to stop?",
  };

  /// Calculate pause duration based on attempt count
  /// Attempt 1: 5 sec, Attempt 2: 10 sec, Attempt 3: 20 sec, Attempt 4+: 30 sec
  static int getPauseDuration(int attemptCount, {int baseDuration = 5}) {
    switch (attemptCount) {
      case 1:
        return baseDuration; // Default 5 seconds
      case 2:
        return 10;
      case 3:
        return 20;
      default:
        return 30; // Max pause duration
    }
  }

  /// Get display name for a package
  static String getAppDisplayName(String packageName) {
    return appDisplayNames[packageName] ?? _extractAppName(packageName);
  }

  /// Extract a readable name from package name if not in our map
  static String _extractAppName(String packageName) {
    // com.example.myapp -> Myapp
    final parts = packageName.split('.');
    if (parts.isEmpty) return packageName;
    final lastPart = parts.last;
    if (lastPart.isEmpty) return packageName;
    return lastPart[0].toUpperCase() + lastPart.substring(1);
  }

  /// Get sub-prompt for escalating attempts (null for attempt 1)
  static String? getSubPrompt(int attemptCount) {
    if (attemptCount >= 5) return subPrompts[5];
    return subPrompts[attemptCount];
  }

  /// Prepare overlay data and write to SharedPreferences.
  /// Call this BEFORE showing the overlay.
  Future<void> prepareOverlayData(String packageName) async {
    debugPrint('OverlayDataService: Preparing data for $packageName');

    try {
      // Ensure database is initialized and seeded
      await _db.seedContentIfNeeded();

      // Get user settings
      final settings = await _db.getUserSettings();

      // Calculate today's Lenten day
      final lentenDayNumber = SeedData.getTodayLentDay();

      // Get today's content
      LentenDay? content = await _db.getLentenDay(lentenDayNumber);

      // Fallback to day 1 if no content found
      if (content == null) {
        debugPrint('OverlayDataService: No content for day $lentenDayNumber, falling back to day 1');
        content = await _db.getLentenDay(1);
      }

      // Get attempt count for this specific app (before this attempt)
      final previousAttempts = await _db.getTodayAttemptsForApp(packageName);
      final attemptNumber = previousAttempts + 1; // This is the current attempt

      // Calculate pause duration based on attempt and user's friction setting
      final pauseDuration = getPauseDuration(
        attemptNumber,
        baseDuration: settings.frictionStartSec,
      );

      // Get sub-prompt for escalating attempts
      final subPrompt = getSubPrompt(attemptNumber);

      // Get app display name
      final appDisplayName = getAppDisplayName(packageName);

      // Write to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(keyAppPackage, packageName);
      await prefs.setString(keyAppName, appDisplayName);
      await prefs.setInt(keyAttemptCount, attemptNumber);
      await prefs.setInt(keyPauseDuration, pauseDuration);
      await prefs.setString(keyTradition, settings.tradition);
      await prefs.setInt(keyLentenDay, lentenDayNumber);

      if (content != null) {
        await prefs.setString(keyScriptureRef, content.scriptureRef);
        await prefs.setString(keyScriptureText, content.scriptureText);
        await prefs.setString(keyBreathPrayer, content.breathPrayer);
        await prefs.setString(keyReflection, content.reflection);
        await prefs.setString(keyCompanionName, content.companionName ?? '');
        await prefs.setString(keyCompanionQuote, content.companionQuote ?? '');
      } else {
        // Hardcoded fallback if database fails
        await prefs.setString(keyScriptureRef, 'Psalm 51:10');
        await prefs.setString(keyScriptureText,
            'Create in me a clean heart, O God, and renew a right spirit within me.');
        await prefs.setString(keyBreathPrayer, 'Be still.');
        await prefs.setString(keyReflection, 'What draws you here?');
        await prefs.setString(keyCompanionName, '');
        await prefs.setString(keyCompanionQuote, '');
      }

      if (subPrompt != null) {
        await prefs.setString(keySubPrompt, subPrompt);
      } else {
        await prefs.remove(keySubPrompt);
      }

      debugPrint('OverlayDataService: Data prepared - app: $appDisplayName, '
          'attempt: $attemptNumber, pause: ${pauseDuration}s, day: $lentenDayNumber');
    } catch (e) {
      debugPrint('OverlayDataService: Error preparing data: $e');
      // Write minimal fallback data so overlay can still display something
      await _writeFallbackData(packageName);
    }
  }

  /// Write minimal fallback data if main preparation fails
  Future<void> _writeFallbackData(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAppPackage, packageName);
    await prefs.setString(keyAppName, getAppDisplayName(packageName));
    await prefs.setInt(keyAttemptCount, 1);
    await prefs.setInt(keyPauseDuration, 5);
    await prefs.setString(keyTradition, 'exploring');
    await prefs.setInt(keyLentenDay, 1);
    await prefs.setString(keyScriptureRef, 'Psalm 51:10');
    await prefs.setString(keyScriptureText,
        'Create in me a clean heart, O God, and renew a right spirit within me.');
    await prefs.setString(keyBreathPrayer, 'Be still.');
    await prefs.setString(keyReflection, 'What draws you here?');
    await prefs.setString(keyCompanionName, '');
    await prefs.setString(keyCompanionQuote, '');
  }

  /// Read overlay data from SharedPreferences (called by overlay)
  static Future<OverlayData> readOverlayData() async {
    final prefs = await SharedPreferences.getInstance();

    return OverlayData(
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

  /// Write intervention result to SharedPreferences (called by overlay)
  /// The main app will pick this up on resume and write to SQLite
  static Future<void> writeInterventionResult({
    required String outcome, // 'resisted' or 'proceeded'
    String? reason, // If proceeded: boredom/anxiety/loneliness/habit/escape/envy/needed
    String? offeringText, // If resisted: dedication text
    int timeSavedEst = 300, // Estimated time saved in seconds (default 5 min)
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

    debugPrint('OverlayDataService: Wrote intervention result - outcome: $outcome');
  }

  /// Check if there's a pending intervention result (called by main app on resume)
  Future<bool> hasPendingResult() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyResultPending) ?? false;
  }

  /// Read and clear pending intervention result (called by main app on resume)
  /// Returns null if no pending result
  Future<InterventionResult?> consumePendingResult() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(keyResultPending) ?? false)) {
      return null;
    }

    final result = InterventionResult(
      appPackage: prefs.getString(keyAppPackage) ?? '',
      outcome: prefs.getString(keyResultOutcome) ?? 'proceeded',
      reason: prefs.getString(keyResultReason),
      offeringText: prefs.getString(keyResultOfferingText),
      scriptureShown: prefs.getString(keyScriptureRef) ?? '',
      pauseDuration: prefs.getInt(keyPauseDuration) ?? 5,
      attemptNumber: prefs.getInt(keyAttemptCount) ?? 1,
      timeSavedEst: prefs.getInt(keyResultTimeSavedEst) ?? 300,
      timestamp: DateTime.tryParse(prefs.getString(keyResultTimestamp) ?? '') ??
          DateTime.now(),
    );

    // Clear the pending result
    await prefs.setBool(keyResultPending, false);

    debugPrint('OverlayDataService: Consumed pending result - ${result.outcome}');
    return result;
  }
}

/// Data class holding intervention result from overlay
class InterventionResult {
  final String appPackage;
  final String outcome; // 'resisted' or 'proceeded'
  final String? reason; // If proceeded
  final String? offeringText; // If resisted
  final String scriptureShown;
  final int pauseDuration;
  final int attemptNumber;
  final int timeSavedEst;
  final DateTime timestamp;

  InterventionResult({
    required this.appPackage,
    required this.outcome,
    this.reason,
    this.offeringText,
    required this.scriptureShown,
    required this.pauseDuration,
    required this.attemptNumber,
    required this.timeSavedEst,
    required this.timestamp,
  });

  bool get wasResisted => outcome == 'resisted';
  bool get wasProceeded => outcome == 'proceeded';
}

/// Data class holding all overlay display data
class OverlayData {
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

  OverlayData({
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

  /// Get the appropriate "offer up" label based on tradition
  String get offerUpLabel {
    return tradition == 'catholic' ? 'Offer it up' : 'Dedicate this moment';
  }

  /// Check if this is an escalated attempt (2+)
  bool get isEscalated => attemptCount > 1;

  /// Check if companion info is available
  bool get hasCompanion => companionName.isNotEmpty;
}
