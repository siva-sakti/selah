package com.selah.app.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.selah.app.R

/**
 * Selah Typography
 *
 * Cormorant Garamond for Scripture and reflections — warm, literary, sacred.
 * System sans-serif for UI elements — clean, modern, readable.
 *
 * Together: ancient wisdom, contemporary delivery.
 */

// Cormorant Garamond font family
val CormorantGaramond = FontFamily(
    Font(R.font.cormorant_garamond_regular, FontWeight.Normal),
    Font(R.font.cormorant_garamond_bold, FontWeight.Bold),
    Font(R.font.cormorant_garamond_italic, FontWeight.Normal, FontStyle.Italic)
)

/**
 * Custom text styles for Selah-specific use cases
 */
object SelahTypography {
    // Scripture display — large, gold, Cormorant
    val scriptureDisplay = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 24.sp,
        lineHeight = 34.sp,
        letterSpacing = 0.sp,
        color = SelahColors.SacredGold
    )

    // Scripture reference — smaller, italic
    val scriptureReference = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontStyle = FontStyle.Italic,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.sp,
        color = SelahColors.SacredGold.copy(alpha = 0.8f)
    )

    // Reflection — italic, Cormorant
    val reflection = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontStyle = FontStyle.Italic,
        fontSize = 18.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp,
        color = SelahColors.WarmCream.copy(alpha = 0.9f)
    )

    // Breath prayer — Cormorant, centered
    val breathPrayer = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 20.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.5.sp,
        color = SelahColors.SacredGold
    )

    // Heading — sans-serif, bold
    val heading = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 20.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp,
        color = SelahColors.WarmCream
    )

    // Body — sans-serif, regular
    val body = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.sp,
        color = SelahColors.WarmCream
    )

    // Button label — sans-serif, medium weight
    val buttonLabel = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )

    // Small text — for metadata, attempt counters
    val caption = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.sp,
        color = SelahColors.SubduedGray
    )

    // Navigation label
    val navLabel = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.sp
    )
}

// Material3 Typography using our font families
val SelahMaterialTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp
    ),
    displayMedium = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp
    ),
    displaySmall = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp
    ),
    headlineLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp
    ),
    headlineSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp
    ),
    titleSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp
    ),
    bodySmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    )
)
