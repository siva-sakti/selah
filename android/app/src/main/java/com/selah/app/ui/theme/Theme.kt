package com.selah.app.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

/**
 * Selah Dark Color Scheme
 *
 * Selah is always dark mode — the deep navy background
 * creates the feeling of a quiet chapel at night.
 */
private val SelahDarkColorScheme = darkColorScheme(
    primary = SelahColors.Primary,
    onPrimary = SelahColors.OnPrimary,
    primaryContainer = SelahColors.SacredGold.copy(alpha = 0.2f),
    onPrimaryContainer = SelahColors.SacredGold,

    secondary = SelahColors.Secondary,
    onSecondary = SelahColors.OnSecondary,
    secondaryContainer = SelahColors.SacredGold.copy(alpha = 0.15f),
    onSecondaryContainer = SelahColors.SacredGold,

    tertiary = SelahColors.WarmCream,
    onTertiary = SelahColors.DeepNavy,

    background = SelahColors.Background,
    onBackground = SelahColors.OnBackground,

    surface = SelahColors.Surface,
    onSurface = SelahColors.OnSurface,
    surfaceVariant = SelahColors.DeepNavy,
    onSurfaceVariant = SelahColors.WarmCream.copy(alpha = 0.7f),

    outline = SelahColors.SacredGold.copy(alpha = 0.3f),
    outlineVariant = SelahColors.SacredGold.copy(alpha = 0.15f),

    inverseSurface = SelahColors.WarmCream,
    inverseOnSurface = SelahColors.DeepNavy,
    inversePrimary = SelahColors.DeepNavy,

    error = SelahColors.SacredGold, // We use gold for errors too — gentle, not alarming
    onError = SelahColors.DeepNavy,
    errorContainer = SelahColors.SacredGold.copy(alpha = 0.2f),
    onErrorContainer = SelahColors.SacredGold,
)

/**
 * Selah Theme
 *
 * The main theme composable for the Selah app.
 * Always uses dark mode with our sacred color palette.
 *
 * @param content The composable content to be themed
 */
@Composable
fun SelahTheme(
    content: @Composable () -> Unit
) {
    val colorScheme = SelahDarkColorScheme
    val view = LocalView.current

    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            // Set status bar color to transparent for edge-to-edge
            window.statusBarColor = SelahColors.DeepNavy.toArgb()
            window.navigationBarColor = SelahColors.DeepNavy.toArgb()
            // Light icons on dark background
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = false
                isAppearanceLightNavigationBars = false
            }
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = SelahMaterialTypography,
        content = content
    )
}
