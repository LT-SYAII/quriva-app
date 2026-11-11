package app.quriva.nativeapp.ui.info

import android.text.Html
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.quriva.nativeapp.QurivaApplication

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChapterInfoScreen(onBack: () -> Unit) {
    val app = LocalContext.current.applicationContext as QurivaApplication
    val vm: ChapterInfoViewModel = viewModel(factory = ChapterInfoViewModel.factory(app.container.repository))
    val state by vm.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("About ${vm.chapterName}") },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back") } },
            )
        },
    ) { padding ->
        when {
            state.loading -> Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
            state.error != null -> Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) { Text(state.error ?: "Error") }
            else -> LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                item {
                    val info = state.info
                    if (info == null) {
                        Text("No chapter info available.")
                    } else {
                        if (info.shortText.isNotBlank()) {
                            Text("Summary", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                            Text(clean(info.shortText), color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                        if (info.textHtml.isNotBlank()) {
                            Text("Details", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                            Text(clean(info.textHtml))
                        }
                        if (info.source.isNotBlank()) {
                            Text("Source: ${info.source}", style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }
        }
    }
}

private fun clean(html: String): String =
    Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY).toString().replace(Regex("\\s+"), " ").trim()
