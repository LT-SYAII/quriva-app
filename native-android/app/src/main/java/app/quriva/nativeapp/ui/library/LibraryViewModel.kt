package app.quriva.nativeapp.ui.library

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import app.quriva.nativeapp.data.db.BookmarkEntity
import app.quriva.nativeapp.data.db.ReadingProgressEntity
import app.quriva.nativeapp.data.repository.QuranRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class LibraryViewModel(private val repository: QuranRepository) : ViewModel() {
    val bookmarks: StateFlow<List<BookmarkEntity>> =
        repository.observeBookmarks().stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val progress: StateFlow<ReadingProgressEntity?> =
        repository.observeProgress().stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    fun removeBookmark(surahId: Int, verseId: Int) {
        viewModelScope.launch { repository.toggleBookmark(surahId, verseId) }
    }

    companion object {
        fun factory(repository: QuranRepository): ViewModelProvider.Factory =
            object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T =
                    LibraryViewModel(repository) as T
            }
    }
}
