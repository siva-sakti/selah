package com.selah.app.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "interventions")
data class Intervention(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val timestamp: Long,
    val sourceType: String,
    val sourceId: String,
    val sourceName: String,
    val outcome: String,
    val reason: String?,
    val offeringText: String?,
    val scriptureShown: String,
    val pauseDuration: Int,
    val attemptNumber: Int,
    val timeSavedEst: Int
)
