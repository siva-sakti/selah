package com.selah.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.tooling.preview.Preview
import com.selah.app.ui.navigation.OnboardingScreen
import com.selah.app.ui.navigation.SelahNavigation
import com.selah.app.ui.theme.SelahTheme

/**
 * Main entry point for Selah app.
 *
 * This activity handles:
 * - Onboarding flow for new users
 * - Accessibility permission setup
 * - Main app navigation (Today, Journey, Offerings, Settings)
 * - Deep linking to reflection screen from intervention overlay
 */
class MainActivity : ComponentActivity() {

    companion object {
        private const val PREFS_NAME = "selah_prefs"
        private const val KEY_ONBOARDING_COMPLETE = "onboarding_complete"

        // Intent extras for reflection screen
        const val EXTRA_SHOW_REFLECTION = "show_reflection"
        const val EXTRA_SCRIPTURE_TEXT = "scripture_text"
        const val EXTRA_SCRIPTURE_REF = "scripture_ref"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // Check if onboarding is complete
        // TODO: Set to false when building real onboarding
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Hardcode to true for now so we can see the tabs
        if (!prefs.contains(KEY_ONBOARDING_COMPLETE)) {
            prefs.edit().putBoolean(KEY_ONBOARDING_COMPLETE, true).apply()
        }

        val onboardingComplete = prefs.getBoolean(KEY_ONBOARDING_COMPLETE, false)

        // Check for reflection intent extras
        val showReflection = intent.getBooleanExtra(EXTRA_SHOW_REFLECTION, false)
        val scriptureText = intent.getStringExtra(EXTRA_SCRIPTURE_TEXT)
        val scriptureRef = intent.getStringExtra(EXTRA_SCRIPTURE_REF)

        setContent {
            SelahTheme {
                SelahApp(
                    onboardingComplete = onboardingComplete,
                    showReflection = showReflection,
                    scriptureText = scriptureText,
                    scriptureRef = scriptureRef
                )
            }
        }
    }
}

/**
 * Root composable that decides between onboarding and main navigation.
 */
@Composable
fun SelahApp(
    onboardingComplete: Boolean,
    showReflection: Boolean = false,
    scriptureText: String? = null,
    scriptureRef: String? = null
) {
    if (onboardingComplete) {
        SelahNavigation(
            showReflection = showReflection,
            scriptureText = scriptureText,
            scriptureRef = scriptureRef
        )
    } else {
        OnboardingScreen()
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF1B2340)
@Composable
fun SelahAppPreview() {
    SelahTheme {
        SelahNavigation()
    }
}
