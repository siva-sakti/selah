package com.selah.app

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import androidx.appcompat.app.AppCompatActivity
import com.selah.app.service.SelahAccessibilityService

/**
 * Main entry point for Selah app.
 *
 * This activity handles:
 * - Onboarding flow for new users
 * - Accessibility permission setup
 * - Main app navigation (Today, Journey, Offerings, Settings)
 */
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO: Set up view binding and navigation
        // setContentView(R.layout.activity_main)

        checkAccessibilityPermission()
    }

    /**
     * Check if accessibility service is enabled.
     * If not, guide user to enable it.
     */
    private fun checkAccessibilityPermission() {
        if (!SelahAccessibilityService.isServiceEnabled(this)) {
            // TODO: Show onboarding/permission screen instead of jumping directly to settings
            openAccessibilitySettings()
        }
    }

    /**
     * Open system accessibility settings.
     */
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
}
