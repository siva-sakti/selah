import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/lenten_day.dart';
import 'database_helper.dart';

/// Handles loading and seeding content from JSON files.
class SeedData {
  /// Seed all content into the database
  static Future<void> seedAll(DatabaseHelper db) async {
    await seedLentenContent(db);
  }

  /// Seed Lenten content from JSON files
  static Future<void> seedLentenContent(DatabaseHelper db) async {
    // For now, load universal English content
    // Later, we'll load tradition-specific content based on user settings
    try {
      final jsonString = await rootBundle.loadString(
        'lib/content/lent_universal_en.json',
      );
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> days = data['days'] ?? [];

      for (final dayData in days) {
        final day = LentenDay(
          id: dayData['day'] as int,
          season: data['season'] as String? ?? 'lent',
          liturgicalLabel: dayData['liturgical_label'] as String,
          scriptureRef: dayData['scripture_ref'] as String,
          scriptureText: dayData['scripture_text'] as String,
          breathPrayer: dayData['breath_prayer'] as String,
          reflection: dayData['reflection'] as String,
          companionName: dayData['companion_name'] as String?,
          companionQuote: dayData['companion_quote'] as String?,
        );

        await db.insertLentenDay(day);
      }

      debugPrint('SeedData: Loaded ${days.length} Lenten days');
    } catch (e) {
      debugPrint('SeedData: Error loading Lenten content: $e');
    }
  }

  /// Load tradition-specific content
  static Future<List<LentenDay>> loadTraditionContent(
    String tradition,
    String language,
  ) async {
    final List<LentenDay> days = [];

    try {
      // Try to load tradition-specific file first
      String filename = 'lib/content/lent_${tradition}_$language.json';

      String jsonString;
      try {
        jsonString = await rootBundle.loadString(filename);
      } catch (_) {
        // Fall back to universal if tradition-specific doesn't exist
        filename = 'lib/content/lent_universal_$language.json';
        try {
          jsonString = await rootBundle.loadString(filename);
        } catch (_) {
          // Fall back to English universal if language doesn't exist
          filename = 'lib/content/lent_universal_en.json';
          jsonString = await rootBundle.loadString(filename);
        }
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> daysList = data['days'] ?? [];

      for (final dayData in daysList) {
        days.add(LentenDay(
          id: dayData['day'] as int,
          season: data['season'] as String? ?? 'lent',
          liturgicalLabel: dayData['liturgical_label'] as String,
          scriptureRef: dayData['scripture_ref'] as String,
          scriptureText: dayData['scripture_text'] as String,
          breathPrayer: dayData['breath_prayer'] as String,
          reflection: dayData['reflection'] as String,
          companionName: dayData['companion_name'] as String?,
          companionQuote: dayData['companion_quote'] as String?,
        ));
      }
    } catch (e) {
      debugPrint('SeedData: Error loading tradition content: $e');
    }

    return days;
  }

  /// Get today's Lenten day number based on Ash Wednesday 2026
  static int getTodayLentDay() {
    // Ash Wednesday 2026 is February 18
    final ashWednesday2026 = DateTime(2026, 2, 18);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final difference = todayStart.difference(ashWednesday2026).inDays;

    // If before Lent, return day 1
    if (difference < 0) return 1;

    // If after Lent (40 days), return day 40
    if (difference >= 40) return 40;

    // Otherwise return the actual day (1-indexed)
    return difference + 1;
  }

  /// Calculate the current liturgical season
  static String getCurrentSeason() {
    final now = DateTime.now();

    // Ash Wednesday 2026: February 18
    // Easter 2026: April 5
    // Pentecost 2026: May 24

    final ashWednesday = DateTime(2026, 2, 18);
    final easter = DateTime(2026, 4, 5);
    final pentecost = DateTime(2026, 5, 24);

    // Advent starts 4 Sundays before Christmas
    final christmas = DateTime(now.year, 12, 25);
    final advent = christmas.subtract(Duration(days: 22 + christmas.weekday));

    if (now.isBefore(ashWednesday)) {
      return 'ordinary';
    } else if (now.isBefore(easter)) {
      return 'lent';
    } else if (now.isBefore(pentecost)) {
      return 'easter';
    } else if (now.isBefore(advent)) {
      return 'ordinary';
    } else {
      return 'advent';
    }
  }
}
