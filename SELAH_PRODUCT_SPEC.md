# SELAH — Sacred Screen Guard
## Product Specification v3.0 | February 2026

> *"Above all else, guard your heart, for everything you do flows from it." — Proverbs 4:23*

**Tagline:** Don't Pause. Pray.  
**One-line pitch:** Turn every temptation into a prayer.  
**Platform:** Native Android (Kotlin + Jetpack Compose). iOS separate, later.  
**Launch target:** Ash Wednesday, February 18, 2026  
**App store title:** Selah — Sacred Screen Guard

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [User Journey & Onboarding](#2-user-journey--onboarding)
3. [The Intervention (Core Experience)](#3-the-intervention-core-experience)
4. [Home Screen & Tabs](#4-home-screen--tabs)
5. [Settings, Armor Lock & Snooze](#5-settings-armor-lock--snooze)
6. [Notifications](#6-notifications)
7. [Monetization (Free vs Premium)](#7-monetization-free-vs-premium)
8. [Content Specification](#8-content-specification)
9. [Data Model](#9-data-model)
10. [Technical Architecture](#10-technical-architecture)
11. [Design Specification](#11-design-specification)
12. [Deployment & Distribution](#12-deployment--distribution)
13. [Build Timeline](#13-build-timeline)
14. [Implementation Notes for Claude Code](#14-implementation-notes-for-claude-code)
15. [v2 Roadmap](#15-v2-roadmap)

---

## 1. Product Overview

### What Is Selah?

Selah is a sacred screen guard for Christians. It intercepts the moment a user reaches for a distracting app and replaces the impulse with Scripture, prayer, and spiritual reflection. Named after the mysterious pause mark in the Psalms — an instruction to stop, reflect, and listen — Selah transforms screen time management from a willpower problem into a spiritual practice.

**Selah is a year-round product.** It works every day, not just during Lent. The liturgical calendar enriches the experience — during Lent you get a special 40-day journey with curated content, during Advent a different themed journey — but the core product is always active. You open Instagram on a random Tuesday in October and Scripture meets you there.

### Core Insight

Existing screen time apps (ScreenZen, one sec) use secular interventions: breathing exercises, countdown timers, generic prompts. These work through friction alone. Selah works through **meaning**. The intervention is not a delay — it is an encounter with the living Word. Every resisted scroll becomes an act of prayer. Every moment of self-denial becomes an offering.

### Target Audience

- Christians of all traditions who struggle with compulsive phone use
- Catholics seeking digital fasting tools aligned with the liturgical year
- Protestants, evangelicals, and Reformed Christians seeking Scripture-grounded screen discipline
- Orthodox Christians seeking tools aligned with ascetic and Desert Fathers traditions
- People exploring Christianity who want a gentle, non-preachy spiritual on-ramp
- Parish small groups, Bible studies, and accountability groups
- Spanish-speaking Christians globally

### Competitive Landscape

| App | What It Does | Gap | Selah Advantage |
|-----|-------------|-----|-----------------|
| **ScreenZen** | App pause + breathing + streaks. Free, cross-platform. | Entirely secular. Generic prompts. | Intervention is Scripture, not a timer. |
| **one sec** | Breathing exercise before app opens. 1 app free, pro for more. | Secular. No spiritual framework. | Prayer replaces the breath. Meaning replaces friction. |
| **Hallow** | Catholic prayer/meditation content platform. $105M raised. | Users go TO Hallow intentionally. Not a screen guard. | Selah meets users at the moment of temptation. Complementary. |
| **Exodus 90** | Catholic men's asceticism program with tech fasting. | Men-only. Intense. Manual tech fasting. | Universal. Automated. Gentle, not punitive. |

### Key Differentiators

1. **Scripture as the intervention** — not a breathing exercise
2. **"Offer it up" / "Dedicate this moment"** — each resistance becomes intercessory prayer
3. **Examination of conscience on proceed** — builds self-awareness
4. **Liturgical season content** — special journeys for Lent, Advent, etc. layered on year-round Scripture
5. **Tradition-aware** — Catholic, Protestant, Orthodox, Exploring variants
6. **Saints/biblical companions** — weekly spiritual guides
7. **Prayer-to-unlock settings lock** — even bypassing becomes spiritual practice
8. **Snooze mode** — pause for 30 min when you need an app for work
9. **Home screen widget** — daily verse visible without opening the app
10. **Shareable weekly report** — accountability without social features

---

## 2. User Journey & Onboarding

### Onboarding Flow (8 screens)

**Screen 1: Welcome**
- Dark navy background (#1B2340)
- Gold cross fades in
- *"Be still, and know that I am God." — Psalm 46:10*
- Beat of silence, then: "Welcome to Selah."
- Below: "A sacred pause between you and distraction."
- Button: "Begin"

**Screen 2: The Promise**
- "Selah places Scripture between you and the apps that steal your peace. When you reach for distraction, you'll find a prayer instead."
- Button: "Set up my guard"

**Screen 3: Tradition Selection**
- "How would you like Selah to speak to you?"
- **Catholic** — Saints, Marian prayers, examination of conscience, feast days
- **Protestant** — Scripture-focused, biblical companions, heart-check language
- **Orthodox** — Desert Fathers, the Jesus Prayer, Great Lent calendar
- **Exploring / Other** — Universal, gentle, Scripture-only
- Changeable anytime in Settings.

**Screen 4: App Selection**
- Grid of installed apps with icons. Common culprits surfaced at top.
- Gold checkmarks on selection. Counter: "Guarding 3 apps."
- **Free tier: up to 3 guarded apps.** Gentle prompt for 4th.
- Note: "You can always change this. Selah never locks you out — it only asks you to pause."

**Screen 5: Schedule**
- "When should Selah guard your heart?"
- **Always** (default), **Evening Peace** (6pm–7am), **Sabbath Rest** (Sundays), **Custom** (premium)

**Screen 6: How It Works**
- Explains escalating friction in spiritual language
- "Each time you return to a guarded app, Selah asks you to sit a little longer with Scripture — 5 seconds, then 10, then 20."
- **Include:** "Keep Selah running in the background for it to work. If you close it or your phone's battery saver stops it, Selah will let you know."

**Screen 7: Permission Grant**
- "To guard your heart, Selah needs accessibility permission."
- "Selah detects when you open guarded apps so it can show you Scripture. It never reads your screen content and never sends anything off your device. Your prayer life stays between you and God."
- Button: "Grant permission" → AccessibilityService settings

**Screen 8: Preview + Ready**
- Shows mock intervention screen
- "This is what you'll see when you reach for a guarded app."
- Button: "I'm ready."

---

## 3. The Intervention (Core Experience)

### Trigger
User taps a guarded app → AccessibilityService detects it → full-screen overlay appears.

### Intervention Structure by Attempt

Per-app, per-day. Resets at midnight.

| Attempt | Pause | What Appears | Sub-Prompt |
|---------|-------|-------------|------------|
| **1st** | 5 sec | Gold cross + breath prayer ("Be still." / "Lord, have mercy." / "Selah.") | None. Just the cross and the word. |
| **2nd** | 10 sec | Cross + today's Scripture verse fading in | "What are you looking for right now?" |
| **3rd** | 20 sec | Cross + Scripture + escalating reflection | "You've come back three times. What is your heart telling you?" |
| **4th** | 30 sec | Cross + Scripture + reflection + saint/companion quote | "He sees you here. He loves you here. Do you want to stay?" |
| **5th+** | 30 sec | Full experience | "You've been here five times. That's okay. But what would it feel like to stop?" |

**Key design rules:**
- Same Scripture appears ALL DAY (lectio divina principle — repeated encounters)
- Buttons hidden until pause timer expires, then fade in
- Tone = spiritual director, never shaming
- **Premium:** Custom starting friction, escalation curve, flat duration

### Choice: "Return to Prayer"
1. Gold "✦ Offered up" animation
2. "Dedicate this moment" (Protestant/Orthodox/Exploring) or "Offer it up" (Catholic)
3. Quick picks: For a loved one / For peace / For my own healing / For the world / Custom text
4. Logged to database. User returns to home screen. App never opens.
5. **This feature is FREE.**

### Choice: "Proceed"
1. "What's drawing you here?" — Boredom / Anxiety / Loneliness / Habit / Escape / Envy / I need this app
2. Logged. App opens. No guilt.

### Time Reclaimed
Each resistance = 5 min saved estimate. "You reclaimed 2 hours for prayer and presence this week."

---

## 4. Home Screen & Tabs

### Home Screen (Today Tab)

**Top:** Liturgical context as accent — if it's a liturgical season (Lent, Advent, Easter), show it: "Day 12 of Lent" or "Third Sunday of Advent." If Ordinary Time, show the date beautifully or a simple "Wednesday" or the saint of the day.

**Center:** Today's Scripture passage, beautifully typeset in Cormorant Garamond gold on navy. Tappable to expand showing reflection + companion quote.

**Stats:** "Guarded X times · Chose prayer Y times · Reclaimed Z minutes today"

**Navigation:** Four tabs — Today / Journey / Offerings / Settings

### Journey Tab

**During liturgical seasons (Lent, Advent, Easter):**
- Visual path with waypoints. Lent = desert (40 days). Advent = starlit night (28 days). Easter = green landscape (50 days).
- Completed days glow gold. Today pulses. Future days dimmed.
- Tapping past day shows Scripture, stats, offerings.

**During Ordinary Time:**
- Simpler view — rolling history of your guarded days. Calendar or list.
- Stats over time: streak, total resistances, time reclaimed all-time.

### Offerings Tab

Running journal of dedicated sacrifices.
- "March 3 — Offered 4 moments for Mom's health"
- "March 5 — Offered 7 moments for peace"

### Weekly Review (Sunday Evening)

Notification at 7 PM. Summary: total times guarded, times chose prayer, time reclaimed, hardest apps/times, offerings dedicated, examination patterns.

**Share button:** Generate image or text summary → Android share intent → send to accountability partner, spouse, small group.

---

## 5. Settings, Armor Lock & Snooze

### Settings Screen
- Guarded apps: add/remove (3 free, unlimited premium)
- Schedule: Always / Evening / Sabbath / Custom (premium)
- Tradition: Catholic / Protestant / Orthodox / Exploring
- Language: English (Spanish in v1.1)
- Friction: view/customize escalation (premium)
- Notifications: toggle each type, custom times
- Armor Lock: toggle on/off
- Snooze: quick-access pause
- Privacy: view data, delete all data, privacy policy
- About: version, credits

### Armor Lock ("Lock Your Armor" — Ephesians 6)

Lock duration: 1 day / 3 days / 1 week / "Until Easter" (during Lent)

Settings become read-only. To change:
- "I need to change something important" → Prayer Unlock (tap through prayer text line by line)
- "Never mind" → return

**Prayer Unlock by Tradition:**

| Tradition | Unlock Prayer | Interaction |
|-----------|--------------|-------------|
| Catholic | Three Hail Marys | Tap through each line, 3 times |
| Protestant | The Lord's Prayer, 3 times | Tap through each line, 3 times |
| Orthodox | The Jesus Prayer, 12 times | Tap through each repetition |
| Exploring | The Lord's Prayer, 3 times | Tap through each line, 3 times |

After unlock: settings open for 5 minutes, then auto-relock.

"This isn't a punishment — it's a pause to make sure you really want to change your guard."

### Snooze Mode

Accessible from home screen or notification shade. "Pause Selah for 30 minutes."

When active: all interventions paused. A subtle banner on the home screen: "Selah paused until 2:30 PM." After 30 minutes, Selah resumes automatically.

This exists because people sometimes need a guarded app for work. Without snooze, they'd uninstall.

---

## 6. Notifications

### Default (on at install)
- **Sunday Weekly Review** (7 PM): "Your weekly Selah." Full summary.
- **Service Killed Alert** (when detected): "Selah was closed and can no longer guard your apps. Tap to restart." One-time, not nagging.

### Optional (user enables in Settings)
- **Morning Verse** (8 AM, custom time): Today's Scripture
- **Midday Prayer Reminder** (12 PM): Brief prompt
- **Evening Examen** (9 PM): "How was your day?"
- **Celebration** (contextual): After 5+ resistances: "You've guarded your heart 5 times today."

Each independently toggleable with custom times.

---

## 7. Monetization (Free vs Premium)

**Pricing: $2.99/month | $19.99/year | $49.99 lifetime**

### Free Tier
1. Core intervention (Scripture overlay on app open)
2. Up to 3 guarded apps
3. Default escalation (5s → 10s → 20s → 30s)
4. "Return to prayer" / "Proceed" flow
5. "Offer it up" / "Dedicate this moment" (FREE)
6. Daily Scripture (year-round rolling content)
7. Basic daily stats + time reclaimed
8. Sunday weekly review
9. Snooze mode
10. English

### Selah Plus (Premium)
1. Unlimited guarded apps
2. Custom friction (starting duration, escalation curve, flat mode)
3. Custom scheduling
4. Armor Lock with prayer unlock
5. Saints/companions as weekly spiritual guides
6. Liturgical season journeys (Lent desert path, Advent starlit night, Easter garden)
7. Detailed weekly review with examination patterns
8. Share weekly report
9. Home screen widget
10. All additional notification types
11. Additional languages
12. Journey path visual themes

### Future: Parish Plan
- Bulk pricing, group challenges, admin dashboard

---

## 8. Content Specification

### Year-Round Content System

Selah needs Scripture content for every day of the year, not just Lent. The system works in layers:

**Layer 1: Daily Scripture (year-round, free)**
A rolling library of Scripture passages — one per day. **v1.0 launches with 40-50 days** of curated passages (cycles until expanded). Each day includes: Scripture reference, full text, breath prayer, reflection question.

**Layer 2: Liturgical Season Overlays (premium)**
During Lent, the daily content is replaced by specially curated seasonal content. **v1.0 launches with 40 days of Lent content.** Advent and Easter content in future updates. These include: themed Scripture, season-specific reflections, saints/companions, journey visualizations.

**Layer 3: Tradition Variants**
**v1.0 launches with Universal + Catholic traditions.** Protestant and Orthodox variants fast-follow in v1.1. ~20% of content varies by tradition. Scripture and breath prayers are mostly shared. Saints/companions, specific prayer forms, and some reflection language differ.

### Daily Content Structure

| Element | Source | Notes |
|---------|--------|-------|
| Scripture passage | Published Bible translations (public domain) | Do NOT translate — source per language. |
| Breath prayer | Traditional short prayers | "Be still." / "Lord, have mercy." / "Selah." Rotates. |
| Reflection question | Original (1–2 sentences) | Translate per language. |
| Sub-prompts | Original (~15 phrases) | Escalating in intimacy. Translate per language. |
| Saint/companion quote | Public domain | 4 tradition variants. |
| Liturgical context | Church calendar | Optional, enriches but not required. |

### Content by Tradition

| Element | Catholic | Protestant | Orthodox | Exploring |
|---------|----------|-----------|----------|-----------|
| Saints | Yes — Catholic saints | Biblical figures | Desert Fathers, Orthodox saints | Biblical scenes |
| Default prayer | Hail Mary | Lord's Prayer | Jesus Prayer | Lord's Prayer |
| Dedication label | "Offer it up" | "Dedicate this moment" | "Dedicate this moment" | "Dedicate this moment" |
| Examination label | "Examination of conscience" | "Heart check" | "Examination" | "What's drawing you here?" |

### Translation Strategy
**v1.0: English only.** Scripture from published translations (ESV, USCCB for Catholic). Spanish in v1.1 with native speaker review. JSON locale files.

---

## 9. Data Model

All data local. Room (Android) or raw SQLite. No server, no cloud, no analytics.

### daily_content (replaces lenten_days)
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Day number in cycle (1–90 for base, 1–40 for Lent overlay, etc.) |
| season | TEXT | "year_round" / "lent" / "advent" / "easter" / "ordinary" |
| day_in_season | INTEGER NULL | Position in season (Day 3 of Lent, etc.) |
| liturgical_label | TEXT NULL | e.g., "Thursday of the Third Week of Lent" |
| scripture_ref | TEXT | e.g., "Psalm 51:10" |
| scripture_text | TEXT | Full text, from locale JSON |
| breath_prayer | TEXT | Short prayer for Attempt 1 |
| reflection | TEXT | From locale JSON, per tradition |
| companion_name | TEXT NULL | Per tradition variant |
| companion_quote | TEXT NULL | Per tradition variant |

### guarded_apps
| Column | Type | Description |
|--------|------|-------------|
| package_name | TEXT PK | Android package name |
| app_name | TEXT | Display name |
| is_active | BOOLEAN | Currently guarded |
| added_at | DATETIME | When added |

### interventions
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| timestamp | DATETIME | When intervention fired |
| app_package | TEXT | Package name |
| app_name | TEXT | Display name |
| outcome | TEXT | "resisted" or "proceeded" |
| reason | TEXT NULL | If proceeded: boredom/anxiety/loneliness/habit/escape/envy/needed |
| offering_text | TEXT NULL | If resisted: dedication text |
| scripture_shown | TEXT | Scripture reference shown |
| pause_duration | INTEGER | Seconds of pause |
| attempt_number | INTEGER | Attempt count for this app today |
| time_saved_est | INTEGER | Estimated seconds saved (300 default) |

### user_settings
| Column | Type | Description |
|--------|------|-------------|
| tradition | TEXT | catholic / protestant / orthodox / exploring |
| language | TEXT | "en", "es" |
| schedule_mode | TEXT | always / evening / sabbath / custom |
| custom_start | TEXT NULL | Custom schedule start time |
| custom_end | TEXT NULL | Custom schedule end time |
| custom_days | TEXT NULL | JSON array of days |
| is_premium | BOOLEAN | Premium subscriber |
| armor_locked | BOOLEAN | Settings locked |
| armor_lock_until | TEXT NULL | When lock expires (ISO datetime) |
| friction_start_sec | INTEGER | Starting pause (default 5) |
| snooze_until | TEXT NULL | If snoozed: when snooze expires (ISO datetime) |
| notifications_morning | BOOLEAN | |
| notifications_midday | BOOLEAN | |
| notifications_evening | BOOLEAN | |
| notifications_celebration | BOOLEAN | |
| notifications_weekly | BOOLEAN | Default true |
| onboarding_complete | BOOLEAN | |

---

## 10. Technical Architecture

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Kotlin |
| UI Framework | Jetpack Compose + Material3 (main app) |
| App Interception | AccessibilityService (native Android) |
| Overlay | WindowManager + XML Views (more reliable than Compose for overlays) |
| Database | Room (Android SQLite ORM) |
| Preferences | DataStore or SharedPreferences |
| Notifications | Android NotificationManager + AlarmManager/WorkManager |
| Fonts | Cormorant Garamond (res/font/), system sans |
| In-App Purchase | Google Play Billing Library |
| Widget | RemoteViews + AppWidgetProvider (not Glance) |

### Why Native Kotlin (not Flutter)

The core product feature — intercepting app launches and showing an overlay — is an Android system-level interaction. Flutter required a separate engine for the overlay, resulting in: no shared state, broken animations, fragile SharedPreferences bridge, no hot reload. In native Kotlin, the AccessibilityService and overlay share the same process. Direct database access, full animation support, no hacks. Since iOS needs a completely different approach anyway (Screen Time API / Shortcuts), Flutter's cross-platform benefit doesn't apply.

### AccessibilityService Architecture

The service runs in the app's process. When it detects a guarded app launch, it creates a full-screen overlay View using WindowManager with TYPE_APPLICATION_OVERLAY. The overlay has direct access to the Room database, SharedPreferences, and all app state. No bridge needed.

**Critical: In-memory cache for performance.** The service maintains an in-memory Set of guarded app package names, loaded from Room on service start and updated when apps are added/removed. This avoids database queries on every accessibility event.

```
Service starts → Load guarded apps from Room into memory cache

User taps app → AccessibilityService.onAccessibilityEvent()
  → Check package against in-memory guardedApps Set (fast!)
  → If no match: return immediately (most events)
  → If match:
    → Check if snoozed (SharedPreferences)
    → Check schedule (compare current time to user schedule)
    → Count today's attempts (Room query - only when showing overlay)
    → Determine escalation level
    → WindowManager.addView(interventionOverlayView)
    → User interacts with overlay
    → Write intervention to Room database
    → WindowManager.removeView() → user returns home or app opens
```

### Project Structure (Kotlin)

```
app/src/main/
├── java/com/selah/app/
│   ├── SelahApplication.kt              # Application class
│   ├── MainActivity.kt                  # Main activity with Compose
│   │
│   ├── data/
│   │   ├── database/
│   │   │   ├── SelahDatabase.kt         # Room database
│   │   │   ├── DailyContentDao.kt
│   │   │   ├── GuardedAppDao.kt
│   │   │   ├── InterventionDao.kt
│   │   │   └── UserSettingsDao.kt
│   │   ├── model/
│   │   │   ├── DailyContent.kt          # @Entity
│   │   │   ├── GuardedApp.kt            # @Entity
│   │   │   ├── Intervention.kt          # @Entity
│   │   │   └── UserSettings.kt          # @Entity
│   │   └── repository/
│   │       ├── ContentRepository.kt
│   │       ├── InterventionRepository.kt
│   │       └── SettingsRepository.kt
│   │
│   ├── service/
│   │   ├── SelahAccessibilityService.kt # THE core service
│   │   └── SelahOverlayManager.kt       # Creates/manages overlay views
│   │
│   ├── ui/
│   │   ├── theme/
│   │   │   ├── Color.kt
│   │   │   ├── Type.kt
│   │   │   ├── Theme.kt
│   │   │   └── Spacing.kt
│   │   ├── overlay/
│   │   │   ├── InterventionOverlayView.kt  # XML View-based overlay (not Compose)
│   │   │   ├── OfferingPromptView.kt
│   │   │   └── ExaminationPromptView.kt
│   │   ├── onboarding/
│   │   │   ├── WelcomeScreen.kt
│   │   │   ├── PromiseScreen.kt
│   │   │   ├── TraditionScreen.kt
│   │   │   ├── AppSelectionScreen.kt
│   │   │   ├── ScheduleScreen.kt
│   │   │   ├── HowItWorksScreen.kt
│   │   │   ├── PermissionScreen.kt
│   │   │   └── ReadyScreen.kt
│   │   ├── home/
│   │   │   └── HomeScreen.kt
│   │   ├── journey/
│   │   │   └── JourneyScreen.kt
│   │   ├── offerings/
│   │   │   └── OfferingsScreen.kt
│   │   ├── settings/
│   │   │   ├── SettingsScreen.kt
│   │   │   ├── ArmorLockScreen.kt
│   │   │   ├── PrayerUnlockScreen.kt
│   │   │   └── GuardedAppsScreen.kt
│   │   ├── review/
│   │   │   └── WeeklyReviewScreen.kt
│   │   └── navigation/
│   │       └── SelahNavigation.kt
│   │
│   ├── widget/
│   │   └── SelahWidget.kt               # Home screen widget
│   │
│   └── util/
│       ├── LiturgicalCalendar.kt
│       ├── ContentLoader.kt             # Load JSON content
│       └── ShareHelper.kt              # Generate & share weekly report
│
├── res/
│   ├── font/
│   │   └── cormorant_garamond*.ttf
│   ├── xml/
│   │   └── accessibilityservice.xml
│   ├── raw/
│   │   ├── content_year_round_en.json    # 40-50 days for v1.0
│   │   ├── content_lent_universal_en.json # 40 days
│   │   ├── content_lent_catholic_en.json  # 40 days (Catholic saints/prayers)
│   │   ├── breath_prayers.json
│   │   └── sub_prompts.json
│   └── values/
│       └── strings.xml                    # English only for v1.0
│
└── AndroidManifest.xml
```

### Android Manifest Requirements

```xml
<!-- AccessibilityService -->
<service
    android:name=".service.SelahAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="false">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibilityservice" />
</service>

<!-- Overlay permission -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- Usage stats (for future usage limits feature) -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions" />
```

### AccessibilityService Config (res/xml/accessibilityservice.xml)

```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:notificationTimeout="100"
    android:accessibilityFlags="flagDefault"
    android:canRetrieveWindowContent="false"
    android:description="@string/accessibility_service_description" />
```

**v1.0 Safety:** `canRetrieveWindowContent="false"` and only `typeWindowStateChanged` events. This is safer for Play Store approval and has zero battery impact. Website blocking (requiring content reading) deferred to v2.

---

## 11. Design Specification

### Philosophy
Beautiful, elegant, modern, sleek, clean. **Church, not spa.** Clean lines, intentional negative space, reverence through simplicity. Walking into a quiet chapel.

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Deep Navy | `#1B2340` | Primary background, intervention screen |
| Sacred Gold | `#C9A84C` | Scripture text, crosses, primary buttons |
| Warm Cream | `#F5F0E8` | Card backgrounds, secondary surfaces |
| Charcoal | `#2D2D2D` | Body text on light backgrounds |
| Subdued Gray | `#666666` | "Proceed" button, metadata |

### Typography
- **Scripture / reflections:** Cormorant Garamond. Warm, literary, sacred.
- **UI:** System sans or Inter. Clean, modern.
- Serif = tradition. Sans = modern. Together = **ancient wisdom, contemporary delivery.**

### Intervention Screen Layout

```
┌──────────────────────────────┐
│         ✦ (gold cross)       │  ← Top 15%
│                              │
│    "Create in me a clean     │
│     heart, O God, and        │  ← Middle 50%: Scripture
│     renew a right spirit     │     Cormorant Garamond, gold
│     within me."              │     Fades in 1.5s
│       — Psalm 51:10          │
│                              │
│   "What are you looking      │  ← Sub-prompt (Attempt 2+)
│    for right now?"           │
│                              │
│   ┌─────────────────────┐    │
│   │  Return to prayer   │    │  ← Gold, large (after pause)
│   └─────────────────────┘    │
│    Proceed to Instagram      │  ← Gray, small
│  Attempt 3 today · 20 sec   │  ← Bottom edge
└──────────────────────────────┘
```

### Visual Principles
- Subtle, reverent animations. No bouncing, no confetti.
- Generous negative space. Let the Word breathe.
- Journey illustrations: minimal, evocative.

---

## 12. Deployment & Distribution

### Google Play Store
- Category: Lifestyle
- AccessibilityService declaration + clear explanation
- Privacy policy: all data on-device only, no screen content reading, no network calls
- Content rating: Everyone

### Store Listing
**Title:** Selah — Sacred Screen Guard  
**Short:** Don't pause. Pray. Turn every temptation into a prayer.  
**Long:** When you reach for distraction, Selah meets you with Scripture. Instead of a timer or a breathing exercise, you encounter the living Word of God — and choose whether to return to prayer or proceed. Tailored for Catholic, Protestant, Orthodox, and exploring Christians.

### Distribution
- Christian subreddits, parish groups, Christian Twitter/X
- Product Hunt, priests/campus ministers
- Lent launch timing for organic momentum

---

## 13. Build Timeline

Ash Wednesday is February 18, 2026. Submit by Feb 16 for review.

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1 | Kotlin project, Compose theme, navigation, Room database + models | App runs with themed 4-tab nav, database ready |
| 2 | AccessibilityService + XML overlay (native) | Overlay appears when opening guarded app |
| 3 | Full intervention behavior + offering/examination prompts | Escalation, both choice paths, data logging |
| 4 | Onboarding (8 screens) | Complete first-run experience |
| 5 | Home screen, Journey tab, Offerings tab | All main screens with real data |
| 6 | Settings, Armor Lock, Snooze | Full settings functionality |
| 7 | Notifications, widget, share report, content loading | All features complete |
| 8 | Polish, testing, Google Play submission | Submitted |

---

## 14. Implementation Notes for Claude Code

### Critical Rules

1. **The intervention overlay is the entire product.** Prioritize above all.
2. **Native Kotlin — NO Flutter.** AccessibilityService and overlay share the same process. Direct Room access from overlay. No bridge.
3. **Overlay = WindowManager + XML Views.** TYPE_APPLICATION_OVERLAY. More reliable than Compose for overlay windows.
4. **Main app = Jetpack Compose.** Modern UI for all screens except overlay.
5. **In-memory cache of guarded apps.** Load from Room on service start, avoid database queries on every event.
6. **Buttons hidden during pause.** Timer counts down, THEN buttons fade in.
7. **Same Scripture all day.** Lectio divina principle.
8. **Escalation is per-app, per-day.** Resets at midnight.
9. **"Proceed" must always be available.** Never lock users out.
10. **Content loaded from JSON in res/raw/.** Loaded into Room on first run.
11. **canRetrieveWindowContent="false"** — safer for Play Store, no battery drain.
12. **Only typeWindowStateChanged events** — minimal, efficient.
13. **All data local.** No network calls, no analytics, no server.
14. **Snooze check:** Before showing overlay, check if `snooze_until` is in the future. If so, skip.
15. **Service-killed detection:** Use onDestroy() or a periodic WorkManager check to detect if service was killed and notify user.

### Build Order (dependency-aware)

1. **Project scaffold + theme + Compose navigation** — foundation
2. **Room database + entities + DAOs** — data layer
3. **AccessibilityService + WindowManager XML overlay** — core technical piece
4. **Intervention behavior** — escalation, timers, animations, both choice flows
5. **Onboarding flow** — writes to database
6. **Home screen + stats** — reads from database
7. **Journey + Offerings** — secondary screens
8. **Settings + Armor Lock + Snooze** — settings management
9. **Notifications + service-killed alert**
10. **Home screen widget (RemoteViews)**
11. **Share weekly report**
12. **Content creation** — 40-50 year-round + 40 Lent days (universal + Catholic)
13. **In-app purchase**
14. **Polish + submission**

### Gotchas

- Android 12+ requires TYPE_APPLICATION_OVERLAY for overlays
- Samsung/Xiaomi battery optimization kills services — detect and notify
- Google Play reviews AccessibilityService apps carefully — clear description required
- Use XML Views for overlay (not Compose) — more reliable lifecycle, theming, and animations
- In-memory cache is critical — don't query Room on every accessibility event
- Room queries for attempt counting must be off main thread — use coroutines with Dispatchers.IO
- RemoteViews for widget — Glance (Compose for widgets) is still maturing

---

## 15. v2 Roadmap

Features deferred from v1.0 for future releases:

### v1.1
- Spanish language support
- Protestant and Orthodox tradition variants
- Additional year-round content (expand to 90+ days)

### v2.0
- **Website blocking** — VPN-based approach (more reliable than URL bar reading)
  - Local VPN intercepts DNS requests
  - No external server, all on-device
  - Works across all browsers and in-app browsers
  - Cleaner UX than AccessibilityService content reading
- Advent content (28 days)
- Easter content (50 days)

### Future
- iOS app (Screen Time API / Shortcuts approach)
- Parish Plan (bulk pricing, group challenges)
- Detailed analytics and patterns
