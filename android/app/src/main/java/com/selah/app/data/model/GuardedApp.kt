package com.selah.app.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "guarded_apps")
data class GuardedApp(
    @PrimaryKey
    val packageName: String,
    val appName: String,
    val isActive: Boolean,
    val addedAt: Long
)
