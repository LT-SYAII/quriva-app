package app.quriva.nativeapp.ui.player

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import app.quriva.nativeapp.audio.PlaybackController
import app.quriva.nativeapp.audio.PlaybackState

@Composable
fun MiniPlayerBar(onOpen: () -> Unit, modifier: Modifier = Modifier) {
    val now by PlaybackState.nowPlaying.collectAsState()
    val isPlaying by PlaybackState.isPlaying.collectAsState()
    val activeVerse by PlaybackState.activeVerse.collectAsState()
    val n = now ?: return
    Surface(modifier = modifier.fillMaxWidth(), tonalElevation = 3.dp, shadowElevation = 4.dp) {
        Row(
            modifier = Modifier.clickable(onClick = onOpen).padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Column(Modifier.weight(1f)) {
                Text(n.chapterName, fontWeight = FontWeight.SemiBold, maxLines = 1)
                val sub = if (activeVerse > 0) "Ayah $activeVerse" else "Playing"
                Text(sub, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            IconButton(onClick = { PlaybackController.toggle() }) {
                Icon(if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow, contentDescription = if (isPlaying) "Pause" else "Play")
            }
        }
    }
}
