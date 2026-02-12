package com.selah.app.data.repository

import android.content.Context
import com.selah.app.data.database.GuardedAppDao
import com.selah.app.data.database.UserSettingsDao
import com.selah.app.data.model.GuardedApp
import com.selah.app.data.model.UserSettings
import com.selah.app.service.SelahAccessibilityService
import kotlinx.coroutines.flow.Flow

class SettingsRepository(
    private val userSettingsDao: UserSettingsDao,
    private val guardedAppDao: GuardedAppDao,
    private val context: Context? = null
) {

    suspend fun getSettings(): UserSettings {
        return userSettingsDao.get() ?: UserSettings().also {
            userSettingsDao.insert(it)
        }
    }

    suspend fun updateSettings(settings: UserSettings) {
        userSettingsDao.update(settings)
    }

    fun getGuardedAppsFlow(): Flow<List<GuardedApp>> {
        return guardedAppDao.getAllFlow()
    }

    suspend fun getGuardedApps(): List<GuardedApp> {
        return guardedAppDao.getAll()
    }

    suspend fun getActiveGuardedApps(): List<GuardedApp> {
        return guardedAppDao.getActiveApps()
    }

    suspend fun addGuardedApp(app: GuardedApp) {
        guardedAppDao.insert(app)
    }

    suspend fun removeGuardedApp(packageName: String) {
        guardedAppDao.deleteByPackage(packageName)
    }

    suspend fun updateGuardedApp(app: GuardedApp) {
        guardedAppDao.update(app)
    }

    suspend fun getGuardedApp(packageName: String): GuardedApp? {
        return guardedAppDao.getByPackage(packageName)
    }

    /**
     * Replace all guarded apps with the given list.
     * Marks cache dirty so AccessibilityService reloads.
     */
    suspend fun setGuardedApps(apps: List<GuardedApp>) {
        // Get current apps to find removals
        val currentApps = guardedAppDao.getAll()
        val newPackages = apps.map { it.packageName }.toSet()

        // Remove apps no longer in list
        currentApps.forEach { current ->
            if (current.packageName !in newPackages) {
                guardedAppDao.deleteByPackage(current.packageName)
            }
        }

        // Insert/update new apps
        guardedAppDao.insertAll(apps)

        // Mark cache dirty for AccessibilityService
        context?.let {
            SelahAccessibilityService.CacheManager.markCacheDirty(it)
        }
    }

    /**
     * Toggle a single app's guarded status and mark cache dirty.
     */
    suspend fun toggleGuardedApp(packageName: String, appName: String, isActive: Boolean) {
        val existing = guardedAppDao.getByPackage(packageName)
        if (existing != null) {
            if (isActive) {
                guardedAppDao.update(existing.copy(isActive = true))
            } else {
                guardedAppDao.deleteByPackage(packageName)
            }
        } else if (isActive) {
            guardedAppDao.insert(
                GuardedApp(
                    packageName = packageName,
                    appName = appName,
                    isActive = true,
                    addedAt = System.currentTimeMillis()
                )
            )
        }

        // Mark cache dirty
        context?.let {
            SelahAccessibilityService.CacheManager.markCacheDirty(it)
        }
    }

    /**
     * Update just the personal commitment message.
     */
    suspend fun setPersonalCommitment(commitment: String?) {
        val settings = getSettings()
        userSettingsDao.update(settings.copy(personalCommitment = commitment))
    }
}
