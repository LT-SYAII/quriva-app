package app.quriva.nativeapp.audio

import app.quriva.nativeapp.data.model.AyahTimestamp
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class NowPlaying(
    val chapterId: Int = 0,
    val chapterName: String = "",
    val audioUrl: String = "",
    val reciterId: Int = 7,
    val timestamps: List<AyahTimestamp> = emptyList(),
)

object PlaybackState {
    private val _nowPlaying = MutableStateFlow<NowPlaying?>(null)
    val nowPlaying: StateFlow<NowPlaying?> = _nowPlaying.asStateFlow()

    private val _isPlaying = MutableStateFlow(false)
    val isPlaying: StateFlow<Boolean> = _isPlaying.asStateFlow()

    private val _positionMs = MutableStateFlow(0L)
    val positionMs: StateFlow<Long> = _positionMs.asStateFlow()

    private val _activeVerse = MutableStateFlow(-1)
    val activeVerse: StateFlow<Int> = _activeVerse.asStateFlow()

    fun updateNowPlaying(np: NowPlaying?) { _nowPlaying.value = np }
    fun updatePlaying(playing: Boolean) { _isPlaying.value = playing }
    fun updatePosition(pos: Long) { _positionMs.value = pos }
    fun updateActiveVerse(v: Int) { _activeVerse.value = v }
}
