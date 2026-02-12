package com.selah.app.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * Selah Brand Colors
 *
 * A sacred, contemplative palette inspired by candlelit chapels
 * and medieval manuscripts. Navy represents the quiet of night prayer,
 * gold the divine light, cream the aged parchment of Scripture.
 */
object SelahColors {
    // Primary palette
    val DeepNavy = Color(0xFF1B2340)
    val SacredGold = Color(0xFFC9A84C)
    val WarmCream = Color(0xFFF5F0E8)

    // Supporting colors
    val Charcoal = Color(0xFF2D2D2D)
    val SubduedGray = Color(0xFF666666)

    // Semantic aliases
    val Background = DeepNavy
    val Surface = DeepNavy
    val Primary = SacredGold
    val OnPrimary = DeepNavy
    val OnBackground = WarmCream
    val OnSurface = WarmCream
    val Secondary = SacredGold
    val OnSecondary = DeepNavy

    // Special use
    val ScriptureText = SacredGold
    val ButtonPrimary = SacredGold
    val ButtonSecondary = SubduedGray
    val Divider = SacredGold.copy(alpha = 0.2f)
}
