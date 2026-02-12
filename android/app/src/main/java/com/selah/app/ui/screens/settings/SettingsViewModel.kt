package com.selah.app.ui.screens.settings

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.selah.app.SelahApplication
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class SettingsState(
    val commitment: String? = null,
    val isLoading: Boolean = true
)

class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val app = application as SelahApplication
    private val settingsRepository = app.settingsRepository

    private val _state = MutableStateFlow(SettingsState())
    val state: StateFlow<SettingsState> = _state.asStateFlow()

    init {
        loadSettings()
    }

    private fun loadSettings() {
        viewModelScope.launch {
            val settings = settingsRepository.getSettings()
            _state.value = SettingsState(
                commitment = settings.personalCommitment,
                isLoading = false
            )
        }
    }

    fun saveCommitment(commitment: String?) {
        viewModelScope.launch {
            settingsRepository.setPersonalCommitment(commitment)
            _state.value = _state.value.copy(commitment = commitment)
        }
    }
}
