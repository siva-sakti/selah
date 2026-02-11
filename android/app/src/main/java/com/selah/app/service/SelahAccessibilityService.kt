package com.selah.app.service

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import android.view.accessibility.AccessibilityEvent

/**
 * AccessibilityService that detects when user opens guarded apps.
 *
 * This service:
 * - Listens for TYPE_WINDOW_STATE_CHANGED events
 * - Checks package names against the guarded apps list
 * - Shows intervention overlay when a guarded app is detected
 *
 * Unlike the Flutter implementation, this runs directly in Android
 * with no bridge complexity - events are received immediately.
 */
class SelahAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "SelahAccessibility"

        // Common social media apps that can be guarded
        val COMMON_APPS = mapOf(
            "com.instagram.android" to "Instagram",
            "com.zhiliaoapp.musically" to "TikTok",
            "com.google.android.youtube" to "YouTube",
            "com.twitter.android" to "Twitter",
            "com.reddit.frontpage" to "Reddit",
            "com.facebook.katana" to "Facebook",
            "com.snapchat.android" to "Snapchat",
            "com.pinterest" to "Pinterest"
        )

        /**
         * Check if this accessibility service is enabled in system settings.
         */
        fun isServiceEnabled(context: Context): Boolean {
            val serviceName = "${context.packageName}/${SelahAccessibilityService::class.java.canonicalName}"
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            return enabledServices.split(':').any { service ->
                service.equals(serviceName, ignoreCase = true)
            }
        }
    }

    // Set of currently guarded app package names
    private val guardedApps = mutableSetOf<String>()

    // Track if overlay is showing to prevent duplicate triggers
    private var overlayShowing = false

    // Last package that triggered overlay
    private var lastTriggeredPackage: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AccessibilityService connected")

        // TODO: Load guarded apps from database
        // For now, hardcode test apps
        guardedApps.addAll(listOf(
            "com.instagram.android",
            "com.zhiliaoapp.musically",
            "com.google.android.youtube"
        ))

        Log.d(TAG, "Guarded apps: $guardedApps")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val packageName = event.packageName?.toString() ?: return

        // Ignore events from our own app
        if (packageName == "com.selah.app") return

        // Reset tracking when user leaves guarded app for non-guarded app
        if (lastTriggeredPackage != null &&
            packageName != lastTriggeredPackage &&
            !guardedApps.contains(packageName)
        ) {
            Log.d(TAG, "User left guarded app, resetting overlay tracking")
            overlayShowing = false
            lastTriggeredPackage = null
        }

        // Check if this is a guarded app
        if (guardedApps.contains(packageName) && !overlayShowing) {
            Log.d(TAG, "GUARDED APP DETECTED: $packageName")
            lastTriggeredPackage = packageName
            showInterventionOverlay(packageName)
        }
    }

    /**
     * Show the intervention overlay.
     */
    private fun showInterventionOverlay(packageName: String) {
        if (overlayShowing) {
            Log.d(TAG, "Overlay already showing, skipping")
            return
        }

        overlayShowing = true
        Log.d(TAG, "Showing intervention overlay for $packageName")

        // TODO: Implement overlay using WindowManager
        // This is where native Android shines - direct WindowManager access
        // without the Flutter-to-native bridge complexity
    }

    /**
     * Called when overlay is dismissed.
     */
    fun onOverlayDismissed() {
        overlayShowing = false
        lastTriggeredPackage = null
        Log.d(TAG, "Overlay dismissed")
    }

    override fun onInterrupt() {
        Log.d(TAG, "AccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AccessibilityService destroyed")
    }
}
