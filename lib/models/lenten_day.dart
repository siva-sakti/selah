/// Represents a day in the liturgical season with Scripture and reflection content.
class LentenDay {
  /// Day number (1-40 for Lent, 1-50 for Easter, etc.)
  final int id;

  /// Liturgical season: lent, easter, ordinary, advent
  final String season;

  /// e.g., "Thursday of the Third Week of Lent"
  final String liturgicalLabel;

  /// Scripture reference, e.g., "Psalm 51:10"
  final String scriptureRef;

  /// Full Scripture text
  final String scriptureText;

  /// Short breath prayer for first attempt ("Be still.", "Lord, have mercy.")
  final String breathPrayer;

  /// Reflection question for deeper engagement
  final String reflection;

  /// Saint or biblical figure name (nullable, tradition-specific)
  final String? companionName;

  /// Quote from the companion (nullable, tradition-specific)
  final String? companionQuote;

  const LentenDay({
    required this.id,
    required this.season,
    required this.liturgicalLabel,
    required this.scriptureRef,
    required this.scriptureText,
    required this.breathPrayer,
    required this.reflection,
    this.companionName,
    this.companionQuote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'season': season,
      'liturgical_label': liturgicalLabel,
      'scripture_ref': scriptureRef,
      'scripture_text': scriptureText,
      'breath_prayer': breathPrayer,
      'reflection': reflection,
      'companion_name': companionName,
      'companion_quote': companionQuote,
    };
  }

  factory LentenDay.fromMap(Map<String, dynamic> map) {
    return LentenDay(
      id: map['id'] as int,
      season: map['season'] as String,
      liturgicalLabel: map['liturgical_label'] as String,
      scriptureRef: map['scripture_ref'] as String,
      scriptureText: map['scripture_text'] as String,
      breathPrayer: map['breath_prayer'] as String,
      reflection: map['reflection'] as String,
      companionName: map['companion_name'] as String?,
      companionQuote: map['companion_quote'] as String?,
    );
  }

  LentenDay copyWith({
    int? id,
    String? season,
    String? liturgicalLabel,
    String? scriptureRef,
    String? scriptureText,
    String? breathPrayer,
    String? reflection,
    String? companionName,
    String? companionQuote,
  }) {
    return LentenDay(
      id: id ?? this.id,
      season: season ?? this.season,
      liturgicalLabel: liturgicalLabel ?? this.liturgicalLabel,
      scriptureRef: scriptureRef ?? this.scriptureRef,
      scriptureText: scriptureText ?? this.scriptureText,
      breathPrayer: breathPrayer ?? this.breathPrayer,
      reflection: reflection ?? this.reflection,
      companionName: companionName ?? this.companionName,
      companionQuote: companionQuote ?? this.companionQuote,
    );
  }

  @override
  String toString() {
    return 'LentenDay(id: $id, season: $season, liturgicalLabel: $liturgicalLabel)';
  }
}
