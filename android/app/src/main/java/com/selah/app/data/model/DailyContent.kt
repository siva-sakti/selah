package com.selah.app.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "daily_content")
data class DailyContent(
    @PrimaryKey
    val id: Int,
    val season: String,
    val dayInSeason: Int?,
    val liturgicalLabel: String?,
    val scriptureRef: String,
    val scriptureText: String,
    val breathPrayer: String,
    val reflection: String,
    val companionName: String?,
    val companionQuote: String?
)
