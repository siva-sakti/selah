package com.selah.app.data.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.selah.app.data.model.DailyContent
import com.selah.app.data.model.GuardedApp
import com.selah.app.data.model.Intervention
import com.selah.app.data.model.UserSettings

@Database(
    entities = [
        DailyContent::class,
        GuardedApp::class,
        Intervention::class,
        UserSettings::class
    ],
    version = 2,
    exportSchema = false
)
abstract class SelahDatabase : RoomDatabase() {

    abstract fun dailyContentDao(): DailyContentDao
    abstract fun guardedAppDao(): GuardedAppDao
    abstract fun interventionDao(): InterventionDao
    abstract fun userSettingsDao(): UserSettingsDao

    companion object {
        @Volatile
        private var INSTANCE: SelahDatabase? = null

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE user_settings ADD COLUMN personalCommitment TEXT")
            }
        }

        fun getInstance(context: Context): SelahDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    SelahDatabase::class.java,
                    "selah_database"
                )
                    .addMigrations(MIGRATION_1_2)
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
