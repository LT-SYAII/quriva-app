package app.quriva.nativeapp.ui.library

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DeleteOutline
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.quriva.nativeapp.QurivaApplication

@Composable
fun LibraryScreen(
    modifier: Modifier = Modifier,
    onOpen: (surahId: Int) -> Unit,
) {
    val app = LocalContext.current.applicationContext as QurivaApplication
    val vm: LibraryViewModel = viewModel(factory = LibraryViewModel.factory(app.container.repository))
    val bookmarks by vm.bookmarks.collectAsState()
    val progress by vm.progress.collectAsState()

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        item {
            Text("Library", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
            Text(
                "Bookmarks and reading progress (stored locally).",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(8.dp))
        }

        item {
            Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                Column(Modifier.padding(14.dp)) {
                    Text("Continue reading", fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(4.dp))
                    if (progress == null) {
                        Text("No reading progress yet.", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    } else {
                        Text(
                            "Surah ${progress!!.surahId} · Ayah ${progress!!.verseId}",
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onOpen(progress!!.surahId) }
                                .padding(vertical = 6.dp),
                            style = MaterialTheme.typography.bodyLarge,
                        )
                    }
                }
            }
        }

        item {
            Spacer(Modifier.height(4.dp))
            Text("Bookmarks", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
        }

        if (bookmarks.isEmpty()) {
            item {
                Text(
                    "No bookmarks yet. Tap the bookmark icon on an ayah in the reader.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        } else {
            items(bookmarks, key = { it.id }) { b ->
                Card(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier
                            .clickable { onOpen(b.surahId) }
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text("Surah ${b.surahId} · Ayah ${b.verseId}", fontWeight = FontWeight.SemiBold)
                            Text(
                                "Saved bookmark",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                        IconButton(onClick = { vm.removeBookmark(b.surahId, b.verseId) }) {
                            Icon(Icons.Filled.DeleteOutline, contentDescription = "Remove")
                        }
                    }
                }
            }
        }
    }
}
