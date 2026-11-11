package app.quriva.nativeapp.ui.player

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import app.quriva.nativeapp.QurivaApplication
import app.quriva.nativeapp.audio.NowPlaying
import app.quriva.nativeapp.audio.PlaybackController
import app.quriva.nativeapp.audio.PlaybackState
import kotlinx.coroutines.flow.first

@Composable
fun AutoNextHandler() {
    val context = LocalContext.current
    val app = context.applicationContext as QurivaApplication
    val ended by PlaybackState.endedChapterId.collectAsState()
    LaunchedEffect(ended) {
        val chapterId = ended ?: return@LaunchedEffect
        PlaybackState.consumeEnded()
        val nextId = chapterId + 1
        if (nextId > 114) return@LaunchedEffect
        try {
            val prefs = app.container.preferences.flow.first()
            val chapters = app.container.repository.getChapters(prefs.appLanguage)
            val next = chapters.firstOrNull { it.id == nextId } ?: return@LaunchedEffect
            val timeline = app.container.repository.getChapterAudioTimeline(nextId, prefs.reciterId)
            val url = timeline.audioUrl ?: return@LaunchedEffect
            PlaybackController.play(
                context,
                NowPlaying(
                    chapterId = nextId,
                    chapterName = next.nameSimple,
                    audioUrl = url,
                    reciterId = prefs.reciterId,
                    timestamps = timeline.timestamps,
                ),
            )
        } catch (_: Exception) {
        }
    }
}
