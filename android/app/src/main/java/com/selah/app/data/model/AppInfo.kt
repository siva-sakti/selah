package com.selah.app.data.model

import android.graphics.drawable.Drawable

/**
 * Represents an installed app that can be selected for guarding.
 */
data class AppInfo(
    val packageName: String,
    val appName: String,
    val icon: Drawable?,
    val isSuggested: Boolean = false
)
