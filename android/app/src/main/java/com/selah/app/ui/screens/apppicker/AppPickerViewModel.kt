package com.selah.app.ui.screens.apppicker

import android.app.Application
import android.content.Intent
import android.content.pm.PackageManager
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.selah.app.SelahApplication
import com.selah.app.data.model.AppInfo
import com.selah.app.data.model.GuardedApp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

data class AppPickerState(
    val suggestedApps: List<AppInfo> = emptyList(),
    val otherApps: List<AppInfo> = emptyList(),
    val selectedPackages: Set<String> = emptySet(),
    val isPremium: Boolean = false,
    val maxApps: Int = 3,
    val isLoading: Boolean = true,
    val isSaving: Boolean = false,
    val showLimitDialog: Boolean = false
) {
    val canSelectMore: Boolean
        get() = isPremium || selectedPackages.size < maxApps

    val selectionCount: String
        get() = if (isPremium) "${selectedPackages.size}" else "${selectedPackages.size}/$maxApps"

    val isOverLimit: Boolean
        get() = !isPremium && selectedPackages.size > maxApps
}

class AppPickerViewModel(application: Application) : AndroidViewModel(application) {

    companion object {
        private val SUGGESTED_PACKAGES = setOf(
            // Video/Streaming
            "com.google.android.youtube",
            "com.netflix.mediaclient",
            "com.hulu.plus",
            "tv.twitch.android.app",
            // Social Media
            "com.instagram.android",
            "com.zhiliaoapp.musically", // TikTok
            "com.ss.android.ugc.trill", // TikTok alternative package
            "com.twitter.android",
            "com.facebook.katana",
            "com.facebook.orca", // Messenger
            "com.reddit.frontpage",
            "com.snapchat.android",
            "com.pinterest",
            "com.linkedin.android",
            "com.discord",
            "com.whatsapp",
            "org.telegram.messenger",
            // Games (common time sinks)
            "com.king.candycrushsaga",
            "com.supercell.clashofclans",
            // News/Browsing
            "com.google.android.apps.magazines", // Google News
            "com.apple.news"
        )

        private val OWN_PACKAGE = "com.selah.app"
    }

    private val app = application as SelahApplication
    private val settingsRepository = app.settingsRepository
    private val packageManager = application.packageManager

    private val _state = MutableStateFlow(AppPickerState())
    val state: StateFlow<AppPickerState> = _state.asStateFlow()

    init {
        loadApps()
    }

    private fun loadApps() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)

            // Load settings and current guarded apps
            val settings = settingsRepository.getSettings()
            val guardedApps = settingsRepository.getGuardedApps()

            // Get installed apps
            val installedApps = withContext(Dispatchers.IO) {
                getInstalledApps()
            }

            val installedPackages = installedApps.map { it.packageName }.toSet()

            // Only count selected apps that are actually installed
            val selectedPackages = guardedApps
                .map { it.packageName }
                .filter { it in installedPackages }
                .toSet()

            // Split into suggested and other
            val suggested = installedApps.filter { it.isSuggested }
            val other = installedApps.filter { !it.isSuggested }

            _state.value = AppPickerState(
                suggestedApps = suggested,
                otherApps = other,
                selectedPackages = selectedPackages,
                isPremium = settings.isPremium,
                maxApps = 3,
                isLoading = false
            )
        }
    }

    private fun getInstalledApps(): List<AppInfo> {
        // Get all installed packages
        val installedPackages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        // Filter to launchable apps only
        val launchableApps = installedPackages.filter { appInfo ->
            appInfo.packageName != OWN_PACKAGE &&
                packageManager.getLaunchIntentForPackage(appInfo.packageName) != null
        }

        return launchableApps.map { appInfo ->
            AppInfo(
                packageName = appInfo.packageName,
                appName = packageManager.getApplicationLabel(appInfo).toString(),
                icon = try {
                    packageManager.getApplicationIcon(appInfo.packageName)
                } catch (e: Exception) {
                    null
                },
                isSuggested = appInfo.packageName in SUGGESTED_PACKAGES
            )
        }
        .sortedWith(compareBy({ !it.isSuggested }, { it.appName.lowercase() }))
        .distinctBy { it.packageName }
    }

    fun toggleApp(packageName: String, appName: String) {
        val currentState = _state.value
        val isCurrentlySelected = packageName in currentState.selectedPackages

        if (isCurrentlySelected) {
            // Always allow deselection
            _state.value = currentState.copy(
                selectedPackages = currentState.selectedPackages - packageName
            )
        } else {
            // Allow selection regardless of limit - we'll check on save
            _state.value = currentState.copy(
                selectedPackages = currentState.selectedPackages + packageName
            )
        }
    }

    /**
     * Refresh the app list (call when screen becomes visible again)
     */
    fun refreshApps() {
        loadApps()
    }

    fun saveSelections(onComplete: () -> Unit, onShowPremium: () -> Unit) {
        val currentState = _state.value

        // Check if over limit for non-premium users
        if (!currentState.isPremium && currentState.selectedPackages.size > currentState.maxApps) {
            _state.value = currentState.copy(showLimitDialog = true)
            return
        }

        viewModelScope.launch {
            _state.value = _state.value.copy(isSaving = true)

            val allApps = currentState.suggestedApps + currentState.otherApps
            val appNameMap = allApps.associate { it.packageName to it.appName }

            val guardedApps = currentState.selectedPackages.map { packageName ->
                GuardedApp(
                    packageName = packageName,
                    appName = appNameMap[packageName] ?: packageName,
                    isActive = true,
                    addedAt = System.currentTimeMillis()
                )
            }

            settingsRepository.setGuardedApps(guardedApps)

            _state.value = _state.value.copy(isSaving = false)
            onComplete()
        }
    }

    fun dismissLimitDialog() {
        _state.value = _state.value.copy(showLimitDialog = false)
    }

    fun isSelected(packageName: String): Boolean {
        return packageName in _state.value.selectedPackages
    }
}
