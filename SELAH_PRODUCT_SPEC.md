# SELAH — Sacred Screen Guard
## Product Specification v2.0 | February 2026

> *"Above all else, guard your heart, for everything you do flows from it." — Proverbs 4:23*

**Tagline:** Don't Pause. Pray.  
**One-line pitch:** Turn every temptation into a prayer.  
**Platform:** Android-first, Flutter, single codebase (iOS via Shortcuts automation later)  
**Launch target:** Ash Wednesday, February 18, 2026  
**App store title:** Selah — Sacred Screen Guard

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [User Journey & Onboarding](#2-user-journey--onboarding)
3. [The Intervention (Core Experience)](#3-the-intervention-core-experience)
4. [Home Screen & Tabs](#4-home-screen--tabs)
5. [Settings & Armor Lock](#5-settings--armor-lock)
6. [Notifications](#6-notifications)
7. [Monetization (Free vs Premium)](#7-monetization-free-vs-premium)
8. [Content Specification](#8-content-specification)
9. [Data Model](#9-data-model)
10. [Technical Architecture](#10-technical-architecture)
11. [Design Specification](#11-design-specification)
12. [Deployment & Distribution](#12-deployment--distribution)
13. [Build Timeline](#13-build-timeline)
14. [Implementation Notes for Claude Code](#14-implementation-notes-for-claude-code)

---

## 1. Product Overview

### What Is Selah?

Selah is a sacred screen guard for Christians. It intercepts the moment a user reaches for a distracting app and replaces the impulse with Scripture, prayer, and spiritual reflection. Named after the mysterious pause mark in the Psalms — an instruction to stop, reflect, and listen — Selah transforms screen time management from a willpower problem into a spiritual practice.

### Core Insight

Existing screen time apps (ScreenZen, one sec) use secular interventions: breathing exercises, countdown timers, generic prompts. These work through friction alone. Selah works through **meaning**. The intervention is not a delay — it is an encounter with the living Word. Every resisted scroll becomes an act of prayer. Every moment of self-denial becomes an offering. This is not productivity. This is fasting.

### Target Audience

- Christians of all traditions who struggle with compulsive phone use
- Catholics seeking digital fasting tools for Lent and the liturgical year
- Protestants, evangelicals, and Reformed Christians seeking Scripture-grounded screen discipline
- Orthodox Christians seeking tools aligned with ascetic and Desert Fathers traditions
- People exploring Christianity who want a gentle, non-preachy spiritual on-ramp
- Parish small groups, Bible studies, and accountability groups
- Spanish-speaking Christians globally (largest underserved demographic)

### Competitive Landscape

| App | What It Does | Gap | Selah Advantage |
|-----|-------------|-----|-----------------|
| **ScreenZen** | App pause + breathing + streaks. Free, cross-platform. | Entirely secular. Generic prompts. | Intervention is Scripture, not a timer. |
| **one sec** | Breathing exercise before app opens. 1 app free, pro for more. ~€15/yr. | Secular. No spiritual framework. | Prayer replaces the breath. Meaning replaces friction. |
| **Hallow** | Catholic prayer/meditation content platform. $105M raised, 20M+ downloads. | Users go TO Hallow intentionally. Not a screen guard. | Selah meets users at the moment of temptation. Complementary, not competing. |
| **Exodus 90** | Catholic men's asceticism program with tech fasting. | Men-only. Intense. Manual tech fasting. | Universal. Automated. Gentle, not punitive. |

### Key Differentiators (features NO screen time app has)

1. **Scripture as the intervention itself** — not a breathing exercise, not "Is this important?"
2. **"Offer it up" / "Dedicate this moment"** — each resistance becomes intercessory prayer
3. **Examination of conscience on proceed** — "What's drawing you here?" builds self-awareness
4. **Liturgical calendar integration** — content changes with Lent, Easter, Ordinary Time, Advent
5. **Tradition-aware content** — Catholic, Protestant, Orthodox, and Exploring variants
6. **Saints/biblical companions** — weekly spiritual guides for the journey
7. **Prayer-to-unlock settings lock** — even bypassing becomes a spiritual practice
8. **Time reclaimed as spiritual metric** — "You reclaimed 2 hours for prayer and presence"

---

## 2. User Journey & Onboarding

### Onboarding Flow (8 screens)

**Screen 1: Welcome**
- Dark navy background (#1B2340)
- Gold cross fades in
- Text: *"Be still, and know that I am God." — Psalm 46:10*
- Beat of silence, then: "Welcome to Selah."
- Below: "A sacred pause between you and distraction."
- Button: "Begin"

**Screen 2: The Promise**
- "Selah places Scripture between you and the apps that steal your peace. When you reach for distraction, you'll find a prayer instead."
- Visual: phone screen transforming from social media noise into a cross of light
- Button: "Set up my guard"

**Screen 3: Tradition Selection**
- "How would you like Selah to speak to you?"
- **Catholic** — Saints, Marian prayers, examination of conscience, liturgical calendar with feast days
- **Protestant** — Scripture-focused, biblical companions, heart-check language
- **Orthodox** — Desert Fathers, the Jesus Prayer, icons, Great Lent calendar
- **Exploring / Other** — Universal, gentle, Scripture-only, no tradition-specific content
- This determines which content variant loads. Changeable anytime in Settings.

**Screen 4: App Selection**
- Grid of installed apps with icons
- Common culprits surfaced at top: Instagram, TikTok, YouTube, Twitter/X, Reddit, Facebook
- Gold checkmarks on selection
- Counter: "Guarding 3 apps"
- **Free tier: up to 3 guarded apps.** If user tries to select a 4th: "Guard more apps with Selah Plus."
- Reassuring note: "You can always change this. Selah never locks you out — it only asks you to pause."

**Screen 5: Schedule**
- "When should Selah guard your heart?"
- **Always** — Every time you open a guarded app (default)
- **Evening Peace** — 6 PM to 7 AM
- **Sabbath Rest** — Sundays, all day
- **Custom** — Pick your own days and hours (Premium)

**Screen 6: How Selah Works (Teaching Screen)**
- Explains escalating friction in simple, spiritual language:
- "Each time you return to a guarded app, Selah asks you to sit a little longer with Scripture — 5 seconds, then 10, then 20. Like the Desert Fathers who sat in patience, the practice deepens with repetition. The more you return, the more the Word has time to work."

**Screen 7: Permission Grant**
- "To guard your heart, Selah needs accessibility permission. This lets Selah notice when you open a guarded app and show you a moment of prayer instead."
- Smaller: "Selah never reads your screen content, never collects your data, and never sends anything off your device. Your prayer life stays between you and God."
- Button: "Grant permission" → Android AccessibilityService settings toggle

**Screen 8: Preview + Ready**
- Shows mock intervention screen
- "This is what you'll see when you reach for a guarded app. Read. Pray. Then choose."
- Button: "I'm ready."

---

## 3. The Intervention (Core Experience)

This is the heart of Selah. Everything else exists to serve this moment.

### Trigger
User taps a guarded app → AccessibilityService detects TYPE_WINDOW_STATE_CHANGED → checks package name against guarded_apps → checks schedule → shows full-screen overlay.

### Intervention Structure by Attempt

The experience deepens with each return to the same app in a single day:

| Attempt | Pause | What Appears | Sub-Prompt |
|---------|-------|-------------|------------|
| **1st** | 5 sec | Gold cross + breath prayer ("Be still." / "Lord, have mercy." / "Selah.") | None. Just the cross and the word. Light tap on the shoulder. |
| **2nd** | 10 sec | Cross + today's full Scripture verse fading in | "What are you looking for right now?" |
| **3rd** | 20 sec | Cross + Scripture + escalating reflection | "You've come back three times today. What is your heart telling you?" |
| **4th** | 30 sec | Cross + Scripture + reflection + saint/companion quote | "He sees you here. He loves you here. Do you want to stay?" |
| **5th+** | 30 sec | Full experience | "You've been here five times. That's okay. But what would it feel like to stop?" |

**Critical design notes:**
- The same Scripture passage appears ALL DAY. Repeated encounters = lectio divina (reading the same passage until it penetrates). The sub-prompts change, adding intimacy without judgment.
- Buttons are NOT visible during the pause. User must sit with the content before choosing.
- The tone of sub-prompts is a spiritual director, not a nagging parent. Direct but never shaming.
- **Premium feature:** Custom starting friction (10s, 15s, 30s, 60s), custom escalation curve, or flat duration. Free users get default 5→10→20→30.

### Choice: "Return to Prayer"

1. Overlay shows gentle gold "✦ Offered up" animation
2. "Dedicate this moment" (Protestant/Orthodox/Exploring) or "Offer it up" (Catholic)
3. Quick-pick options: For a loved one / For peace / For my own healing / For the world / Custom text
4. Dedication logged to Offerings journal
5. User returns to home screen. Guarded app never opens.
6. **This feature is FREE — it is the spiritual heart of the app.**

### Choice: "Proceed"

1. Examination screen: "What's drawing you here?"
2. Options: Boredom (acedia) / Anxiety / Loneliness / Habit / Escape / Envy (comparing myself to others) / I need this app for something specific
3. User picks one. No guilt, no lecture. App lets them through.
4. Data logged — surfaces in weekly review.

### Time Reclaimed Estimate

Each resisted app-open = estimated 5 minutes saved (industry standard average session length). Cumulative time tracked and displayed. Spiritual reframe: not "you saved 2 hours of productivity" but **"You reclaimed 2 hours for prayer and presence this week."**

---

## 4. Home Screen & Tabs

### Home Screen (Today Tab)

**Top:** Liturgical context — "Wednesday of the First Week of Lent" or "Day 3 of 40"

**Center:** Today's Scripture passage, beautifully typeset. Tapping expands to show reflection and saint/companion quote.

**Stats bar:** Understated, no judgment — "Guarded 7 times · Chose prayer 5 times · Reclaimed 25 minutes today."

**Navigation:** Four tabs — Today / Journey / Offerings / Settings

### Journey Tab

Visual progress through the liturgical season.
- **Lent:** Path through a desert landscape, minimal and illustrated. 40 waypoints. Completed days glow gold. Today pulses. Future days dimmed.
- **Easter:** 50 days, lush green landscape
- **Ordinary Time:** Rolling fields
- **Advent:** Starlit night, approaching light

Tapping a past day shows: Scripture, times guarded, times chose prayer, time reclaimed, offerings dedicated.

### Offerings Tab

Running journal of dedicated sacrifices:
- "March 3 — Offered 4 moments for Mom's health"
- "March 5 — Offered 7 moments for peace"

Reframes every resisted scroll as intercessory prayer.

### Weekly Review (Sunday Evening)

Notification at 7 PM: "Your weekly Selah."

Summary: total times guarded, times chose prayer, time reclaimed, which apps/times were hardest, offerings, examination patterns ("You opened Instagram out of loneliness 8 times this week — what might God be saying to you in that loneliness?").

Closes with: next week's liturgical preview + saint/companion for the week.

---

## 5. Settings & Armor Lock

### Settings Screen
- Guarded apps: add/remove (3 free, unlimited premium)
- Schedule: Always / Evening / Sabbath / Custom (custom is premium)
- Tradition: Catholic / Protestant / Orthodox / Exploring
- Language: English, Spanish (launch); more added during Lent
- Friction: view current escalation; customize with premium
- Notifications: toggle each independently, set custom times
- Armor Lock: toggle on/off
- Privacy: view data, delete all data, privacy policy
- About: version, credits

### Armor Lock ("Lock Your Armor" — Ephesians 6)

When toggled on, user chooses lock duration: **1 day / 3 days / 1 week / "Until Easter"**

Settings become read-only — user can VIEW configuration but cannot change it.

**Attempting to change locked settings:**

Screen: "Your armor is locked. Why are you here?"

**Option A: "I need to change something important"**
→ Prayer Unlock screen. User must pray through the full text of the unlock prayer, tapping through each line (forces actual engagement, not just a button press). After completing, settings unlock for 5 minutes, then re-lock automatically.

Subtle line: "This isn't a punishment — it's a pause to make sure you really want to change your guard."

**Option B: "Never mind"**
→ Returns to app. Settings remain locked.

**Prayer Unlock by Tradition:**

| Tradition | Default Unlock Prayer | Interaction |
|-----------|----------------------|-------------|
| Catholic | Three Hail Marys | Tap through each line, 3 times |
| Protestant | The Lord's Prayer, 3 times | Tap through each line, 3 times |
| Orthodox | The Jesus Prayer, 12 times | Tap through each repetition |
| Exploring | The Lord's Prayer, 3 times | Tap through each line, 3 times |

**The brilliance:** even if someone unlocks and weakens their settings, they just prayed. They still won.

---

## 6. Notifications

### Default (on at install)
- **Sunday Weekly Review** (7 PM): "Your weekly Selah." Full summary.

### Optional (user enables in Settings)
- **Morning Verse** (8 AM default, custom time): Today's Scripture, one line.
- **Midday Angelus / Prayer Reminder** (12 PM): Brief prayer prompt.
- **Evening Examen** (9 PM): "How was your day? See your Selah."
- **Celebration** (contextual, not timed): Triggered after 5+ resistances in a day: "You've guarded your heart 5 times today. Well done."

Each notification independently toggleable with custom time. Users can enable more if they want — the default is minimalist.

---

## 7. Monetization (Free vs Premium)

**Pricing: $2.99/month | $19.99/year | $49.99 lifetime**

### Free Tier
1. Core intervention (Scripture overlay on app open)
2. Up to 3 guarded apps
3. Default escalation (5s → 10s → 20s → 30s)
4. "Return to prayer" / "Proceed" flow
5. "Offer it up" / "Dedicate this moment" (FREE — spiritual heart of app)
6. 40-day Lenten journey with daily Scripture
7. Basic daily stats + time reclaimed estimate
8. Sunday weekly review notification
9. English and Spanish

### Selah Plus (Premium)
1. Unlimited guarded apps
2. Custom starting friction duration (10s, 15s, 30s, 60s)
3. Custom escalation curve or flat duration
4. Choose content type per escalation level
5. Custom scheduling (specific days, hours, time ranges)
6. Armor Lock (lock settings with prayer unlock)
7. Saints/companions as weekly spiritual guides
8. Full liturgical year content (Easter, Ordinary Time, Advent)
9. Detailed weekly review with examination insights and patterns
10. All additional notification types
11. Additional languages as added
12. Journey path visual themes per liturgical season

### Future: Parish Plan
- Bulk pricing for parishes, schools, campus ministries
- Group challenges with aggregate stats
- Parish admin dashboard

---

## 8. Content Specification

### Daily Content Structure

Each day needs:

| Element | Source | Notes |
|---------|--------|-------|
| Scripture passage | Daily Mass lectionary (public domain) | Use established translations per language. Do NOT translate — source from published Bibles. |
| Breath prayer (Attempt 1) | Traditional short prayers (public domain) | "Be still." / "Lord, have mercy." / "Selah." Rotates daily. |
| Reflection question | Original (1–2 sentences) | Must be translated per language. ~40 for Lent. |
| Sub-prompts (Attempt 3+) | Original (~15 phrases) | Escalating in intimacy. Must be translated. |
| Saint/companion quote | Church Fathers, saints, biblical figures (public domain) | 4 tradition variants per day. |
| Liturgical context | Church calendar (public domain) | "Thursday of the Third Week of Lent" |

### Content by Tradition

4 content variants. ~80% shared (Scripture, liturgical context, breath prayers). ~20% varies:

- **Catholic:** Saint quotes, Marian references, examination language, feast days, "offer it up"
- **Protestant:** Biblical figure companions, Scripture-heavy, "heart check" language, "dedicate this moment"
- **Orthodox:** Desert Fathers quotes, Jesus Prayer, Great Lent calendar (starts Feb 23, 2026), icons
- **Exploring:** Universal phrasing, no tradition-specific prayers, gentlest tone, "dedicate this moment"

### Saints/Companions by Tradition

| Catholic | Protestant | Orthodox | Exploring |
|----------|-----------|----------|-----------|
| St. Anthony of the Desert — resisting temptation | Elijah in the cave — hearing God in silence (1 Kings 19) | St. Anthony the Great — Desert Father tradition | Jesus in the wilderness — 40 days of testing (Matt 4) |
| St. Thérèse — small sacrifices | David in the wilderness — patience and trust (Psalms) | St. Mary of Egypt — radical transformation | Moses in the desert — 40 years of faithfulness |
| St. Augustine — battling old habits | Paul in prison — contentment (Phil 4:11–13) | St. John Climacus — The Ladder of Divine Ascent | The Prodigal Son — coming home (Luke 15) |
| St. Ignatius — discernment | Daniel — discipline and fasting (Daniel 1) | St. Seraphim of Sarov — acquiring peace | The woman at the well — thirsting for more (John 4) |
| St. Francis de Sales — gentleness | Ruth — faithfulness in the ordinary | St. Silouan the Athonite — praying for the world | Abraham — stepping into the unknown (Genesis 12) |
| St. John of the Cross — the dark night | Joseph — endurance through injustice (Genesis 37–50) | St. Macarius — prayer in the desert | The Good Samaritan — compassion in action (Luke 10) |
| St. Monica — patient perseverance | Nehemiah — rebuilding with prayer (Nehemiah 1) | St. Ephrem the Syrian — hymns of repentance | Mary Magdalene — encounter and transformation (John 20) |
| St. Benedict — holy habits and rule of life | Esther — courage and fasting (Esther 4) | St. Isaac the Syrian — mercy and silence | The disciples on the road to Emmaus — eyes opened (Luke 24) |

### Translation Strategy

**Launch:** English + Spanish. Additional languages added as rolling updates during Lent.

- **Scripture passages:** Source from established official Bible translations per language. USCCB (English Catholic), ESV/NIV (English Protestant), Biblia de Jerusalén (Spanish Catholic), Reina-Valera (Spanish Protestant). Do NOT translate Scripture — use published texts.
- **Original content** (reflections, sub-prompts, UI strings): Draft in English, translate, then have a native speaker review for naturalness. ~80–100 short phrases total per language.
- **Structure:** JSON locale files from day one. Easy to add languages.

### Theological Review

Have a priest, pastor, or theologian from each tradition review their content variant. Doesn't need formal imprimatur for v1. Credited reviewer adds trust.

---

## 9. Data Model

All data local. SQLite via sqflite. No server, no cloud, no analytics.

### lenten_days
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Day number (1–40 for Lent) |
| season | TEXT | lent / easter / ordinary / advent |
| liturgical_label | TEXT | e.g., "Thursday of the Third Week of Lent" |
| scripture_ref | TEXT | e.g., "Psalm 51:10" |
| scripture_text | TEXT | Loaded from locale JSON per language |
| breath_prayer | TEXT | Short prayer for Attempt 1 ("Be still.", "Lord, have mercy.") |
| reflection | TEXT | Loaded from locale JSON, per tradition |
| companion_name | TEXT NULL | Saint or biblical figure, per tradition variant |
| companion_quote | TEXT NULL | Quote, per tradition variant and language |

### guarded_apps
| Column | Type | Description |
|--------|------|-------------|
| package_name | TEXT PK | Android package name (e.g., com.instagram.android) |
| app_name | TEXT | Display name |
| is_active | BOOLEAN | Currently guarded |
| added_at | DATETIME | When added |

### interventions
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PK | Auto-increment |
| timestamp | DATETIME | When intervention fired |
| app_package | TEXT | Which app attempted |
| outcome | TEXT | "resisted" or "proceeded" |
| reason | TEXT NULL | If proceeded: boredom / anxiety / loneliness / habit / escape / envy / needed |
| offering_text | TEXT NULL | If resisted: dedication text |
| scripture_shown | TEXT | Scripture reference shown |
| pause_duration | INTEGER | Seconds of pause |
| attempt_number | INTEGER | Which attempt today (1st, 2nd, etc.) |
| time_saved_est | INTEGER | Estimated seconds saved (300 = 5 min default) |

### user_settings
| Column | Type | Description |
|--------|------|-------------|
| tradition | TEXT | catholic / protestant / orthodox / exploring |
| language | TEXT | "en", "es", etc. |
| schedule_mode | TEXT | always / evening / sabbath / custom |
| custom_start | TIME NULL | Custom schedule start |
| custom_end | TIME NULL | Custom schedule end |
| custom_days | TEXT NULL | JSON array of days ["mon","tue",...] |
| is_premium | BOOLEAN | Premium subscriber |
| armor_locked | BOOLEAN | Settings currently locked |
| armor_lock_until | DATETIME NULL | When lock expires |
| friction_start_sec | INTEGER | Custom starting pause (premium, default 5) |
| notifications_morning | BOOLEAN | Morning verse enabled |
| notifications_midday | BOOLEAN | Midday reminder enabled |
| notifications_evening | BOOLEAN | Evening examen enabled |
| notifications_celebration | BOOLEAN | Contextual celebration enabled |
| notifications_weekly | BOOLEAN | Sunday review (default: true) |
| onboarding_complete | BOOLEAN | Has finished onboarding |

---

## 10. Technical Architecture

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| App Interception | `flutter_accessibility_service` (Android AccessibilityService) |
| Local Database | `sqflite` (SQLite for Flutter) |
| State Management | Riverpod or Provider |
| Notifications | `flutter_local_notifications` |
| Installed Apps | `installed_apps` or `device_apps` package |
| Localization | `flutter_localizations` + JSON locale files |
| Fonts | Cormorant Garamond (Scripture, via `google_fonts`), Inter or system sans (UI) |
| Icons | Custom SVG (cross, Chi Rho) + Material Icons |
| Charts | `fl_chart` (weekly review stats if needed) |
| In-App Purchase | `in_app_purchase` (Google Play billing) |

### App Interception Flow (Android)

1. User taps guarded app (e.g., Instagram)
2. AccessibilityService detects `TYPE_WINDOW_STATE_CHANGED` event
3. Service checks `event.packageName` against `guarded_apps` table where `is_active = true`
4. Checks current time against user's schedule
5. If match: counts today's attempts for this app (query `interventions` where date = today AND app_package = this app), determines escalation level
6. Shows full-screen overlay with appropriate content for attempt level
7. User makes choice
8. Logs intervention to `interventions` table
9. If resisted: overlay dismisses, performGlobalAction(GLOBAL_ACTION_HOME) to go home. If proceeded: overlay dismisses, target app continues loading.

### Key Flutter Packages

```yaml
dependencies:
  flutter_accessibility_service: ^latest
  sqflite: ^latest
  shared_preferences: ^latest
  flutter_local_notifications: ^latest
  google_fonts: ^latest
  installed_apps: ^latest  # or device_apps
  intl: ^latest
  fl_chart: ^latest
  in_app_purchase: ^latest
  provider: ^latest  # or riverpod
  path_provider: ^latest
```

### Project Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, theme, routing
├── models/
│   ├── lenten_day.dart
│   ├── guarded_app.dart
│   ├── intervention.dart
│   └── user_settings.dart
├── database/
│   ├── database_helper.dart          # SQLite init, migrations
│   └── seed_data.dart                # Load JSON content into DB
├── services/
│   ├── accessibility_handler.dart    # AccessibilityService bridge
│   ├── notification_service.dart
│   ├── liturgical_calendar.dart      # Calculate current day, season
│   ├── purchase_service.dart         # In-app purchase logic
│   └── stats_service.dart            # Calculate streaks, time saved, patterns
├── screens/
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   ├── promise_screen.dart
│   │   ├── tradition_screen.dart
│   │   ├── app_selection_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── how_it_works_screen.dart
│   │   ├── permission_screen.dart
│   │   └── ready_screen.dart
│   ├── home/
│   │   └── home_screen.dart          # Today tab
│   ├── journey/
│   │   └── journey_screen.dart       # Desert path visualization
│   ├── offerings/
│   │   └── offerings_screen.dart     # Sacrifice journal
│   ├── weekly_review/
│   │   └── weekly_review_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── armor_lock_screen.dart
│       └── prayer_unlock_screen.dart
├── widgets/
│   ├── intervention_overlay.dart     # THE core overlay widget
│   ├── scripture_card.dart
│   ├── progress_path.dart            # Journey visualization
│   ├── stats_bar.dart
│   ├── offering_prompt.dart
│   ├── examination_prompt.dart
│   └── breath_prayer_display.dart
├── content/
│   ├── lent_catholic_en.json
│   ├── lent_protestant_en.json
│   ├── lent_orthodox_en.json
│   ├── lent_universal_en.json
│   ├── lent_catholic_es.json
│   ├── lent_protestant_es.json
│   ├── lent_orthodox_es.json
│   ├── lent_universal_es.json
│   ├── saints.json
│   ├── breath_prayers.json
│   └── sub_prompts.json
├── theme/
│   ├── colors.dart
│   ├── typography.dart
│   └── spacing.dart
└── l10n/
    ├── app_en.json                   # UI strings English
    └── app_es.json                   # UI strings Spanish
```

### Android-Specific Configuration

**AndroidManifest.xml additions:**
```xml
<!-- AccessibilityService declaration -->
<service
    android:name=".AccessibilityListener"
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
```

**res/xml/accessibilityservice.xml:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackVisual"
    android:notificationTimeout="300"
    android:accessibilityFlags="flagDefault"
    android:canRetrieveWindowContent="false" />
```

Note: `canRetrieveWindowContent` is `false` — Selah never reads screen content. This is important for privacy and for Google Play approval.

---

## 11. Design Specification

### Philosophy

Beautiful, elegant, modern, sleek, clean. **Church, not spa.** Think of the best modern sacred architecture: clean lines, intentional negative space, reverence through simplicity. The app should feel like walking into a quiet chapel.

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Deep Navy | `#1B2340` | Primary background, intervention screen |
| Sacred Gold | `#C9A84C` | Scripture text, crosses, primary buttons, accents |
| Warm Cream | `#F5F0E8` | Card backgrounds, secondary surfaces |
| Charcoal | `#2D2D2D` | Body text on light backgrounds |
| Subdued Gray | `#666666` | "Proceed" button, metadata, secondary text |

### Typography

- **Scripture / reflections:** Cormorant Garamond (Google Fonts, free). Warm, literary, sacred without being medieval.
- **UI elements:** System sans-serif or Inter. Clean, modern, readable.
- Serif = tradition. Sans-serif = modern. Together = **ancient wisdom, contemporary delivery.**

### Intervention Screen Layout

```
┌──────────────────────────────┐
│                              │
│         ✦ (gold cross)       │  ← Top 15%
│                              │
│                              │
│    "Create in me a clean     │
│     heart, O God, and        │  ← Middle 50%: Scripture
│     renew a right spirit     │     Large serif, gold on navy
│     within me."              │     Fades in over 1.5s
│       — Psalm 51:10          │
│                              │
│   "What are you looking      │  ← Sub-prompt (Attempt 2+)
│    for right now?"           │     Smaller italic
│                              │
│                              │
│   ┌─────────────────────┐    │
│   │  Return to prayer   │    │  ← Large, gold, prominent
│   └─────────────────────┘    │     (appears after pause)
│                              │
│    Proceed to Instagram      │  ← Smaller, gray
│                              │
│  Attempt 3 today · 20 sec   │  ← Bottom edge, subtle
└──────────────────────────────┘
```

### Visual Principles

- **Animations:** Subtle, reverent. Scripture fades in (1.5s). Buttons appear after pause. Gold shimmer on "Offered up." No bouncing, no confetti, no gamification aesthetics.
- **Negative space:** Generous margins everywhere. Let the Word breathe.
- **Journey illustrations:** Minimal, evocative. Desert (Lent), green landscape (Easter), rolling fields (Ordinary Time), starlit night (Advent).
- **Cross/Chi Rho:** Simple gold line art. Appears on intervention screen and as subtle branding throughout.

---

## 12. Deployment & Distribution

### Google Play Store
- **Category:** Lifestyle (broader reach than Religious)
- AccessibilityService declaration required in manifest AND store listing
- Privacy policy required (hosted URL)
- Content rating: Everyone
- Target SDK: latest stable Android API

### Store Listing

**Title:** Selah — Sacred Screen Guard

**Short description:** Don't pause. Pray. Turn every temptation into a prayer.

**Long description (draft):**
When you reach for distraction, Selah meets you with Scripture. Instead of a timer or a breathing exercise, you encounter the living Word of God — and choose whether to return to prayer or proceed.

Selah transforms screen time management from a willpower problem into a spiritual practice. Every moment of self-denial becomes an offering. Every resisted scroll becomes a prayer.

Tailored for Catholic, Protestant, Orthodox, and exploring Christians. Built for Lent. Built for life.

### Distribution Strategy
- Christian subreddits (r/Catholicism, r/Christianity, r/Reformed, r/OrthodoxChristianity)
- Parish WhatsApp/email groups
- Catholic and Christian Twitter/X (Lent is heavily discussed)
- Product Hunt launch
- Ask priests, pastors, campus ministers to share
- Cross-promote with companion Lent Tracker app (v2)

---

## 13. Build Timeline

Target: submit to Google Play by **February 16** (review takes 1–3 days). Live by Ash Wednesday, **February 18**.

| Day | Focus | Deliverable |
|-----|-------|-------------|
| **1** | Flutter project setup, theme system (colors, typography, spacing), AccessibilityService integration | App detects target app launches, shows basic overlay |
| **2** | Intervention overlay: cross, breath prayer, Scripture fade-in, pause timer, escalating content, choice buttons | Beautiful full-screen intervention with all attempt levels |
| **3** | Onboarding flow: all 8 screens including tradition selection, app selection, permission grant | Complete first-run experience |
| **4** | Database, intervention logging, home screen, stats, time reclaimed, offer-it-up/dedicate flow | Core data flow working end-to-end |
| **5** | Journey tab (desert path), Offerings tab, weekly review, settings, armor lock with prayer unlock | All screens built |
| **6** | 40-day Lenten content (all 4 tradition variants), English + Spanish | Complete content bundle |
| **7** | Polish, testing, notifications, in-app purchase setup, edge cases | Polished app ready for submission |
| **8** | Google Play submission, store listing, screenshots, privacy policy | App submitted |

---

## 14. Implementation Notes for Claude Code

### Critical Things to Remember

1. **The intervention overlay is the entire product.** If it's not beautiful and smooth, nothing else matters. Prioritize this above all other screens.

2. **AccessibilityService is the technical core.** Use `flutter_accessibility_service` package. The service must:
   - Detect `TYPE_WINDOW_STATE_CHANGED` events
   - Check package name against user's guarded apps list
   - Show a full-screen overlay via `FlutterAccessibilityService.showOverlayWindow()`
   - Handle the overlay as a separate Flutter entry point (`@pragma("vm:entry-point")`)

3. **Content is loaded from JSON files, not hardcoded.** This enables easy language additions and tradition variants. The JSON structure should be: `content/{season}_{tradition}_{language}.json`

4. **All data is local.** No network calls, no servers, no analytics. SQLite via sqflite for structured data. SharedPreferences for simple settings.

5. **The "Proceed" option must always be available.** Never lock users out. This is a theological principle (voluntary sacrifice) AND a UX principle (trust).

6. **Buttons must be hidden during the pause period.** The pause timer counts down, THEN buttons fade in. This forces actual engagement with the content.

7. **Escalation is per-app, per-day.** If someone opens Instagram 3 times and TikTok once, Instagram is at attempt 3 (20s) but TikTok is at attempt 1 (5s). Resets at midnight.

8. **The tradition selection affects content loading only.** The app mechanics, database schema, screens, and navigation are identical across all traditions. Only the JSON content files differ.

9. **"Offer it up" (Catholic) = "Dedicate this moment" (Protestant/Orthodox/Exploring).** Same feature, different label. Conditional on `user_settings.tradition`.

10. **Free tier = 3 guarded apps, default friction, core features. Premium = unlimited apps, custom friction, armor lock, saints, liturgical year, advanced notifications.** Check `user_settings.is_premium` before enabling premium features.

11. **Privacy-first:** AccessibilityService config must set `canRetrieveWindowContent="false"`. Google Play listing must explain why AccessibilityService is needed. Privacy policy must state all data stays on device.

12. **The visual language is navy + gold + serif Scripture + sans-serif UI.** Not pastel. Not wellness. Not gamified. Sacred and modern.

13. **Time reclaimed = number of resistances × 300 seconds (5 minutes).** Simple estimate. Display in human-readable format.

14. **Armor lock auto-relocks after 5 minutes.** After prayer unlock, a timer starts. When it expires, settings lock again.

15. **Google Play AccessibilityService policy:** Apps using AccessibilityService must declare it and explain the use case clearly. Selah's use is legitimate (app launch detection for screen time management) and follows the precedent set by ScreenZen and one sec.

### Build Order (suggested)

The intervention overlay depends on the AccessibilityService, which depends on Android configuration. The onboarding depends on the app selection and settings infrastructure. The stats and journey depend on the database. Suggested dependency-aware build order:

1. **Theme + project scaffold** — colors, fonts, spacing, basic navigation shell
2. **Android AccessibilityService setup** — manifest, config XML, Flutter bridge, basic event detection
3. **Intervention overlay** — the full overlay widget with all attempt levels, animations, timers
4. **Database + models** — SQLite tables, Dart model classes, seed data from JSON
5. **Onboarding flow** — all 8 screens wired up, writing to database
6. **Home screen + stats** — reading from database, displaying today's data
7. **Journey + Offerings + Weekly Review** — secondary screens
8. **Settings + Armor Lock + Prayer Unlock** — settings management, lock logic
9. **Notifications** — scheduled and contextual
10. **In-app purchase** — premium gating
11. **Content creation** — all 40 days × 4 traditions × 2 languages
12. **Polish + submission**

### Potential Gotchas

- **AccessibilityService overlay on Android 12+:** May need `TYPE_APPLICATION_OVERLAY` window type. Test on multiple API levels.
- **Battery optimization:** AccessibilityService can be killed by aggressive battery savers on some OEMs (Xiaomi, Samsung). May need to guide user to exempt Selah from battery optimization.
- **Google Play review for AccessibilityService:** First submission may get extra scrutiny. Have a clear, honest description ready. ScreenZen and one sec both passed review, so the use case is accepted.
- **flutter_accessibility_service overlay entry point:** The overlay runs as a SEPARATE Flutter engine. It does NOT share state with the main app. Communication between the overlay and the main app must go through the AccessibilityService (method channels) or shared storage (SharedPreferences / sqflite).
- **Overlay dismissal on "Proceed":** After user chooses to proceed, the overlay must dismiss cleanly and the target app must continue loading. This may require `performGlobalAction(GLOBAL_ACTION_BACK)` followed by letting the original intent through, OR simply hiding the overlay window.
- **Counting attempts:** Query the interventions table filtered by today's date and the specific app's package name. This query runs every time an intervention fires, so it must be fast.
- **Midnight reset:** Attempt counts reset at midnight. Use the date portion of the timestamp for grouping. Consider timezone handling.
- **Content file loading:** Load the correct JSON based on `{season}_{tradition}_{language}`. If a specific tradition file is missing, fall back to universal. If a language is missing, fall back to English.

---

> *"Watch and pray that you may not enter into temptation." — Matthew 26:41*

✦
