package app.quriva.nativeapp.ui.reader

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.model.ChapterAudioTimeline
import app.quriva.nativeapp.data.model.ReaderVerse
import app.quriva.nativeapp.data.preferences.UserPreferencesRepository
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

data class ReaderUiState(
    val loading: Boolean = true,
    val error: String? = null,
    val chapter: Chapter? = null,
    val verses: List<ReaderVerse> = emptyList(),
    val timeline: ChapterAudioTimeline? = null,
    val bookmarkedVerses: Set<Int> = emptySet(),
    val resumeVerse: Int? = null,
)

class ReaderViewModel(
    savedStateHandle: SavedStateHandle,
    private val repository: QuranRepository,
    private val preferences: UserPreferencesRepository,
) : ViewModel() {
    val chapterId: Int = savedStateHandle.get<Int>("chapterId") ?: 1
    val chapterName: String = savedStateHandle.get<String>("chapterName") ?: "Surah"

    private val _uiState = MutableStateFlow(ReaderUiState())
    val uiState: StateFlow<ReaderUiState> = _uiState.asStateFlow()

    init {
        observeBookmarks()
        load()
    }

    private fun observeBookmarks() {
        viewModelScope.launch {
            repository.observeBookmarks().collectLatest { list ->
                val mine = list.filter { it.surahId == chapterId }.map { it.verseId }.toSet()
                _uiState.value = _uiState.value.copy(bookmarkedVerses = mine)
            }
        }
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(loading = true, error = null)
            try {
                val prefs = preferences.flow.first()
                val chaptersDeferred = async { repository.getChapters(prefs.appLanguage) }
                val versesDeferred = async { repository.getReaderVerses(chapterId, prefs.translationId) }
                val timelineDeferred = async {
                    runCatching { repository.getChapterAudioTimeline(chapterId, prefs.reciterId) }.getOrNull()
                }
                val chapter = chaptersDeferred.await().firstOrNull { it.id == chapterId }
                val verses = versesDeferred.await()
                val timeline = timelineDeferred.await()
                val progress = runCatching { repository.getReadingProgress() }.getOrNull()
                val resume = if (progress?.surahId == chapterId && progress.verseId > 1) progress.verseId else null
                _uiState.value = _uiState.value.copy(
                    loading = false,
                    chapter = chapter,
                    verses = verses,
                    timeline = timeline,
                    resumeVerse = resume,
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    loading = false,
                    error = e.message ?: "Could not load surah.",
                )
            }
        }
    }

    fun saveProgress(verseId: Int) {
        viewModelScope.launch {
            runCatching { repository.saveProgress(chapterId, verseId) }
        }
    }

    fun toggleBookmark(verseId: Int) {
        viewModelScope.launch {
            runCatching { repository.toggleBookmark(chapterId, verseId) }
        }
    }

    companion object {
        fun factory(
            repository: QuranRepository,
            preferences: UserPreferencesRepository,
        ): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T =
                    ReaderViewModel(extras.createSavedStateHandle(), repository, preferences) as T
            }
    }
}
