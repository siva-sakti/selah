package com.selah.app

import android.app.Application
import com.selah.app.data.database.SelahDatabase
import com.selah.app.data.repository.ContentRepository
import com.selah.app.data.repository.InterventionRepository
import com.selah.app.data.repository.SettingsRepository

class SelahApplication : Application() {

    val database: SelahDatabase by lazy {
        SelahDatabase.getInstance(this)
    }

    val contentRepository: ContentRepository by lazy {
        ContentRepository(database.dailyContentDao())
    }

    val interventionRepository: InterventionRepository by lazy {
        InterventionRepository(database.interventionDao())
    }

    val settingsRepository: SettingsRepository by lazy {
        SettingsRepository(
            database.userSettingsDao(),
            database.guardedAppDao(),
            this
        )
    }

    companion object {
        private lateinit var instance: SelahApplication

        fun getInstance(): SelahApplication = instance
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }
}
