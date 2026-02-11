import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'overlay_data_service.dart';

/// Handles AccessibilityService integration for detecting app launches.
///
/// This service:
/// - Detects TYPE_WINDOW_STATE_CHANGED events
/// - Checks package names against guarded apps list
/// - Shows intervention overlay when a guarded app is opened
class AccessibilityHandler {
  static final AccessibilityHandler _instance = AccessibilityHandler._internal();
  factory AccessibilityHandler() => _instance;
  AccessibilityHandler._internal();

  StreamSubscription<AccessibilityEvent>? _subscription;

  /// List of package names that are currently guarded
  final Set<String> _guardedApps = {};

  /// Track if overlay is currently showing to prevent multiple triggers
  bool _overlayShowing = false;

  /// The last package that triggered the overlay (to avoid re-triggering)
  String? _lastTriggeredPackage;

  /// Callback when a guarded app is detected (optional, for logging/tracking)
  void Function(String packageName)? onGuardedAppDetected;

  /// Check if accessibility service is enabled
  Future<bool> isAccessibilityEnabled() async {
    try {
      return await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    } catch (e) {
      debugPrint('Error checking accessibility permission: $e');
      return false;
    }
  }

  /// Request accessibility permission (opens settings)
  Future<void> requestAccessibilityPermission() async {
    try {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    } catch (e) {
      debugPrint('Error requesting accessibility permission: $e');
    }
  }

  /// Start listening for accessibility events
  /// Set force=true to cancel existing subscription and create new one
  Future<void> startListening({bool force = false}) async {
    if (_subscription != null && !force) {
      debugPrint('AccessibilityHandler: Already listening');
      return;
    }

    // Cancel existing subscription if forcing restart
    if (force && _subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
      debugPrint('AccessibilityHandler: Cancelled existing subscription');
    }

    try {
      debugPrint('AccessibilityHandler: Creating new stream subscription...');
      _subscription = FlutterAccessibilityService.accessStream.listen(
        _handleAccessibilityEvent,
        onError: (error) {
          debugPrint('AccessibilityHandler error: $error');
        },
      );
      debugPrint('AccessibilityHandler: Started listening for events');
    } catch (e) {
      debugPrint('Error starting accessibility listener: $e');
    }
  }

  /// Stop listening for accessibility events
  Future<void> stopListening() async {
    if (_subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
      debugPrint('AccessibilityHandler: Stopped listening');
    }
  }

  /// Update the list of guarded apps
  void updateGuardedApps(List<String> packageNames) {
    _guardedApps.clear();
    _guardedApps.addAll(packageNames);
    debugPrint('AccessibilityHandler: Updated guarded apps: $_guardedApps');
  }

  /// Add a single app to the guarded list
  void addGuardedApp(String packageName) {
    _guardedApps.add(packageName);
    debugPrint('AccessibilityHandler: Added guarded app: $packageName');
  }

  /// Remove an app from the guarded list
  void removeGuardedApp(String packageName) {
    _guardedApps.remove(packageName);
    debugPrint('AccessibilityHandler: Removed guarded app: $packageName');
  }

  /// Check if an app is currently guarded
  bool isAppGuarded(String packageName) {
    return _guardedApps.contains(packageName);
  }

  /// Handle incoming accessibility events
  void _handleAccessibilityEvent(AccessibilityEvent event) {
    final packageName = event.packageName;
    final eventType = event.eventType;

    // Skip logging for non-guarded apps to reduce noise
    if (packageName != null && _guardedApps.contains(packageName)) {
      debugPrint('AccessibilityHandler: Event received - type: $eventType, package: $packageName');
    }

    // Check for window state changes OR any event from a guarded app
    if (packageName != null && packageName.isNotEmpty) {
      // Ignore events from our own app (the overlay generates these)
      if (packageName == 'com.selah.selah') {
        return;
      }

      // If user navigated away from a guarded app to a NON-guarded app, reset tracking
      if (_lastTriggeredPackage != null &&
          packageName != _lastTriggeredPackage &&
          !_guardedApps.contains(packageName)) {
        debugPrint('AccessibilityHandler: User left guarded app, resetting overlay tracking');
        _overlayShowing = false;
        _lastTriggeredPackage = null;
      }

      // Check if this is a guarded app
      if (_guardedApps.contains(packageName) && !_overlayShowing) {
        debugPrint('AccessibilityHandler: GUARDED APP DETECTED: $packageName');
        _lastTriggeredPackage = packageName;
        _showInterventionOverlay(packageName);
        onGuardedAppDetected?.call(packageName);
      }
    }
  }

  /// Show the intervention overlay
  Future<void> _showInterventionOverlay(String packageName) async {
    if (_overlayShowing) {
      debugPrint('AccessibilityHandler: Overlay already showing, skipping');
      return;
    }

    _overlayShowing = true;
    debugPrint('AccessibilityHandler: Showing intervention overlay for $packageName');

    try {
      // Hide any existing overlay first to ensure fresh state
      await FlutterAccessibilityService.hideOverlayWindow();

      // Prepare overlay data BEFORE showing overlay
      // This writes to SharedPreferences so the overlay can read it
      final overlayDataService = OverlayDataService();
      await overlayDataService.prepareOverlayData(packageName);

      // Small delay to ensure SharedPreferences is flushed
      await Future.delayed(const Duration(milliseconds: 50));

      // Show full-screen overlay
      final success = await FlutterAccessibilityService.showOverlayWindow();
      debugPrint('AccessibilityHandler: showOverlayWindow result: $success');

      if (!success) {
        _overlayShowing = false;
      }
    } catch (e) {
      debugPrint('AccessibilityHandler: Error showing overlay: $e');
      _overlayShowing = false;
    }
  }

  /// Called when overlay is dismissed (can be used for cleanup)
  void onOverlayDismissed() {
    _overlayShowing = false;
    _lastTriggeredPackage = null;
    debugPrint('AccessibilityHandler: Overlay dismissed');
  }

  /// Dispose of resources
  void dispose() {
    stopListening();
    _guardedApps.clear();
  }
}

/// Common app package names for quick reference
class CommonApps {
  static const String instagram = 'com.instagram.android';
  static const String tiktok = 'com.zhiliaoapp.musically';
  static const String youtube = 'com.google.android.youtube';
  static const String twitter = 'com.twitter.android';
  static const String reddit = 'com.reddit.frontpage';
  static const String facebook = 'com.facebook.katana';
  static const String snapchat = 'com.snapchat.android';
  static const String pinterest = 'com.pinterest';

  static List<String> get all => [
    instagram,
    tiktok,
    youtube,
    twitter,
    reddit,
    facebook,
    snapchat,
    pinterest,
  ];
}
