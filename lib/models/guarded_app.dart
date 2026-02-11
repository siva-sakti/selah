/// Represents an app that is being guarded by Selah.
class GuardedApp {
  /// Android package name (e.g., com.instagram.android) - Primary Key
  final String packageName;

  /// Display name of the app
  final String appName;

  /// Whether the app is currently being guarded
  final bool isActive;

  /// When the app was added to the guarded list
  final DateTime addedAt;

  const GuardedApp({
    required this.packageName,
    required this.appName,
    required this.isActive,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'package_name': packageName,
      'app_name': appName,
      'is_active': isActive ? 1 : 0,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory GuardedApp.fromMap(Map<String, dynamic> map) {
    return GuardedApp(
      packageName: map['package_name'] as String,
      appName: map['app_name'] as String,
      isActive: (map['is_active'] as int) == 1,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  GuardedApp copyWith({
    String? packageName,
    String? appName,
    bool? isActive,
    DateTime? addedAt,
  }) {
    return GuardedApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isActive: isActive ?? this.isActive,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() {
    return 'GuardedApp(packageName: $packageName, appName: $appName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuardedApp && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;
}
