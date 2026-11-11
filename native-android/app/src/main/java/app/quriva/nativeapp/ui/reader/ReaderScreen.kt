package app.quriva.nativeapp.ui.reader

import android.text.Html
import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import app.quriva.nativeapp.QurivaApplication
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReaderScreen(
    onBack: () -> Unit,
) {
    val context = LocalContext.current
    val app = context.applicationContext as QurivaApplication
    val viewModel: ReaderViewModel = viewModel(
        factory = ReaderViewModel.factory(app.container.repository),
    )
    val state by viewModel.uiState.collectAsState()

    val audioUrl = state.timeline?.audioUrl
    val timestamps = state.timeline?.timestamps.orEmpty()

    val player = remember(audioUrl) {
        if (audioUrl.isNullOrBlank()) null else ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(audioUrl))
            prepare()
        }
    }
    var isPlaying by remember(player) { mutableStateOf(false) }
    var activeVerse by remember(player) { mutableIntStateOf(-1) }

    DisposableEffect(player) {
        val listener = object : Player.Listener {
            override fun onIsPlayingChanged(playing: Boolean) {
                isPlaying = playing
            }
        }
        player?.addListener(listener)
        onDispose {
            player?.removeListener(listener)
            player?.release()
        }
    }

    LaunchedEffect(player, timestamps) {
        if (player == null || timestamps.isEmpty()) return@LaunchedEffect
        while (isActive) {
            val pos = player.currentPosition.toInt()
            val match = timestamps.firstOrNull { pos >= it.fromMs && pos <= it.toMs }
            activeVerse = match?.verseNumber ?: -1
            delay(250)
        }
    }

    val listState = rememberLazyListState()
    LaunchedEffect(activeVerse, state.verses) {
        if (activeVerse > 0) {
            viewModel.saveProgress(activeVerse)
            val index = state.verses.indexOfFirst { it.number == activeVerse }
            if (index >= 0) {
                listState.animateScrollToItem((index + 1).coerceAtLeast(0))
            }
        }
    }

    LaunchedEffect(state.verses) {
        if (state.verses.isNotEmpty()) {
            viewModel.saveProgress(state.verses.first().number)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            state.chapter?.nameSimple ?: viewModel.chapterName,
                            fontWeight = FontWeight.SemiBold,
                        )
                        val sub = state.chapter?.translatedName
                        if (!sub.isNullOrBlank()) {
                            Text(
                                sub,
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    if (player != null) {
                        IconButton(onClick = {
                            if (player.isPlaying) player.pause() else player.play()
                        }) {
                            Icon(
                                if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                                contentDescription = if (isPlaying) "Pause" else "Play",
                            )
                        }
                    }
                },
            )
        },
    ) { padding ->
        when {
            state.loading -> Box(
                Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentAlignment = Alignment.Center,
            ) { CircularProgressIndicator() }

            state.error != null -> Box(
                Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(state.error ?: "Error", textAlign = TextAlign.Center)
                    Spacer(Modifier.height(12.dp))
                    Button(onClick = { viewModel.load() }) {
                        Icon(Icons.Filled.Refresh, contentDescription = null)
                        Spacer(Modifier.padding(horizontal = 4.dp))
                        Text("Retry")
                    }
                }
            }

            else -> LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                state = listState,
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                item {
                    ReaderHeader(
                        arabicName = state.chapter?.nameArabic.orEmpty(),
                        meta = buildString {
                            val c = state.chapter
                            if (c != null) {
                                append(c.revelationLabel)
                                append(" · ")
                                append(c.versesCount)
                                append(" ayat")
                            }
                            if (player != null) append(" · Audio ready")
                            if (timestamps.isNotEmpty()) append(" · Highlight synced")
                        },
                    )
                }
                itemsIndexed(state.verses, key = { _, v -> v.key }) { _, verse ->
                    VerseCard(
                        verse = verse,
                        active = verse.number == activeVerse && activeVerse > 0,
                        bookmarked = state.bookmarkedVerses.contains(verse.number),
                        onToggleBookmark = { viewModel.toggleBookmark(verse.number) },
                    )
                }
            }
        }
    }
}

@Composable
private fun ReaderHeader(arabicName: String, meta: String) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
        ),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (arabicName.isNotBlank()) {
                Text(
                    arabicName,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Spacer(Modifier.height(4.dp))
            }
            if (meta.isNotBlank()) {
                Text(
                    meta,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}

@Composable
private fun VerseCard(
    verse: ReaderVerse,
    active: Boolean,
    bookmarked: Boolean,
    onToggleBookmark: () -> Unit,
) {
    val bg by animateColorAsState(
        if (active) MaterialTheme.colorScheme.primary.copy(alpha = 0.10f)
        else MaterialTheme.colorScheme.surface,
        label = "verse-bg",
    )
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = bg),
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    verse.number.toString(),
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontWeight = FontWeight.Bold,
                )
                Spacer(Modifier.weight(1f))
                IconButton(onClick = onToggleBookmark) {
                    Icon(
                        if (bookmarked) Icons.Filled.Bookmark else Icons.Filled.BookmarkBorder,
                        contentDescription = if (bookmarked) "Remove bookmark" else "Bookmark",
                    )
                }
            }
            Text(
                verse.arabic,
                style = MaterialTheme.typography.titleLarge,
                textAlign = TextAlign.End,
                modifier = Modifier.fillMaxWidth(),
            )
            val translation = cleanText(verse.translation)
            if (translation.isNotBlank()) {
                Text(
                    translation,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

private fun cleanText(html: String): String {
    if (html.isBlank()) return ""
    return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY)
        .toString()
        .replace(Regex("\\s+"), " ")
        .trim()
}
