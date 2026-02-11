import 'dart:convert';

/// User settings and preferences for Selah.
class UserSettings {
  /// Christian tradition: catholic, protestant, orthodox, exploring
  final String tradition;

  /// Language code: en, es, etc.
  final String language;

  /// Schedule mode: always, evening, sabbath, custom
  final String scheduleMode;

  /// Custom schedule start time (for custom mode)
  final String? customStart;

  /// Custom schedule end time (for custom mode)
  final String? customEnd;

  /// Custom schedule days as JSON array (for custom mode)
  final List<String>? customDays;

  /// Whether user has premium subscription
  final bool isPremium;

  /// Whether settings are currently locked (Armor Lock)
  final bool armorLocked;

  /// When the Armor Lock expires
  final DateTime? armorLockUntil;

  /// Custom starting friction in seconds (premium, default 5)
  final int frictionStartSec;

  /// Morning verse notification enabled
  final bool notificationsMorning;

  /// Midday reminder notification enabled
  final bool notificationsMidday;

  /// Evening examen notification enabled
  final bool notificationsEvening;

  /// Celebration notification enabled
  final bool notificationsCelebration;

  /// Weekly review notification enabled (default true)
  final bool notificationsWeekly;

  /// Whether user has completed onboarding
  final bool onboardingComplete;

  const UserSettings({
    this.tradition = 'exploring',
    this.language = 'en',
    this.scheduleMode = 'always',
    this.customStart,
    this.customEnd,
    this.customDays,
    this.isPremium = false,
    this.armorLocked = false,
    this.armorLockUntil,
    this.frictionStartSec = 5,
    this.notificationsMorning = false,
    this.notificationsMidday = false,
    this.notificationsEvening = false,
    this.notificationsCelebration = false,
    this.notificationsWeekly = true,
    this.onboardingComplete = false,
  });

  /// Default settings for a new user
  factory UserSettings.defaults() => const UserSettings();

  /// Get the display name for the current tradition
  String get traditionDisplayName {
    switch (tradition) {
      case 'catholic':
        return 'Catholic';
      case 'protestant':
        return 'Protestant';
      case 'orthodox':
        return 'Orthodox';
      case 'exploring':
      default:
        return 'Exploring';
    }
  }

  /// Get the "offer it up" label based on tradition
  String get offerUpLabel {
    return tradition == 'catholic' ? 'Offer it up' : 'Dedicate this moment';
  }

  Map<String, dynamic> toMap() {
    return {
      'tradition': tradition,
      'language': language,
      'schedule_mode': scheduleMode,
      'custom_start': customStart,
      'custom_end': customEnd,
      'custom_days': customDays != null ? jsonEncode(customDays) : null,
      'is_premium': isPremium ? 1 : 0,
      'armor_locked': armorLocked ? 1 : 0,
      'armor_lock_until': armorLockUntil?.toIso8601String(),
      'friction_start_sec': frictionStartSec,
      'notifications_morning': notificationsMorning ? 1 : 0,
      'notifications_midday': notificationsMidday ? 1 : 0,
      'notifications_evening': notificationsEvening ? 1 : 0,
      'notifications_celebration': notificationsCelebration ? 1 : 0,
      'notifications_weekly': notificationsWeekly ? 1 : 0,
      'onboarding_complete': onboardingComplete ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    List<String>? customDays;
    if (map['custom_days'] != null) {
      final decoded = jsonDecode(map['custom_days'] as String);
      customDays = (decoded as List).cast<String>();
    }

    return UserSettings(
      tradition: map['tradition'] as String? ?? 'exploring',
      language: map['language'] as String? ?? 'en',
      scheduleMode: map['schedule_mode'] as String? ?? 'always',
      customStart: map['custom_start'] as String?,
      customEnd: map['custom_end'] as String?,
      customDays: customDays,
      isPremium: (map['is_premium'] as int? ?? 0) == 1,
      armorLocked: (map['armor_locked'] as int? ?? 0) == 1,
      armorLockUntil: map['armor_lock_until'] != null
          ? DateTime.parse(map['armor_lock_until'] as String)
          : null,
      frictionStartSec: map['friction_start_sec'] as int? ?? 5,
      notificationsMorning: (map['notifications_morning'] as int? ?? 0) == 1,
      notificationsMidday: (map['notifications_midday'] as int? ?? 0) == 1,
      notificationsEvening: (map['notifications_evening'] as int? ?? 0) == 1,
      notificationsCelebration: (map['notifications_celebration'] as int? ?? 0) == 1,
      notificationsWeekly: (map['notifications_weekly'] as int? ?? 1) == 1,
      onboardingComplete: (map['onboarding_complete'] as int? ?? 0) == 1,
    );
  }

  UserSettings copyWith({
    String? tradition,
    String? language,
    String? scheduleMode,
    String? customStart,
    String? customEnd,
    List<String>? customDays,
    bool? isPremium,
    bool? armorLocked,
    DateTime? armorLockUntil,
    int? frictionStartSec,
    bool? notificationsMorning,
    bool? notificationsMidday,
    bool? notificationsEvening,
    bool? notificationsCelebration,
    bool? notificationsWeekly,
    bool? onboardingComplete,
  }) {
    return UserSettings(
      tradition: tradition ?? this.tradition,
      language: language ?? this.language,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      customDays: customDays ?? this.customDays,
      isPremium: isPremium ?? this.isPremium,
      armorLocked: armorLocked ?? this.armorLocked,
      armorLockUntil: armorLockUntil ?? this.armorLockUntil,
      frictionStartSec: frictionStartSec ?? this.frictionStartSec,
      notificationsMorning: notificationsMorning ?? this.notificationsMorning,
      notificationsMidday: notificationsMidday ?? this.notificationsMidday,
      notificationsEvening: notificationsEvening ?? this.notificationsEvening,
      notificationsCelebration: notificationsCelebration ?? this.notificationsCelebration,
      notificationsWeekly: notificationsWeekly ?? this.notificationsWeekly,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  String toString() {
    return 'UserSettings(tradition: $tradition, language: $language, scheduleMode: $scheduleMode, onboardingComplete: $onboardingComplete)';
  }
}

/// Available Christian traditions
class Tradition {
  static const String catholic = 'catholic';
  static const String protestant = 'protestant';
  static const String orthodox = 'orthodox';
  static const String exploring = 'exploring';

  static const List<String> all = [catholic, protestant, orthodox, exploring];
}

/// Available schedule modes
class ScheduleMode {
  static const String always = 'always';
  static const String evening = 'evening';
  static const String sabbath = 'sabbath';
  static const String custom = 'custom';

  static const List<String> all = [always, evening, sabbath, custom];
}
