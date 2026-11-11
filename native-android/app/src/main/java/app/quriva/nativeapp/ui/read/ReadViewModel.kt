package app.quriva.nativeapp.ui.read

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface ChaptersUiState {
    data object Loading : ChaptersUiState
    data class Success(val chapters: List<Chapter>) : ChaptersUiState
    data class Error(val message: String) : ChaptersUiState
}

class ReadViewModel(
    private val repository: QuranRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow<ChaptersUiState>(ChaptersUiState.Loading)
    val uiState: StateFlow<ChaptersUiState> = _uiState.asStateFlow()

    init {
        load()
    }

    fun load(language: String = "en") {
        viewModelScope.launch {
            _uiState.value = ChaptersUiState.Loading
            try {
                _uiState.value = ChaptersUiState.Success(repository.getChapters(language))
            } catch (e: Exception) {
                val cached = runCatching { repository.getCachedChapters(language) }.getOrDefault(emptyList())
                _uiState.value = if (cached.isNotEmpty()) {
                    ChaptersUiState.Success(cached)
                } else {
                    ChaptersUiState.Error(e.message ?: "Could not load chapters. Check your connection.")
                }
            }
        }
    }

    companion object {
        fun factory(repository: QuranRepository): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    ReadViewModel(repository) as T
            }
    }
}
