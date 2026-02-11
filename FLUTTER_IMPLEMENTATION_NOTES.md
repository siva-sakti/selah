# Selah - Flutter Implementation Notes

**Date:** February 11, 2026
**Status:** Proof of concept working, but recommend native Android for production
**Branch:** `flutter-attempt`

---

## Summary

This Flutter implementation successfully demonstrates the core Selah intervention flow:
- AccessibilityService detects when user opens a guarded app (Instagram, TikTok, YouTube)
- Full-screen overlay appears with Scripture and prayer prompt
- User can "Return to prayer" (goes home) or "Continue anyway" (proceeds to app)
- Data is passed between main app and overlay via SharedPreferences

**However**, the Flutter-to-native bridge introduces complexity that native Android would avoid.

---

## What Works

1. **AccessibilityService Integration**
   - Detects app launches via `flutter_accessibility_service` package
   - Correctly identifies guarded apps by package name
   - Shows system overlay when guarded app detected

2. **Intervention Overlay**
   - Full-screen overlay with Scripture, cross icon, buttons
   - Reads dynamic content from SharedPreferences
   - "Return to prayer" → hides overlay + goes to home screen
   - "Continue anyway" → hides overlay, lets target app open

3. **Content System**
   - 40-day Lenten content in JSON files (4 traditions × 2 languages)
   - SQLite database for user settings, interventions, guarded apps
   - Lenten day calculation based on Ash Wednesday 2026

4. **Data Flow**
   - Main app writes intervention data to SharedPreferences before showing overlay
   - Overlay reads and displays the data
   - Overlay writes result (resisted/proceeded) back to SharedPreferences
   - Main app consumes result on resume and logs to SQLite

---

## Technical Challenges Encountered

### 1. Dead Stream Subscription (Critical)

**Problem:** If you create the Flutter stream subscription before the native AccessibilityService is running, the subscription is "dead" - it never receives events.

**Symptoms:** Native `TREE_DEPTH` logs appear (service working) but no Flutter `Event received` logs.

**Solution:** Force-restart the subscription AFTER permission is confirmed enabled:
```dart
if (isEnabled) {
  await _accessibilityHandler.startListening(force: true);
}
```

**Workaround for UX:** Added periodic check (every 2 seconds) to detect when permission becomes enabled, so users don't have to manually return to the app.

### 2. Separate Flutter Engine for Overlay

**Problem:** The overlay runs in a completely separate Flutter engine/isolate. It cannot access:
- Main app's state/providers
- Main app's database connection
- Main app's theme

**Solution:** Use SharedPreferences as a bridge:
- Main app writes data before showing overlay
- Overlay reads data on launch
- Overlay writes result before dismissing
- Main app reads result on resume

**Gotcha:** The overlay's Flutter engine may persist between triggers. Must call `hideOverlayWindow()` before `showOverlayWindow()` to ensure fresh state.

### 3. Overlay Animations Not Working

**Problem:** FadeTransition animations in the overlay didn't work - content was invisible.

**Cause:** Unclear - possibly related to separate Flutter engine initialization.

**Solution:** Removed animations for now, content displays immediately.

### 4. Hot Reload Doesn't Affect Overlay

**Problem:** Hot reload/restart only affects the main Flutter engine. The overlay becomes an "orphan" - visible but unresponsive.

**Solution:** Must force-stop app to dismiss orphaned overlay:
```bash
~/Library/Android/sdk/platform-tools/adb shell am force-stop com.selah.selah
```

### 5. EventChannel Errors on Stream Restart

**Problem:** `Receiver not registered: null` errors when canceling/restarting stream.

**Cause:** The `flutter_accessibility_service` package tries to unregister a receiver that wasn't registered.

**Impact:** Error is logged but doesn't break functionality.

---

## Architecture Overview

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
│                     │◄──SharedPrefs──►│                     │
│  - UI screens       │                 │  - Scripture display│
│  - Database access  │                 │  - Buttons          │
│  - Event handling   │                 │  - Self-contained   │
└─────────────────────┘                 └─────────────────────┘
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry + `@pragma("vm:entry-point") accessibilityOverlay()` |
| `lib/app.dart` | Main navigation, accessibility handler init, lifecycle observer |
| `lib/overlay/overlay_main.dart` | Standalone overlay widget (separate engine) |
| `lib/overlay/overlay_data_reader.dart` | Minimal SharedPreferences reader for overlay |
| `lib/services/accessibility_handler.dart` | Event handling, guarded app detection |
| `lib/services/overlay_data_service.dart` | SharedPreferences bridge for data passing |
| `lib/database/database_helper.dart` | SQLite database operations |
| `lib/content/*.json` | Lenten content (Scripture, prayers, reflections) |
| `android/.../AndroidManifest.xml` | AccessibilityService declaration |
| `android/.../xml/accessibilityservice.xml` | Service configuration |

---

## Recommendation: Native Android

For production, recommend native Kotlin/Java for Android because:

1. **Direct AccessibilityService access** - No bridge, no dead subscriptions
2. **Single process** - No separate engine issues
3. **Immediate service start** - Permission granted = service running = events received
4. **Standard overlay pattern** - WindowManager is well-documented
5. **This is how ScreenZen, OneSec, etc. likely work**

### For iOS

iOS requires a completely different approach regardless:
- No AccessibilityService equivalent
- Options: Screen Time API, VPN profiles, MDM
- Would be a separate implementation anyway

### What to Preserve

- **Content JSON files** - Scripture, prayers, reflections (can be used by native app)
- **Database schema** - Well-designed, can recreate in native
- **UI/UX design** - Colors, typography, flow (reference for native UI)
- **Product spec** - Core requirements unchanged

---

## Package Dependencies

```yaml
flutter_accessibility_service: ^1.0.0  # AccessibilityService bridge
shared_preferences: any                 # Data passing to overlay
sqflite: any                           # Local SQLite database
path: any                              # Database path handling
flutter_local_notifications: ^19.0.0   # Future: notifications
```

---

## Testing Notes

### Emulator Setup
- Used Pixel 7 emulator via Android Studio
- Required: `flutter emulators --launch Pixel_7`

### Test Flow
1. `flutter run`
2. Enable accessibility: Settings → Accessibility → Selah → ON
3. Return to Selah app (or wait for periodic check)
4. Open guarded app (TikTok/Instagram/YouTube)
5. Overlay should appear

### Debug Commands
```bash
# Force stop app (dismiss orphaned overlay)
~/Library/Android/sdk/platform-tools/adb shell am force-stop com.selah.selah

# Check connected devices
flutter devices

# Run with verbose logging
flutter run -v
```

---

## Files to Review for Native Implementation

1. `SELAH_PRODUCT_SPEC.md` - Full product requirements
2. `lib/content/*.json` - All Lenten content ready to use
3. `lib/database/database_helper.dart` - Database schema reference
4. `lib/models/*.dart` - Data models
5. `lib/theme/colors.dart` - Brand colors
6. `lib/theme/typography.dart` - Typography specs

---

*This branch preserved for reference. Continue development with native Android.*
