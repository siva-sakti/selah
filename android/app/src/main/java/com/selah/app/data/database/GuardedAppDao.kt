package com.selah.app.data.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.selah.app.data.model.GuardedApp
import kotlinx.coroutines.flow.Flow

@Dao
interface GuardedAppDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(app: GuardedApp)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(apps: List<GuardedApp>)

    @Query("SELECT * FROM guarded_apps")
    suspend fun getAll(): List<GuardedApp>

    @Query("SELECT * FROM guarded_apps")
    fun getAllFlow(): Flow<List<GuardedApp>>

    @Query("SELECT * FROM guarded_apps WHERE isActive = 1")
    suspend fun getActiveApps(): List<GuardedApp>

    @Query("SELECT * FROM guarded_apps WHERE packageName = :packageName LIMIT 1")
    suspend fun getByPackage(packageName: String): GuardedApp?

    @Update
    suspend fun update(app: GuardedApp)

    @Delete
    suspend fun delete(app: GuardedApp)

    @Query("DELETE FROM guarded_apps WHERE packageName = :packageName")
    suspend fun deleteByPackage(packageName: String)
}
