package com.selah.app.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.selah.app.data.model.UserSettings

@Dao
interface UserSettingsDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(settings: UserSettings)

    @Query("SELECT * FROM user_settings WHERE id = 1 LIMIT 1")
    suspend fun get(): UserSettings?

    @Update
    suspend fun update(settings: UserSettings)
}
