package com.selah.app.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.selah.app.data.model.DailyContent

@Dao
interface DailyContentDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(contents: List<DailyContent>)

    @Query("SELECT * FROM daily_content WHERE season = :season AND dayInSeason = :dayInSeason LIMIT 1")
    suspend fun getBySeasonAndDay(season: String, dayInSeason: Int): DailyContent?

    @Query("SELECT * FROM daily_content WHERE id = :id LIMIT 1")
    suspend fun getById(id: Int): DailyContent?
}
