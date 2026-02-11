# Selah Accessibility Overlay - Technical Notes

## Overview
This document captures the correct approach for implementing the AccessibilityService overlay system, including issues encountered and their solutions.

---

## Architecture Summary

### How It Works
```
┌─────────────────────────────────────────────────────────────────┐
│                    ANDROID OS                                    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  AccessibilityService (from flutter_accessibility_service)  ││
│  │  - Runs as system service when permission granted           ││
│  │  - Detects window state changes across ALL apps             ││
│  │  - Manages overlay window creation/destruction              ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┴────────────────────┐
         ▼                                         ▼
┌─────────────────────┐                 ┌─────────────────────┐
│  FLUTTER ENGINE #1  │                 │  FLUTTER ENGINE #2  │
│  (Main App)         │                 │  (Overlay)          │
│                     │                 │                     │
│  main() entry point │                 │  accessibilityOverlay() │
│  - UI screens       │                 │  @pragma("vm:entry-point") │
│  - Database access  │                 │  - Self-contained widget │
│  - AccessibilityHandler              │  - NO shared state     │
└─────────────────────┘                 └─────────────────────┘
```

### Key Files
- `lib/main.dart` - Contains `@pragma("vm:entry-point") void accessibilityOverlay()`
- `lib/overlay/overlay_main.dart` - Standalone overlay widget
- `lib/services/accessibility_handler.dart` - Stream subscription and event handling
- `lib/services/overlay_data_service.dart` - SharedPreferences bridge for main app ↔ overlay
- `android/app/src/main/AndroidManifest.xml` - Service declaration
- `android/app/src/main/res/xml/accessibilityservice.xml` - Service configuration

---

## Critical Configuration (MUST HAVE)

### 1. AndroidManifest.xml
```xml
<service
    android:name="slayer.accessibility.service.flutter_accessibility_service.AccessibilityListener"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">  <!-- MUST be true -->
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibilityservice" />
</service>
```

### 2. accessibilityservice.xml
```xml
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackVisual"
    android:notificationTimeout="300"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagReportViewIds|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
    android:description="@string/accessibility_service_description" />
```

**Note:** `canRetrieveWindowContent="true"` is required for events to flow properly. The product spec wanted `false` for privacy - test if it works with `false` after confirming everything works.

### 3. Overlay Entry Point (main.dart)
```dart
@pragma("vm:entry-point")
void accessibilityOverlay() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InterventionOverlayStandalone());
}
```

---

## Issues Encountered & Solutions

### Issue 1: Accessibility permission shows as `false` even after enabling
**Symptom:** User enables permission in Settings, but app still reports `false`
**Cause:** Permission check happens once at app startup
**Solution:** Use `WidgetsBindingObserver` to re-check when app resumes:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _checkAndStartAccessibility();
  }
}
```

### Issue 2: Stream subscription created before permission granted = no events
**Symptom:** `TREE_DEPTH` logs appear (native service working) but no Flutter events
**Cause:** Stream subscription created before accessibility permission was granted. The subscription is "dead" - not connected to the native service.
**Solution:** Force restart the stream subscription AFTER permission is confirmed enabled:
```dart
Future<void> startListening({bool force = false}) async {
  if (force && _subscription != null) {
    await _subscription!.cancel();
    _subscription = null;
  }
  // ... create new subscription
}

// When checking accessibility:
if (isEnabled) {
  await _accessibilityHandler.startListening(force: true);
}
```

### Issue 3: Service class not found
**Symptom:** App crashes or service doesn't appear in Accessibility settings
**Cause:** Wrong service class name in manifest
**Solution:** Use the exact class from flutter_accessibility_service package:
```
slayer.accessibility.service.flutter_accessibility_service.AccessibilityListener
```
NOT a custom class name.

### Issue 4: Events not received even with correct configuration
**Symptom:** Service appears in settings, permission granted, but no events
**Cause:** Missing flags or `canRetrieveWindowContent="false"`
**Solution:** Match the example configuration exactly (see Critical Configuration above)

### Issue 5: Emulator crashes / "DeadSystemException"
**Symptom:** Random emulator crashes during testing
**Solution:** Restart emulator: `flutter emulators --launch Pixel_7`

---

## Testing Workflow

1. **Launch emulator:** `flutter emulators --launch Pixel_7`
2. **Run app:** `flutter run`
3. **Enable accessibility:** Settings → Accessibility → Selah → ON
4. **Return to Selah app** (tap on it to trigger resume check)
5. **Open guarded app** (YouTube, Instagram, TikTok)
6. **Overlay should appear**

### What to look for in logs:
- `AccessibilityHandler: Creating new stream subscription...` - Good
- `AccessibilityHandler: Event received - type:...` - Events flowing
- `AccessibilityHandler: GUARDED APP DETECTED` - Detection working
- `AccessibilityHandler: showOverlayWindow result: true` - Overlay shown

---

## Overlay Limitations

1. **Separate Flutter engine** - Cannot share state/providers with main app
2. **No direct communication** - Use SharedPreferences to pass data (see below)
3. **Styling must be self-contained** - Can't use main app's theme
4. **Hot reload doesn't affect overlay** - Need full restart for overlay changes

---

## Data Flow via SharedPreferences

Since the overlay runs in a separate Flutter engine, we use SharedPreferences as a bridge.

### Main App → Overlay (before showing overlay)
Written by `OverlayDataService.prepareOverlayData()`:
- App package name + display name
- Scripture reference and text (based on Lenten day number)
- Breath prayer, reflection, companion name/quote
- Attempt count for this specific app today
- Pause duration (escalates: 5s → 10s → 20s → 30s)
- User's tradition (determines "Offer it up" vs "Dedicate this moment")
- Sub-prompt for escalated attempts (attempt 2+)

### Overlay → Main App (after user makes choice)
Written by `OverlayDataService.writeInterventionResult()`:
- Outcome: "resisted" or "proceeded"
- If proceeded: examination reason
- If resisted: offering text
- Timestamp, pause duration, scripture shown, time saved estimate

### Main App Consumption (on resume)
When the main app resumes, `_consumePendingInterventionResult()` in `app.dart`:
1. Reads pending result from SharedPreferences
2. Creates an `Intervention` model
3. Writes to SQLite database
4. Clears the pending result

---

## Guarded Apps System

### How Guarded Apps Work
Apps are "guarded" based on their Android package name. When the AccessibilityService detects a window state change from a guarded package, it triggers the intervention overlay.

### Current Hardcoded Apps (for testing)
Set in `lib/app.dart` `_initializeAccessibilityService()`:
```dart
_accessibilityHandler.addGuardedApp(CommonApps.instagram);  // com.instagram.android
_accessibilityHandler.addGuardedApp(CommonApps.youtube);    // com.google.android.youtube
_accessibilityHandler.addGuardedApp(CommonApps.tiktok);     // com.zhiliaoapp.musically
```

### Common App Package Names
Defined in `lib/services/accessibility_handler.dart`:
| App | Package Name |
|-----|--------------|
| Instagram | `com.instagram.android` |
| TikTok | `com.zhiliaoapp.musically` |
| YouTube | `com.google.android.youtube` |
| X (Twitter) | `com.twitter.android` |
| Reddit | `com.reddit.frontpage` |
| Facebook | `com.facebook.katana` |
| Snapchat | `com.snapchat.android` |
| Pinterest | `com.pinterest` |

### Adding More Apps
To add any app:
1. Find the app's package name (use apps like "Package Name Viewer" or check the Play Store URL)
2. Add to `guarded_apps` table in the database (or call `_accessibilityHandler.addGuardedApp(packageName)`)
3. Optionally add display name mapping in `OverlayDataService.appDisplayNames`

### Future: User-Selectable Apps
The database has a `guarded_apps` table ready for user-managed apps:
```sql
CREATE TABLE guarded_apps (
  package_name TEXT PRIMARY KEY,  -- e.g., com.instagram.android
  app_name TEXT NOT NULL,          -- Display name
  is_active INTEGER DEFAULT 1,     -- 1 = guarded, 0 = paused
  added_at TEXT                    -- When user added it
);
```

The Settings screen will let users:
1. Browse installed apps
2. Select which to guard
3. Toggle guarding on/off per app

---

## Escalation System

### Pause Duration by Attempt
| Attempt | Duration | Sub-prompt shown? |
|---------|----------|-------------------|
| 1 | 5 sec | No |
| 2 | 10 sec | Yes - "What are you looking for right now?" |
| 3 | 20 sec | Yes - "You've come back three times today..." |
| 4 | 30 sec | Yes - "He sees you here. He loves you here..." |
| 5+ | 30 sec | Yes - "You've been here five times..." |

### Future: User-Customizable Starting Duration
The `user_settings.friction_start_sec` field allows customization of the base duration.

---

## Future Improvements

1. Test if `canRetrieveWindowContent="false"` works (for privacy)
2. Add offering text input when user chooses "Return to prayer"
3. Add examination reason selection when user chooses "Proceed"
4. Build Settings UI for user-managed guarded apps
5. Show companion name/quote in overlay for traditions that have them

---

## Package Reference
- Package: `flutter_accessibility_service: ^1.0.0`
- GitHub: https://github.com/AhmedAbouelkher/flutter_accessibility_service
- Key APIs:
  - `FlutterAccessibilityService.accessStream` - Event stream
  - `FlutterAccessibilityService.showOverlayWindow()` - Show overlay
  - `FlutterAccessibilityService.hideOverlayWindow()` - Hide overlay
  - `FlutterAccessibilityService.performGlobalAction()` - Go home, back, etc.

---

*Last updated: February 11, 2026*
*This is the hardest technical piece of Selah - guard these notes well!*
