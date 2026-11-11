package app.quriva.nativeapp.ui.info

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import app.quriva.nativeapp.data.model.ChapterInfo
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class ChapterInfoUiState(
    val loading: Boolean = true,
    val info: ChapterInfo? = null,
    val error: String? = null,
)

class ChapterInfoViewModel(
    savedStateHandle: SavedStateHandle,
    private val repository: QuranRepository,
) : ViewModel() {
    val chapterId: Int = savedStateHandle.get<Int>("chapterId") ?: 1
    val chapterName: String = savedStateHandle.get<String>("chapterName") ?: "Surah"

    private val _uiState = MutableStateFlow(ChapterInfoUiState())
    val uiState: StateFlow<ChapterInfoUiState> = _uiState.asStateFlow()

    init { load() }

    fun load() {
        viewModelScope.launch {
            _uiState.value = ChapterInfoUiState(loading = true)
            try {
                val info = repository.getChapterInfo(chapterId, "en")
                _uiState.value = ChapterInfoUiState(loading = false, info = info)
            } catch (e: Exception) {
                _uiState.value = ChapterInfoUiState(loading = false, error = e.message ?: "Failed to load info")
            }
        }
    }

    companion object {
        fun factory(repository: QuranRepository): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T =
                    ChapterInfoViewModel(extras.createSavedStateHandle(), repository) as T
            }
    }
}
