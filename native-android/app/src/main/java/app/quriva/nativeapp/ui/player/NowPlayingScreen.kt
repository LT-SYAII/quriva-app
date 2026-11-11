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
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import app.quriva.nativeapp.audio.PlaybackController
import app.quriva.nativeapp.audio.PlaybackState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NowPlayingScreen(onBack: () -> Unit) {
    val now by PlaybackState.nowPlaying.collectAsState()
    val isPlaying by PlaybackState.isPlaying.collectAsState()
    val activeVerse by PlaybackState.activeVerse.collectAsState()

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
                    }
                }
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    Button(onClick = { PlaybackController.toggle() }) {
                        Icon(if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow, contentDescription = null)
                        Text(if (isPlaying) " Pause" else " Play")
                    }
                    Button(onClick = { PlaybackController.stop(); onBack() }) {
                        Icon(Icons.Filled.Stop, contentDescription = null)
                        Text(" Stop")
                    }
                }
            }
        }
    }
}
