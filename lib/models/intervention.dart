/// Represents a single intervention event when the user opened a guarded app.
class Intervention {
  /// Auto-increment ID
  final int? id;

  /// When the intervention occurred
  final DateTime timestamp;

  /// Package name of the app that was opened
  final String appPackage;

  /// Outcome: "resisted" or "proceeded"
  final String outcome;

  /// If proceeded: reason selected (boredom, anxiety, loneliness, habit, escape, envy, needed)
  final String? reason;

  /// If resisted: the dedication/offering text
  final String? offeringText;

  /// Scripture reference that was shown
  final String scriptureShown;

  /// How long the pause lasted in seconds
  final int pauseDuration;

  /// Which attempt this was today (1st, 2nd, 3rd, etc.)
  final int attemptNumber;

  /// Estimated time saved in seconds (default 300 = 5 minutes)
  final int timeSavedEst;

  const Intervention({
    this.id,
    required this.timestamp,
    required this.appPackage,
    required this.outcome,
    this.reason,
    this.offeringText,
    required this.scriptureShown,
    required this.pauseDuration,
    required this.attemptNumber,
    this.timeSavedEst = 300,
  });

  /// Whether the user chose to return to prayer
  bool get wasResisted => outcome == 'resisted';

  /// Whether the user chose to proceed to the app
  bool get wasProceeded => outcome == 'proceeded';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'app_package': appPackage,
      'outcome': outcome,
      'reason': reason,
      'offering_text': offeringText,
      'scripture_shown': scriptureShown,
      'pause_duration': pauseDuration,
      'attempt_number': attemptNumber,
      'time_saved_est': timeSavedEst,
    };
  }

  factory Intervention.fromMap(Map<String, dynamic> map) {
    return Intervention(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      appPackage: map['app_package'] as String,
      outcome: map['outcome'] as String,
      reason: map['reason'] as String?,
      offeringText: map['offering_text'] as String?,
      scriptureShown: map['scripture_shown'] as String,
      pauseDuration: map['pause_duration'] as int,
      attemptNumber: map['attempt_number'] as int,
      timeSavedEst: map['time_saved_est'] as int? ?? 300,
    );
  }

  Intervention copyWith({
    int? id,
    DateTime? timestamp,
    String? appPackage,
    String? outcome,
    String? reason,
    String? offeringText,
    String? scriptureShown,
    int? pauseDuration,
    int? attemptNumber,
    int? timeSavedEst,
  }) {
    return Intervention(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      appPackage: appPackage ?? this.appPackage,
      outcome: outcome ?? this.outcome,
      reason: reason ?? this.reason,
      offeringText: offeringText ?? this.offeringText,
      scriptureShown: scriptureShown ?? this.scriptureShown,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      timeSavedEst: timeSavedEst ?? this.timeSavedEst,
    );
  }

  @override
  String toString() {
    return 'Intervention(id: $id, appPackage: $appPackage, outcome: $outcome, attemptNumber: $attemptNumber)';
  }
}

/// Possible reasons for proceeding to a guarded app
class ProceedReason {
  static const String boredom = 'boredom';
  static const String anxiety = 'anxiety';
  static const String loneliness = 'loneliness';
  static const String habit = 'habit';
  static const String escape = 'escape';
  static const String envy = 'envy';
  static const String needed = 'needed';

  static const List<String> all = [
    boredom,
    anxiety,
    loneliness,
    habit,
    escape,
    envy,
    needed,
  ];

  static String getDisplayName(String reason) {
    switch (reason) {
      case boredom:
        return 'Boredom';
      case anxiety:
        return 'Anxiety';
      case loneliness:
        return 'Loneliness';
      case habit:
        return 'Habit';
      case escape:
        return 'Escape';
      case envy:
        return 'Envy (comparing myself to others)';
      case needed:
        return 'I need this app for something specific';
      default:
        return reason;
    }
  }
}
