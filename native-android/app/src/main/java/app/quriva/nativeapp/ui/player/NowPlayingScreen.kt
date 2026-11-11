package app.quriva.nativeapp.ui.player

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import app.quriva.nativeapp.QurivaApplication
import app.quriva.nativeapp.audio.NowPlaying
import app.quriva.nativeapp.audio.PlaybackController
import app.quriva.nativeapp.audio.PlaybackState
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlin.math.max

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NowPlayingScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val app = context.applicationContext as QurivaApplication
    val scope = rememberCoroutineScope()
    val now by PlaybackState.nowPlaying.collectAsState()
    val isPlaying by PlaybackState.isPlaying.collectAsState()
    val activeVerse by PlaybackState.activeVerse.collectAsState()
    val position by PlaybackState.positionMs.collectAsState()
    val duration by PlaybackState.durationMs.collectAsState()
    val error by PlaybackState.error.collectAsState()
    var scrubbing by remember { mutableStateOf(false) }
    var scrubPos by remember { mutableFloatStateOf(0f) }

    fun playChapter(chapterId: Int) {
        scope.launch {
            try {
                val prefs = app.container.preferences.flow.first()
                val chapters = app.container.repository.getChapters(prefs.appLanguage)
                val ch = chapters.firstOrNull { it.id == chapterId } ?: return@launch
                val timeline = app.container.repository.getChapterAudioTimeline(chapterId, prefs.reciterId)
                val url = timeline.audioUrl ?: return@launch
                PlaybackController.play(
                    context,
                    NowPlaying(
                        chapterId = chapterId,
                        chapterName = ch.nameSimple,
                        audioUrl = url,
                        reciterId = prefs.reciterId,
                        timestamps = timeline.timestamps,
                    ),
                )
            } catch (_: Exception) {}
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Now Playing") },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back") } },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (now == null) {
                Text("Nothing playing", color = MaterialTheme.colorScheme.onSurfaceVariant)
            } else {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(now!!.chapterName, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.SemiBold)
                        Text("Reciter ${now!!.reciterId} · Surah ${now!!.chapterId}", color = MaterialTheme.colorScheme.onSurfaceVariant)
                        if (activeVerse > 0) Text("Highlight: ayah $activeVerse", color = MaterialTheme.colorScheme.primary)
                        if (error != null) Text(error!!, color = MaterialTheme.colorScheme.error)
                    }
                }
                if (duration > 0) {
                    val shown = if (scrubbing) scrubPos.toLong() else position
                    Slider(
                        value = shown.toFloat().coerceIn(0f, duration.toFloat()),
                        onValueChange = { scrubbing = true; scrubPos = it },
                        onValueChangeFinished = {
                            PlaybackController.seekTo(scrubPos.toLong())
                            scrubbing = false
                        },
                        valueRange = 0f..max(1f, duration.toFloat()),
                        modifier = Modifier.fillMaxWidth(),
                    )
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(fmtTime(shown), style = MaterialTheme.typography.bodySmall)
                        Text(fmtTime(duration), style = MaterialTheme.typography.bodySmall)
                    }
                }
                Spacer(Modifier.height(4.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = { val prev = (now!!.chapterId - 1).coerceAtLeast(1); if (prev != now!!.chapterId) playChapter(prev) }) {
                        Icon(Icons.Filled.SkipPrevious, contentDescription = "Previous")
                    }
                    Button(onClick = { PlaybackController.toggle() }) {
                        Icon(if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow, contentDescription = null)
                        Text(if (isPlaying) " Pause" else " Play")
                    }
                    IconButton(onClick = { val next = (now!!.chapterId + 1).coerceAtMost(114); if (next != now!!.chapterId) playChapter(next) }) {
                        Icon(Icons.Filled.SkipNext, contentDescription = "Next")
                    }
                }
                if (error != null) {
                    OutlinedButton(onClick = { PlaybackController.retry(context) }) {
                        Icon(Icons.Filled.Refresh, contentDescription = null)
                        Text(" Retry audio")
                    }
                }
                Button(onClick = { PlaybackController.stop(); onBack() }) {
                    Icon(Icons.Filled.Stop, contentDescription = null)
                    Text(" Stop")
                }
            }
        }
    }
}

private fun fmtTime(ms: Long): String {
    val total = (ms / 1000).coerceAtLeast(0)
    val m = total / 60
    val s = total % 60
    return "%d:%02d".format(m, s)
}
