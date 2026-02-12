package com.selah.app.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_settings")
data class UserSettings(
    @PrimaryKey
    val id: Int = 1,
    val tradition: String = "exploring",
    val language: String = "en",
    val scheduleMode: String = "always",
    val customStart: String? = null,
    val customEnd: String? = null,
    val customDays: String? = null,
    val isPremium: Boolean = false,
    val armorLocked: Boolean = false,
    val armorLockUntil: String? = null,
    val frictionStartSec: Int = 5,
    val notificationsMorning: Boolean = false,
    val notificationsMidday: Boolean = false,
    val notificationsEvening: Boolean = false,
    val notificationsCelebration: Boolean = false,
    val notificationsWeekly: Boolean = true,
    val onboardingComplete: Boolean = false,
    val personalCommitment: String? = null
)
