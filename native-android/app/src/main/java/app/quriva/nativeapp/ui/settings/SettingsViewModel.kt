package app.quriva.nativeapp.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import app.quriva.nativeapp.data.model.Reciter
import app.quriva.nativeapp.data.model.TranslationResource
import app.quriva.nativeapp.data.preferences.UserPreferences
import app.quriva.nativeapp.data.preferences.UserPreferencesRepository
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class SettingsDataState(
    val reciters: List<Reciter> = emptyList(),
    val translations: List<TranslationResource> = emptyList(),
    val loading: Boolean = true,
    val error: String? = null,
)

class SettingsViewModel(
    private val repository: QuranRepository,
    private val preferences: UserPreferencesRepository,
) : ViewModel() {
    val prefs: StateFlow<UserPreferences> = preferences.flow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), UserPreferences())

    private val _data = MutableStateFlow(SettingsDataState())
    val data: StateFlow<SettingsDataState> = _data.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _data.value = SettingsDataState(loading = true)
            try {
                val reciters = runCatching { repository.getReciters("en") }.getOrDefault(emptyList())
                val translations = runCatching { repository.getTranslationResources("en") }.getOrDefault(emptyList())
                _data.value = SettingsDataState(reciters = reciters, translations = translations, loading = false)
            } catch (e: Exception) {
                _data.value = SettingsDataState(loading = false, error = e.message)
            }
        }
    }

    fun setReciter(id: Int) { viewModelScope.launch { preferences.setReciterId(id) } }
    fun setTranslation(id: Int) { viewModelScope.launch { preferences.setTranslationId(id) } }
    fun setLanguage(lang: String) { viewModelScope.launch { preferences.setAppLanguage(lang) } }

    companion object {
        fun factory(
            repository: QuranRepository,
            preferences: UserPreferencesRepository,
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T =
                SettingsViewModel(repository, preferences) as T
        }
    }
}
