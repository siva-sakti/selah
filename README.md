# Selah

**A moment of reflection before distraction.**

Selah is a Christian app-blocking intervention tool that helps users pause and reflect before opening distracting apps. When you try to open a guarded app (like Instagram, TikTok, or YouTube), Selah displays Scripture and a moment of prayer, giving you space to choose intentionally.

## Project Structure

```
selah/
├── android/              # Native Android app (Kotlin)
├── shared/
│   └── content/          # Lenten content (JSON) - reusable across platforms
├── SELAH_PRODUCT_SPEC.md # Full product requirements
└── FLUTTER_IMPLEMENTATION_NOTES.md  # Lessons from Flutter POC
```

## Branches

- `main` - Native Android development
- `flutter-attempt` - Archived Flutter proof-of-concept (functional but complex)

## Getting Started (Android)

1. Open `android/` folder in Android Studio
2. Sync Gradle
3. Run on device/emulator
4. Enable accessibility service: Settings > Accessibility > Selah

## Key Features

- **AccessibilityService** detects guarded app launches
- **Full-screen overlay** with Scripture and reflection prompt
- **40-day Lenten content** (4 traditions, 2 languages)
- **Escalating interventions** for repeat attempts

## Why Native Android?

See `FLUTTER_IMPLEMENTATION_NOTES.md` for details. TL;DR: The Flutter-to-native bridge for AccessibilityService introduced complexity (dead streams, separate Flutter engines, SharedPreferences workarounds) that native Android avoids entirely.

## Content

All Lenten content is in `shared/content/`:
- `lent_*_en.json` / `lent_*_es.json` - Daily Scripture and reflections
- `breath_prayers.json` - Short breath prayers
- `saints.json` - Saint companions
- `sub_prompts.json` - Escalation prompts
