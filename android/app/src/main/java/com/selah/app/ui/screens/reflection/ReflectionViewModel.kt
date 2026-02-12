package com.selah.app.ui.screens.reflection

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.selah.app.SelahApplication
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class ReflectionViewModel(application: Application) : AndroidViewModel(application) {

    private val app = application as SelahApplication
    private val settingsRepository = app.settingsRepository

    private val _commitment = MutableStateFlow<String?>(null)
    val commitment: StateFlow<String?> = _commitment.asStateFlow()

    init {
        loadCommitment()
    }

    private fun loadCommitment() {
        viewModelScope.launch {
            val settings = settingsRepository.getSettings()
            _commitment.value = settings.personalCommitment
        }
    }
}
