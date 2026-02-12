package com.selah.app.data.repository

import com.selah.app.data.database.DailyContentDao
import com.selah.app.data.model.DailyContent

class ContentRepository(
    private val dailyContentDao: DailyContentDao
) {

    suspend fun getTodayContent(tradition: String, season: String, dayNumber: Int): DailyContent? {
        // For now, just get by season and day
        // Tradition filtering will be added when we have content per tradition
        return dailyContentDao.getBySeasonAndDay(season, dayNumber)
    }

    suspend fun seedContent(contents: List<DailyContent>) {
        dailyContentDao.insertAll(contents)
    }

    suspend fun getContentById(id: Int): DailyContent? {
        return dailyContentDao.getById(id)
    }
}
