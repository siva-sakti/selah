package com.selah.app.data.repository

import com.selah.app.data.database.InterventionDao
import com.selah.app.data.model.Intervention
import java.util.Calendar

/**
 * Stats for today's interventions
 */
data class TodayStats(
    val guardedCount: Int,
    val resistedCount: Int,
    val timeReclaimedSeconds: Int
)

class InterventionRepository(
    private val interventionDao: InterventionDao
) {

    suspend fun logIntervention(intervention: Intervention): Long {
        return interventionDao.insert(intervention)
    }

    suspend fun getTodayStats(): TodayStats {
        val (startOfDay, endOfDay) = getTodayBounds()
        val todayInterventions = interventionDao.getForDate(startOfDay, endOfDay)
        val resistedInterventions = todayInterventions.filter { it.outcome == "resisted" }

        return TodayStats(
            guardedCount = todayInterventions.size,
            resistedCount = resistedInterventions.size,
            timeReclaimedSeconds = resistedInterventions.sumOf { it.timeSavedEst }
        )
    }

    suspend fun getOfferings(startDate: Long, endDate: Long): List<Intervention> {
        return interventionDao.getForDateRange(startDate, endDate)
            .filter { it.outcome == "resisted" && !it.offeringText.isNullOrBlank() }
    }

    suspend fun getTodayCountForSource(sourceId: String): Int {
        val (startOfDay, _) = getTodayBounds()
        return interventionDao.getTodayCountForSource(sourceId, startOfDay)
    }

    suspend fun getTodayInterventions(): List<Intervention> {
        val (startOfDay, endOfDay) = getTodayBounds()
        return interventionDao.getForDate(startOfDay, endOfDay)
    }

    private fun getTodayBounds(): Pair<Long, Long> {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startOfDay = calendar.timeInMillis

        calendar.add(Calendar.DAY_OF_YEAR, 1)
        val endOfDay = calendar.timeInMillis

        return Pair(startOfDay, endOfDay)
    }
}
