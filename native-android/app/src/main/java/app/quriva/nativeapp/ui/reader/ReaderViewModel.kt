package app.quriva.nativeapp.ui.reader

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.model.ChapterAudioTimeline
import app.quriva.nativeapp.data.model.ReaderVerse
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class ReaderUiState(
    val loading: Boolean = true,
    val error: String? = null,
    val chapter: Chapter? = null,
    val verses: List<ReaderVerse> = emptyList(),
    val timeline: ChapterAudioTimeline? = null,
)

class ReaderViewModel(
    savedStateHandle: SavedStateHandle,
    private val repository: QuranRepository = QuranRepository(),
) : ViewModel() {
    val chapterId: Int = savedStateHandle.get<Int>("chapterId") ?: 1
    val chapterName: String = savedStateHandle.get<String>("chapterName") ?: "Surah"

    private val _uiState = MutableStateFlow(ReaderUiState())
    val uiState: StateFlow<ReaderUiState> = _uiState.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = ReaderUiState(loading = true)
            try {
                val chaptersDeferred = async { repository.getChapters("en") }
                val versesDeferred = async { repository.getReaderVerses(chapterId, 20) }
                val timelineDeferred = async {
                    runCatching { repository.getChapterAudioTimeline(chapterId, 7) }.getOrNull()
                }
                val chapter = chaptersDeferred.await().firstOrNull { it.id == chapterId }
                val verses = versesDeferred.await()
                val timeline = timelineDeferred.await()
                _uiState.value = ReaderUiState(
                    loading = false,
                    chapter = chapter,
                    verses = verses,
                    timeline = timeline,
                )
            } catch (e: Exception) {
                _uiState.value = ReaderUiState(
                    loading = false,
                    error = e.message ?: "Could not load surah.",
                )
            }
        }
    }
}
