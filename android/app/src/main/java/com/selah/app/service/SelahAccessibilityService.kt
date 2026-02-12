package com.selah.app.service

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.selah.app.MainActivity
import com.selah.app.SelahApplication
import com.selah.app.data.model.GuardedApp
import com.selah.app.data.model.Intervention
import com.selah.app.data.model.UserSettings
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.util.Calendar

/**
 * Data class for intervention escalation
 */
data class EscalationData(
    val attemptNumber: Int, // 1-based for display (attempt 1 = first time)
    val pauseDurationSeconds: Int,
    val contentLevel: ContentLevel,
    val scriptureText: String,
    val scriptureRef: String,
    val subPromptText: String?,
    val companionName: String?,
    val companionQuote: String?
)

enum class ContentLevel {
    BREATH_PRAYER,      // Attempt 1: Just "Be still."
    SCRIPTURE,          // Attempt 2: Full scripture + basic sub-prompt
    SCRIPTURE_DEEPER,   // Attempt 3: Scripture + deeper sub-prompt
    SCRIPTURE_COMPANION // Attempt 4+: Scripture + sub-prompt + companion
}

/**
 * AccessibilityService that detects when a guarded app is opened.
 *
 * This service:
 * - Loads active guarded app package names into memory on connect
 * - Checks TYPE_WINDOW_STATE_CHANGED events against the in-memory set
 * - Checks snooze status and schedule before showing overlay
 * - Calculates escalation based on today's attempt count
 * - Shows intervention overlay with progressive content
 * - Logs interventions to database
 */
class SelahAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "SelahAccessibility"
        private const val PREFS_NAME = "selah_service_prefs"
        private const val KEY_CACHE_DIRTY = "cache_dirty"
        private const val KEY_SNOOZE_UNTIL = "snooze_until"
        private const val OWN_PACKAGE = "com.selah.app"
        private const val DEBOUNCE_MS = 2000L
        private const val DISMISS_GRACE_MS = 3000L
    }

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var guardedApps: Map<String, GuardedApp> = emptyMap()
    private var cachedSettings: UserSettings? = null
    private lateinit var prefs: SharedPreferences
    private lateinit var overlayManager: SelahOverlayManager

    // Session tracking
    private var lastOverlayPackage: String? = null
    private var lastOverlayTime: Long = 0
    private var activeSession: String? = null
    private var lastSeenPackage: String? = null
    private var lastDismissTime: Long = 0
    private var lastDismissedPackage: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AccessibilityService connected")

        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        overlayManager = SelahOverlayManager(this)

        loadGuardedApps()
        loadSettings()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return
        if (packageName == OWN_PACKAGE) return

        // Check if cache needs refresh
        if (prefs.getBoolean(KEY_CACHE_DIRTY, false)) {
            Log.d(TAG, "Cache dirty flag detected, reloading")
            loadGuardedApps()
            loadSettings()
            prefs.edit().putBoolean(KEY_CACHE_DIRTY, false).apply()
        }

        // Track if user left an active session
        if (activeSession != null && packageName != activeSession && !guardedApps.containsKey(packageName)) {
            Log.d(TAG, "User left $activeSession, clearing session")
            activeSession = null
        }

        lastSeenPackage = packageName

        val guardedApp = guardedApps[packageName]
        if (guardedApp != null) {
            Log.d(TAG, "Guarded app detected: $packageName")
            handleGuardedAppDetected(packageName, guardedApp)
        }
    }

    private fun handleGuardedAppDetected(packageName: String, guardedApp: GuardedApp) {
        // 1. Check debounce/session
        if (shouldSkipOverlay(packageName)) return

        // 2. Check if overlay already showing
        if (overlayManager.isShowing()) {
            Log.d(TAG, "Overlay already showing, ignoring")
            return
        }

        // 3. Check overlay permission
        if (!Settings.canDrawOverlays(this)) {
            Log.w(TAG, "No overlay permission, cannot show intervention")
            return
        }

        // 4. Check snooze
        val snoozeUntil = prefs.getLong(KEY_SNOOZE_UNTIL, 0)
        if (System.currentTimeMillis() < snoozeUntil) {
            Log.d(TAG, "Snoozed until ${snoozeUntil}, skipping")
            return
        }

        // 5. Check schedule
        if (!isWithinSchedule()) {
            Log.d(TAG, "Outside schedule, skipping")
            return
        }

        // 6. Get escalation data (runs DB query)
        serviceScope.launch {
            val escalation = calculateEscalation(packageName)
            showIntervention(packageName, guardedApp.appName, escalation)
        }
    }

    private fun isWithinSchedule(): Boolean {
        val settings = cachedSettings ?: return true // Default to always if not loaded

        return when (settings.scheduleMode) {
            "always" -> true
            "evening" -> {
                val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                hour >= 18 || hour < 7 // 6pm to 7am
            }
            "sabbath" -> {
                val dayOfWeek = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)
                dayOfWeek == Calendar.SUNDAY
            }
            else -> true
        }
    }

    private suspend fun calculateEscalation(packageName: String): EscalationData {
        val app = application as? SelahApplication
        val attemptCount = if (app != null) {
            withContext(Dispatchers.IO) {
                app.interventionRepository.getTodayCountForSource(packageName)
            }
        } else 0

        // attemptNumber is 1-based for display (first attempt = 1)
        val attemptNumber = attemptCount + 1

        // Escalating pause duration
        val pauseDuration = when (attemptCount) {
            0 -> 2   // First time: 2 seconds
            1 -> 5   // Second time: 5 seconds
            2 -> 10  // Third time: 10 seconds
            else -> 15 // Fourth+: 15 seconds
        }

        // Content level based on attempts
        val contentLevel = when (attemptCount) {
            0 -> ContentLevel.BREATH_PRAYER
            1 -> ContentLevel.SCRIPTURE
            2 -> ContentLevel.SCRIPTURE_DEEPER
            else -> ContentLevel.SCRIPTURE_COMPANION
        }

        // Hardcoded content for now - will wire to database later
        val scriptureText = "Create in me a clean heart, O God, and renew a right spirit within me."
        val scriptureRef = "Psalm 51:10"

        val subPromptText = when (contentLevel) {
            ContentLevel.BREATH_PRAYER -> null
            ContentLevel.SCRIPTURE -> "What are you looking for right now?"
            ContentLevel.SCRIPTURE_DEEPER -> "You've returned $attemptNumber times. What is your heart seeking?"
            ContentLevel.SCRIPTURE_COMPANION -> "You've returned $attemptNumber times. What is your heart seeking?"
        }

        val (companionName, companionQuote) = if (contentLevel == ContentLevel.SCRIPTURE_COMPANION) {
            Pair("Thomas Merton", "\"We are not at peace with others because we are not at peace with ourselves.\"")
        } else {
            Pair(null, null)
        }

        Log.d(TAG, "Escalation: attempt=$attemptNumber, pause=${pauseDuration}s, level=$contentLevel")

        return EscalationData(
            attemptNumber = attemptNumber,
            pauseDurationSeconds = pauseDuration,
            contentLevel = contentLevel,
            scriptureText = scriptureText,
            scriptureRef = scriptureRef,
            subPromptText = subPromptText,
            companionName = companionName,
            companionQuote = companionQuote
        )
    }

    private fun shouldSkipOverlay(packageName: String): Boolean {
        val now = System.currentTimeMillis()

        if (packageName == lastOverlayPackage) {
            val timeSinceLastOverlay = now - lastOverlayTime
            if (timeSinceLastOverlay < DEBOUNCE_MS) {
                Log.d(TAG, "Debounced: rapid event")
                return true
            }
        }

        if (packageName == lastDismissedPackage) {
            val timeSinceDismiss = now - lastDismissTime
            if (timeSinceDismiss < DISMISS_GRACE_MS) {
                Log.d(TAG, "In grace period")
                return true
            }
        }

        if (packageName == activeSession) {
            Log.d(TAG, "Active session for $packageName, skipping")
            return true
        }

        return false
    }

    private fun showIntervention(packageName: String, appName: String, escalation: EscalationData) {
        lastOverlayPackage = packageName
        lastOverlayTime = System.currentTimeMillis()

        Log.d(TAG, "Showing intervention for $appName (attempt ${escalation.attemptNumber})")

        overlayManager.showOverlay(
            packageName = packageName,
            appName = appName,
            escalation = escalation,
            onReturnToPrayer = {
                Log.d(TAG, "User chose: Return to prayer")
                overlayManager.hideOverlay()
                lastDismissedPackage = packageName
                lastDismissTime = System.currentTimeMillis()

                // Log intervention
                logIntervention(
                    packageName = packageName,
                    appName = appName,
                    outcome = "resisted",
                    escalation = escalation
                )

                // Launch Selah app with reflection screen
                launchReflectionScreen(escalation)
            },
            onProceed = {
                Log.d(TAG, "User chose: Proceed to $appName")
                overlayManager.hideOverlay()
                lastDismissedPackage = packageName
                lastDismissTime = System.currentTimeMillis()
                activeSession = packageName

                // Log intervention
                logIntervention(
                    packageName = packageName,
                    appName = appName,
                    outcome = "proceeded",
                    escalation = escalation
                )

                Log.d(TAG, "Session started for $packageName")
            }
        )
    }

    private fun launchReflectionScreen(escalation: EscalationData) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(MainActivity.EXTRA_SHOW_REFLECTION, true)
            putExtra(MainActivity.EXTRA_SCRIPTURE_TEXT, escalation.scriptureText)
            putExtra(MainActivity.EXTRA_SCRIPTURE_REF, escalation.scriptureRef)
        }
        startActivity(intent)
        Log.d(TAG, "Launched reflection screen with scripture: ${escalation.scriptureRef}")
    }

    private fun logIntervention(
        packageName: String,
        appName: String,
        outcome: String,
        escalation: EscalationData
    ) {
        serviceScope.launch(Dispatchers.IO) {
            try {
                val app = application as? SelahApplication ?: return@launch

                val intervention = Intervention(
                    timestamp = System.currentTimeMillis(),
                    sourceType = "app",
                    sourceId = packageName,
                    sourceName = appName,
                    outcome = outcome,
                    reason = null, // Will add examination prompt later
                    offeringText = null, // Will add offering prompt later
                    scriptureShown = escalation.scriptureRef,
                    pauseDuration = escalation.pauseDurationSeconds,
                    attemptNumber = escalation.attemptNumber,
                    timeSavedEst = if (outcome == "resisted") 300 else 0 // 5 min estimate
                )

                app.interventionRepository.logIntervention(intervention)
                Log.d(TAG, "Logged intervention: $outcome for $appName")
            } catch (e: Exception) {
                Log.e(TAG, "Error logging intervention", e)
            }
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "AccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayManager.hideOverlay()
        serviceScope.cancel()
        Log.d(TAG, "AccessibilityService destroyed")
    }

    private fun loadGuardedApps() {
        serviceScope.launch(Dispatchers.IO) {
            try {
                val app = application as? SelahApplication ?: return@launch
                val activeApps = app.settingsRepository.getActiveGuardedApps()
                guardedApps = activeApps.associateBy { it.packageName }
                Log.d(TAG, "Loaded ${guardedApps.size} guarded apps")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading guarded apps", e)
            }
        }
    }

    private fun loadSettings() {
        serviceScope.launch(Dispatchers.IO) {
            try {
                val app = application as? SelahApplication ?: return@launch
                cachedSettings = app.settingsRepository.getSettings()
                Log.d(TAG, "Loaded settings: scheduleMode=${cachedSettings?.scheduleMode}")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading settings", e)
            }
        }
    }

    object CacheManager {
        fun markCacheDirty(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putBoolean(KEY_CACHE_DIRTY, true).apply()
            Log.d(TAG, "Cache marked as dirty")
        }

        fun setSnooze(context: Context, untilMillis: Long) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putLong(KEY_SNOOZE_UNTIL, untilMillis).apply()
            Log.d(TAG, "Snooze set until $untilMillis")
        }

        fun clearSnooze(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().remove(KEY_SNOOZE_UNTIL).apply()
            Log.d(TAG, "Snooze cleared")
        }
    }
}
