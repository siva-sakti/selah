package com.selah.app.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.selah.app.data.model.Intervention

@Dao
interface InterventionDao {

    @Insert
    suspend fun insert(intervention: Intervention): Long

    @Query("SELECT * FROM interventions WHERE timestamp >= :startOfDay AND timestamp < :endOfDay")
    suspend fun getForDate(startOfDay: Long, endOfDay: Long): List<Intervention>

    @Query("SELECT COUNT(*) FROM interventions WHERE sourceId = :sourceId AND timestamp >= :startOfDay")
    suspend fun getTodayCountForSource(sourceId: String, startOfDay: Long): Int

    @Query("SELECT * FROM interventions WHERE outcome = 'resisted' AND timestamp >= :startOfDay AND timestamp < :endOfDay")
    suspend fun getAllResisted(startOfDay: Long, endOfDay: Long): List<Intervention>

    @Query("SELECT * FROM interventions WHERE timestamp >= :start AND timestamp < :end ORDER BY timestamp DESC")
    suspend fun getForDateRange(start: Long, end: Long): List<Intervention>
}
