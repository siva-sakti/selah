package com.selah.app.ui.theme

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Selah Spacing System
 *
 * Consistent spacing values based on an 4dp grid.
 * Generous negative space is key to the design —
 * let the Word breathe.
 */
object SelahSpacing {
    val xxs: Dp = 4.dp
    val xs: Dp = 8.dp
    val sm: Dp = 12.dp
    val md: Dp = 16.dp
    val lg: Dp = 24.dp
    val xl: Dp = 32.dp
    val xxl: Dp = 48.dp
    val xxxl: Dp = 64.dp

    // Semantic spacing
    val buttonPaddingHorizontal: Dp = 32.dp
    val buttonPaddingVertical: Dp = 16.dp
    val cardPadding: Dp = 16.dp
    val screenPadding: Dp = 24.dp
    val sectionSpacing: Dp = 32.dp

    // Overlay specific
    val overlayTopPadding: Dp = 48.dp
    val overlayBottomPadding: Dp = 24.dp
    val overlayCrossSize: Dp = 56.dp
}
