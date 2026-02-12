# Selah v1.0 Implementation Plan

**Target:** Ash Wednesday, February 18, 2026
**Submit to Play Store:** February 16, 2026

---

## Overview

This plan is organized into **phases**, each building on the previous. Within each phase, pieces are listed in dependency order. A piece should not be started until its dependencies are complete.

```
Phase 1: Foundation (no dependencies)
    ↓
Phase 2: Core Feature - AccessibilityService + Overlay
    ↓
Phase 3: Intervention Behavior (depends on Phase 2)
    ↓
Phase 4: Onboarding (depends on Phase 3 - needs snooze/schedule working)
    ↓
Phase 5: Main App Screens (depends on Phase 3, 4)
    ↓
Phase 6: Settings & Controls (depends on Phase 5)
    ↓
Phase 7: Notifications & Widget (depends on Phase 6)
    ↓
Phase 8: Content & Polish (depends on all above)
    ↓
Phase 9: Monetization & Submission
```

**Important:** Phase 3 (Intervention Behavior) must be complete before Phase 4 (Onboarding) because onboarding sets schedule/snooze preferences that the overlay must respect immediately after setup.

---

## Phase 1: Foundation

**Goal:** App runs with themed navigation and database ready. No functionality yet.

### 1.1 Project Scaffold
- Create new Android project in Android Studio
- Package: `com.selah.app`
- Min SDK 26, Target SDK 34
- Kotlin + Jetpack Compose + Material3
- Set up Gradle with all dependencies (Room, DataStore, Coroutines, Navigation)

**Deliverable:** Empty app compiles and runs

### 1.2 Theme & Design System
- `ui/theme/Color.kt` - Brand colors (Deep Navy, Sacred Gold, Warm Cream, etc.)
- `ui/theme/Type.kt` - Typography (Cormorant Garamond for Scripture, system sans for UI)
- `ui/theme/Theme.kt` - Material3 theme with dark color scheme
- Add Cormorant Garamond font files to `res/font/`

**Deliverable:** App has correct colors and fonts

### 1.3 Navigation Structure
- `ui/navigation/SelahNavigation.kt` - Navigation graph
- Bottom navigation with 4 tabs: Today / Journey / Offerings / Settings
- Placeholder screens for each tab
- Onboarding flow navigation (separate from main nav)

**Deliverable:** Can navigate between placeholder screens

### 1.4 Room Database Setup
- `data/database/SelahDatabase.kt` - Room database class
- Entity classes:
  - `DailyContent.kt` - Scripture, reflections, companions
  - `GuardedApp.kt` - Package name, display name, active status
  - `Intervention.kt` - Logged interventions with outcomes
  - `UserSettings.kt` - Single row for all user preferences
- DAO interfaces for each entity
- Database migrations strategy (start with version 1)

**Deliverable:** Database compiles, can insert/query test data

### 1.5 Repository Layer
- `ContentRepository.kt` - Daily content access, Lenten day calculation
- `InterventionRepository.kt` - Log interventions, query stats
- `SettingsRepository.kt` - User preferences, guarded apps management
- Coroutine-based (suspend functions, Flow for observables)

**Deliverable:** Repositories can read/write through DAOs

### 1.6 Application Class
- `SelahApplication.kt` - Initialize database, provide dependencies
- Simple manual DI (no Hilt/Dagger for v1 - keep it simple)

**Deliverable:** App starts with database initialized

---

## Phase 2: Core Feature - AccessibilityService + Overlay

**Goal:** Opening a guarded app shows the intervention overlay. This is THE critical feature.

### 2.1 AccessibilityService Setup
- `service/SelahAccessibilityService.kt`
- Register in AndroidManifest.xml with correct permissions
- `res/xml/accessibility_service_config.xml` with typeWindowStateChanged only
- `onServiceConnected()` - load guarded apps into memory
- `onAccessibilityEvent()` - detect package names

**Deliverable:** Service runs, logs when guarded app opened

### 2.2 In-Memory Guarded Apps Cache
- `guardedAppsCache: Set<String>` in service
- Load from Room on service start (coroutine in onServiceConnected)
- Method to refresh cache when apps added/removed
- **Cache refresh mechanism:** When main app writes to guarded_apps table, also write `cache_dirty = true` to SharedPreferences. Service checks this flag before each intervention and reloads if dirty. Simpler and more reliable than broadcast receivers.

**Deliverable:** Fast package name lookup without database queries

### 2.3 BOOT_COMPLETED Receiver
- `receiver/BootCompletedReceiver.kt`
- Register in AndroidManifest with `RECEIVE_BOOT_COMPLETED` permission
- On boot, check if AccessibilityService should be running
- If service was enabled, it auto-restarts (Android manages this), but receiver ensures app state is correct
- Also handles `MY_PACKAGE_REPLACED` for app updates

**Deliverable:** Service restarts correctly after phone reboot and app updates

### 2.4 Overlay Permission Flow
- Check `Settings.canDrawOverlays()`
- If not granted, navigate to overlay settings
- Return handling to continue after permission granted

**Deliverable:** App requests and receives overlay permission

### 2.5 Overlay Manager
- `service/SelahOverlayManager.kt`
- Creates overlay View using WindowManager
- `TYPE_APPLICATION_OVERLAY` with correct flags
- `showOverlay(packageName: String)` - display overlay
- `hideOverlay()` - remove overlay
- Handle back button (should NOT dismiss - user must choose)

**Deliverable:** Overlay appears over guarded app

### 2.6 Intervention Overlay Layout (XML)
- `res/layout/overlay_intervention.xml`
- Gold cross at top
- Scripture text area (Cormorant Garamond)
- Sub-prompt text area
- Countdown indicator
- "Return to prayer" button (gold, hidden initially)
- "Continue anyway" button (gray, hidden initially)
- Attempt counter at bottom

**Deliverable:** Beautiful overlay layout matching design spec

### 2.7 Overlay View Binding & Basic Logic
- `ui/overlay/InterventionOverlayView.kt`
- Inflate layout, bind views
- Accept data: scripture, app name, attempt number, pause duration
- Countdown timer logic
- Button visibility after countdown
- Callbacks for button presses

**Deliverable:** Overlay displays data and buttons appear after countdown

---

## Phase 3: Intervention Behavior

**Goal:** Full intervention flow with escalation, offering, and examination.

### 3.1 Escalation Logic

**Important flow clarification:**
1. Event arrives → check in-memory cache (instant, no I/O)
2. If NOT guarded → return immediately (99% of events)
3. If guarded → THEN query attempt count via coroutine (Dispatchers.IO)
4. This is acceptable because we only hit the database when we're already committed to showing an overlay

- Query interventions table for count of this app today
- Determine pause duration: 5s → 10s → 20s → 30s → 30s...
- Determine what content to show per attempt level
- Same Scripture all day (query by date, can cache daily)

**Deliverable:** Escalation works correctly across attempts

### 3.2 Snooze Check
- Before showing overlay, check `snooze_until` in SharedPreferences
- If current time < snooze_until, skip overlay entirely
- Let app open normally

**Note:** Snooze lives in SharedPreferences (not Room) because it's checked on every guarded app event and must be fast. The home screen's "Paused until 2:30 PM" banner also reads from SharedPreferences for consistency.

**Deliverable:** Snooze mode prevents interventions

### 3.3 Schedule Check
- Before showing overlay, check user's schedule
- Always / Evening (6pm-7am) / Sabbath (Sundays)
- Skip overlay if outside scheduled times

**Deliverable:** Schedule-based activation works

### 3.4 "Return to Prayer" Flow
- User taps "Return to prayer" button
- Show offering prompt (slide up or transition)
- Quick picks: For a loved one / For peace / For my own healing / For the world
- Optional: Custom text input
- Log intervention with outcome="resisted", offering_text
- Dismiss overlay
- Navigate to home screen (performGlobalAction HOME)

**Deliverable:** Full "resist" flow with offering dedication

### 3.5 "Continue Anyway" Flow
- User taps "Continue anyway"
- Show examination prompt
- Quick picks: Boredom / Anxiety / Loneliness / Habit / Escape / Envy / I need this app
- Log intervention with outcome="proceeded", reason
- Dismiss overlay
- Let target app continue opening

**Deliverable:** Full "proceed" flow with examination

### 3.6 Overlay Animations
- Cross fades in on overlay appear
- Scripture fades in (1.5s after cross)
- Buttons fade in after countdown
- "Offered up" animation on resist (gold sparkle or similar)
- Keep animations subtle and reverent

**Deliverable:** Polished, spiritual feel to transitions

---

## Phase 4: Onboarding

**Goal:** New users complete 8-screen onboarding and have Selah configured.

### 4.1 Onboarding Navigation
- Separate nav graph for onboarding
- Check `onboarding_complete` flag on app start
- If false, show onboarding; if true, show main app

**Deliverable:** App routes to correct flow based on onboarding state

### 4.2 Welcome Screen
- Navy background, gold cross fades in
- "Be still, and know that I am God." — Psalm 46:10
- Beat of silence (2s delay), then "Welcome to Selah."
- "Begin" button

### 4.3 Promise Screen
- Explain what Selah does
- "Set up my guard" button

### 4.4 Tradition Selection Screen
- Four options: Catholic / Protestant / Orthodox / Exploring
- For v1.0: Catholic and Exploring/Universal available
- Protestant/Orthodox show "Coming soon" badge
- Save to UserSettings

### 4.5 App Selection Screen
- Query PackageManager for installed apps
- Surface common culprits at top (Instagram, TikTok, YouTube, Twitter, etc.)
- Grid layout with app icons
- Gold checkmarks on selection
- Counter: "Guarding 3 apps"
- Free tier limit: 3 apps (show upgrade prompt for 4th)
- Save selections to GuardedApp table

### 4.6 Schedule Screen
- Always (default) / Evening Peace / Sabbath Rest
- Custom = premium (show upgrade prompt)
- Save to UserSettings

### 4.7 How It Works Screen
- Explain escalating friction
- "Keep Selah running in the background..."
- Visual or illustration

### 4.8 Permission Screen
- Explain accessibility permission need
- Privacy assurance text
- "Grant permission" button → opens accessibility settings
- Return handling: check if permission now granted
- Also request overlay permission here

### 4.9 Ready Screen
- Show mock intervention preview
- "I'm ready" button
- Set `onboarding_complete = true`
- Navigate to main app

**Deliverable:** Complete onboarding flow, user is set up

---

## Phase 5: Main App Screens

**Goal:** Home, Journey, and Offerings tabs show real data.

### 5.1 Home Screen (Today Tab)
- Liturgical context at top (if Lent: "Day X of Lent", else date)
- Today's Scripture, beautifully typeset
- Tap to expand: reflection + companion quote
- Stats bar: "Guarded X times · Chose prayer Y times · Reclaimed Z min"
- Pull data from ContentRepository and InterventionRepository

**Important: Home screen must refresh on every resume.** User might arrive here after:
- Normal app open (tap icon)
- Returning from "Offered up" (overlay sent them home)
- Coming back from settings
- Any other navigation

Query database in `onResume()` or use Flow/LiveData to ensure stats are always current.

### 5.2 Lenten Day Calculation

**Decision: Lent = 46 calendar days** (Ash Wednesday through Holy Saturday)
- Include Sundays in the count (simpler date math, better UX)
- This means 46 days of content, not 40
- "40 days of Lent" is marketing language; internally it's 46 entries
- Day 1 = Ash Wednesday (Feb 18, 2026)
- Day 46 = Holy Saturday (April 4, 2026)

- Calculate: `(today - ashWednesday).days + 1`
- Return day number 1-46, or null if outside Lent season

### 5.3 Journey Tab - Lent Mode
- Desert path visualization (can be simple for v1)
- 46 waypoints representing calendar days (Ash Wed → Holy Saturday)
- Completed days glow gold
- Today pulses
- Future days dimmed
- Tap past day → show that day's Scripture + stats

### 5.4 Journey Tab - Non-Lent Mode
- Calendar or list view of guarded days
- Stats: streak, total resistances, time reclaimed all-time
- Simpler than Lent visualization

### 5.5 Offerings Tab
- List of dedicated offerings from interventions
- Grouped by day
- "March 3 — Offered 4 moments for Mom's health"
- Pull from interventions where outcome="resisted"

### 5.6 Stats Calculation
- Time reclaimed = count of resisted × 300 seconds (5 min estimate)
- Format nicely: "2 hours 15 minutes"
- Daily, weekly, all-time views

**Deliverable:** All three main tabs show real, meaningful data

---

## Phase 6: Settings & Controls

**Goal:** User can configure Selah and use Armor Lock/Snooze.

### 6.1 Settings Screen
- Guarded Apps: list with toggle, add button
- Schedule: picker (Always/Evening/Sabbath)
- Tradition: picker (Catholic/Exploring for v1)
- Notifications: toggles for each type
- Armor Lock: current status + enable button
- Snooze: quick-access button
- Privacy: view data, delete all, privacy policy link
- About: version, credits

### 6.2 Guarded Apps Management
- List current guarded apps with remove option
- "Add app" → app picker (similar to onboarding)
- Enforce 3-app limit for free tier
- After add/remove, refresh service's in-memory cache

### 6.3 Armor Lock
- Enable screen: choose duration (1 day / 3 days / 1 week / Until Easter)
- When locked: settings become read-only
- "I need to change something" → Prayer Unlock flow
- "Never mind" → return

### 6.4 Prayer Unlock
- Based on tradition:
  - Catholic: Three Hail Marys (tap through each line, 3 times)
  - Exploring: Lord's Prayer, 3 times
- Tap-to-advance through prayer text
- After completion: unlock for 5 minutes, then auto-relock
- Store `armor_lock_until` timestamp

### 6.5 Snooze Mode
- "Pause Selah for 30 minutes" button
- Set `snooze_until` = now + 30 minutes in SharedPreferences (NOT Room - needs fast reads)
- Home screen reads from same SharedPreferences to show "Paused until 2:30 PM" banner
- Service checks SharedPreferences before showing overlay (see 3.2)

### 6.6 Premium Gating
- Check `is_premium` flag before allowing:
  - More than 3 guarded apps
  - Custom schedule
  - Custom friction settings
- Show upgrade prompt when hitting limits

**Deliverable:** Full settings functionality with Armor Lock and Snooze

---

## Phase 7: Notifications & Widget

**Goal:** Notifications work, widget displays daily verse.

### 7.1 Notification Channels
- Create channels on app start:
  - Weekly Review (default on)
  - Service Status (for killed alerts)
  - Daily Verses (optional)
  - Prayer Reminders (optional)

### 7.2 Weekly Review Notification
- Schedule for Sunday 7 PM using WorkManager
- Build summary: times guarded, times chose prayer, time reclaimed
- Tap opens app to a summary view
- AlarmManager as backup for exact timing

### 7.3 Service-Killed Detection
- In AccessibilityService.onDestroy(), schedule notification
- "Selah was closed and can no longer guard your apps. Tap to restart."
- Tap opens app → checks and restarts service
- Use WorkManager periodic check as backup

### 7.4 Optional Notifications (Future/Premium)
- Morning Verse: 8 AM
- Midday Prayer: 12 PM
- Evening Examen: 9 PM
- Celebration: after 5+ resistances
- These can be stubs for v1.0, implement fully in v1.1

### 7.5 Home Screen Widget
- `widget/SelahWidgetProvider.kt` extends AppWidgetProvider
- `res/layout/widget_selah.xml` - RemoteViews layout
- Display today's Scripture verse
- Tap opens app
- Update daily using AlarmManager or WorkManager
- `res/xml/selah_widget_info.xml` - widget metadata

**Deliverable:** Weekly review notification + working widget

---

## Phase 8: Content & Polish

**Goal:** Real Scripture content loaded, app is polished.

### 8.1 Content JSON Structure
```json
{
  "day": 1,
  "scripture_ref": "Psalm 51:10",
  "scripture_text": "Create in me a clean heart, O God...",
  "breath_prayer": "Be still.",
  "reflection": "What weighs on your heart today?",
  "companion_name": "St. Augustine",
  "companion_quote": "Our hearts are restless..."
}
```

### 8.2 Year-Round Content (40-50 days)
- Create `res/raw/content_year_round_en.json`
- 40-50 curated Scripture passages
- Covers diverse themes: rest, temptation, peace, trust, etc.
- Breath prayers rotate through set of 5-6
- Reflections are gentle, inviting

### 8.3 Lent Content - Universal (46 days)
- Create `res/raw/content_lent_universal_en.json`
- **46 entries** (Ash Wednesday through Holy Saturday, including Sundays)
- Follows Lenten themes: repentance, fasting, prayer, almsgiving
- Desert imagery in reflections
- Biblical companions (Moses, Elijah, Jesus in wilderness)
- Sundays can have slightly different tone (resurrection hope)

### 8.4 Lent Content - Catholic (46 days)
- Create `res/raw/content_lent_catholic_en.json`
- **46 entries** matching universal structure
- Same Scripture as universal
- Catholic saints as companions
- "Offer it up" language
- Examination of conscience framing

### 8.5 Breath Prayers & Sub-Prompts
- `res/raw/breath_prayers.json` - 6-8 short prayers
- `res/raw/sub_prompts.json` - 15 escalating prompts

### 8.6 Content Loader
- `util/ContentLoader.kt`
- Load JSON from res/raw on first app run
- Insert into Room database
- Check for content version to handle updates

### 8.7 Polish Pass
- Test all flows end-to-end
- Fix any animation jank
- Ensure consistent spacing and typography
- Test on multiple screen sizes
- Test with different font scales (accessibility)
- Dark mode consistency check

### 8.8 Error Handling
- Graceful fallbacks if content not found
- Handle edge cases: no guarded apps, service not running
- Helpful error messages, not crashes

**Deliverable:** App has real content, feels polished

---

## Phase 9: Monetization & Submission

**Goal:** Premium features work, app submitted to Play Store.

### 9.1 Google Play Billing Setup
- Add Play Billing Library dependency
- Create products in Play Console:
  - `selah_monthly` - $2.99/month
  - `selah_yearly` - $19.99/year
  - `selah_lifetime` - $49.99 one-time

### 9.2 Billing Implementation
- `billing/BillingManager.kt`
- Connect to BillingClient
- Query purchases on app start
- Purchase flow UI
- Handle purchase callbacks
- Update `is_premium` in UserSettings

### 9.3 Premium Features Check
- Gate unlimited apps, custom schedule, Armor Lock, etc.
- Upgrade prompts at limit points
- Restore purchases flow

### 9.4 Play Store Assets
- App icon (512x512, various densities)
- Feature graphic (1024x500)
- Screenshots (phone, 7" tablet, 10" tablet)
- Short description (80 chars)
- Full description (4000 chars)
- Privacy policy URL

### 9.5 Privacy Policy
- Host on simple webpage
- Explain: all data on-device, no analytics, no tracking
- AccessibilityService explanation
- Data deletion instructions

### 9.6 Play Store Listing
- Title: "Selah — Sacred Screen Guard"
- Category: Lifestyle
- Content rating: Everyone
- AccessibilityService declaration with clear description
- Submit for review

### 9.7 Pre-Launch Testing
- Internal testing track first
- Test on multiple devices
- Fix any crashes from Play Console's Android Vitals (no Crashlytics - keeps "no analytics" promise)
- Promote to production

**Deliverable:** App live on Play Store

---

## Dependencies Summary

```
Phase 1 (Foundation)
  └── No dependencies, start here

Phase 2 (AccessibilityService + Overlay)
  └── Depends on: 1.4 (Database), 1.6 (Application)

Phase 3 (Intervention Behavior)
  └── Depends on: Phase 2 complete

Phase 4 (Onboarding)
  └── Depends on: Phase 3 complete (snooze/schedule must work before onboarding sets them)

Phase 5 (Main Screens)
  └── Depends on: Phase 4 complete

Phase 6 (Settings)
  └── Depends on: Phase 5, 2.2 (Cache refresh via dirty flag)

Phase 7 (Notifications & Widget)
  └── Depends on: Phase 6, 1.5 (Repositories)

Phase 8 (Content & Polish)
  └── Depends on: All above functional

Phase 9 (Monetization & Submission)
  └── Depends on: All above complete
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| AccessibilityService permission confusing for users | Clear onboarding explanation, FAQ in app |
| Service killed by battery optimization | Detect and notify, guide user to whitelist |
| Play Store rejects for AccessibilityService | Clear declaration, minimal permissions, no content reading |
| Content not ready in time | Start with 20 days minimum, expand post-launch |
| Overlay not working on some devices | Test on Samsung, Xiaomi, Pixel early |

---

## Testing Checklist

### Core Flow
- [ ] Open guarded app → overlay appears
- [ ] Countdown works correctly
- [ ] "Return to prayer" → offering flow → home screen
- [ ] "Continue anyway" → examination flow → app opens
- [ ] Escalation increases with each attempt
- [ ] Resets at midnight

### Onboarding
- [ ] All 8 screens work
- [ ] Tradition selection saves
- [ ] App selection saves and syncs to service
- [ ] Permissions granted correctly
- [ ] Can complete full onboarding

### Settings
- [ ] Add/remove guarded apps works
- [ ] Changes reflect immediately in service
- [ ] Armor Lock prevents changes
- [ ] Prayer Unlock works
- [ ] Snooze pauses interventions

### Edge Cases
- [ ] Service restart after phone reboot
- [ ] Service restart after app update
- [ ] No crash if content missing
- [ ] Works with 0 guarded apps (just shows home)
- [ ] Works during Lent and outside Lent

---

## Notes for CTO Review

1. **Phase 2 is the make-or-break.** If the overlay doesn't work reliably, nothing else matters. Suggest allocating extra time here.

2. **XML Views for overlay is intentional.** Compose in WindowManager overlays has known issues. This is the safer choice.

3. **In-memory cache is critical for performance.** AccessibilityService events fire constantly. Database queries on each event would destroy battery.

4. **Content can be minimal at launch.** 40 days Lent + 40 days year-round is enough. Quality over quantity.

5. **Play Store approval is a real risk.** AccessibilityService apps face scrutiny. Our minimal permissions (no content reading) help, but should plan for potential back-and-forth.

6. **No Hilt/Dagger.** Manual DI keeps the project simple and reduces build complexity. Can add later if needed.

7. **Widget uses RemoteViews, not Glance.** Glance is too new and has compatibility issues.

---

## Backlog (Post-v1.0)

Items identified during planning that are not blocking for launch:

### v1.1 Candidates
- **Data export:** Users may want to export their offerings/stats (CSV or shareable format)
- **TalkBack accessibility:** Overlay must work with screen readers since we're using AccessibilityService (ironic if our accessibility app isn't accessible)
- **Font scaling:** Verify overlay remains usable at largest system font sizes

### Technical Debt to Address
- **App update handling:** Verify database migrations work cleanly, service restarts after MY_PACKAGE_REPLACED
- **Edge case:** What if user is mid-overlay when app updates? (Probably just dismiss and let them re-trigger)

### Future Consideration
- **Crashlytics:** Decided against for v1.0 to maintain "no analytics" promise. Revisit if crash debugging becomes painful. If added, update privacy policy.

---

*Plan version: 1.1*
*Last updated: February 11, 2026*
*Reviewed by: CTO*
