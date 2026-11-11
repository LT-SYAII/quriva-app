package app.quriva.nativeapp.ui.settings

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
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.quriva.nativeapp.QurivaApplication

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(onBack: (() -> Unit)? = null) {
    val app = LocalContext.current.applicationContext as QurivaApplication
    val vm: SettingsViewModel = viewModel(
        factory = SettingsViewModel.factory(app.container.repository, app.container.preferences),
    )
    val prefs by vm.prefs.collectAsState()
    val data by vm.data.collectAsState()
    var showReciters by remember { mutableStateOf(false) }
    var showTranslations by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    if (onBack != null) {
                        IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back") }
                    }
                },
            )
        },
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("App", fontWeight = FontWeight.SemiBold)
                        Text("Language", style = MaterialTheme.typography.labelLarge)
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            listOf("en" to "English", "id" to "Indonesia").forEach { (code, label) ->
                                FilterChip(
                                    selected = prefs.appLanguage == code,
                                    onClick = { vm.setLanguage(code) },
                                    label = { Text(label) },
                                )
                            }
                        }
                        Text("Theme", style = MaterialTheme.typography.labelLarge)
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            listOf("system", "light", "dark").forEach { mode ->
                                FilterChip(
                                    selected = prefs.themeMode == mode,
                                    onClick = { vm.setTheme(mode) },
                                    label = { Text(mode.replaceFirstChar { it.uppercase() }) },
                                )
                            }
                        }
                        Text(
                            "Theme/language changes may apply on next screen open; playback uses current prefs.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("Selected", fontWeight = FontWeight.SemiBold)
                        Text("Translation: ${prefs.translationId} · Reciter: ${prefs.reciterId}",
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
            if (data.loading) {
                item { CircularProgressIndicator() }
            } else {
                item {
                    Card(modifier = Modifier.fillMaxWidth().clickable { showReciters = !showReciters }) {
                        Column(Modifier.padding(14.dp)) {
                            Text("Reciter", fontWeight = FontWeight.SemiBold)
                            Text(if (showReciters) "Tap a reciter to select" else "Tap to choose reciter",
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
                if (showReciters) {
                    items(data.reciters.take(40)) { r ->
                        Row(
                            modifier = Modifier.fillMaxWidth().clickable { vm.setReciter(r.id) }.padding(vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            RadioButton(selected = prefs.reciterId == r.id, onClick = { vm.setReciter(r.id) })
                            Column {
                                Text(r.name)
                                if (!r.style.isNullOrBlank()) Text(r.style!!, style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
                item { Spacer(Modifier.height(4.dp)) }
                item {
                    Card(modifier = Modifier.fillMaxWidth().clickable { showTranslations = !showTranslations }) {
                        Column(Modifier.padding(14.dp)) {
                            Text("Translation", fontWeight = FontWeight.SemiBold)
                            Text(if (showTranslations) "Tap a translation to select" else "Tap to choose translation",
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
                if (showTranslations) {
                    items(data.translations.take(50)) { t ->
                        Row(
                            modifier = Modifier.fillMaxWidth().clickable { vm.setTranslation(t.id) }.padding(vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            RadioButton(selected = prefs.translationId == t.id, onClick = { vm.setTranslation(t.id) })
                            Column(Modifier.weight(1f)) {
                                Text(t.name)
                                Text("${t.authorName} · ${t.languageName}", style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
            }
        }
    }
}
