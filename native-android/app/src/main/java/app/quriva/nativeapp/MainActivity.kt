package app.quriva.nativeapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.Refresh
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.preferences.UserPreferences
import app.quriva.nativeapp.ui.info.ChapterInfoScreen
import app.quriva.nativeapp.ui.library.LibraryScreen
import app.quriva.nativeapp.ui.player.MiniPlayerBar
import app.quriva.nativeapp.ui.player.AutoNextHandler
import app.quriva.nativeapp.ui.player.NowPlayingScreen
import app.quriva.nativeapp.ui.read.ChaptersUiState
import app.quriva.nativeapp.ui.read.ReadViewModel
import app.quriva.nativeapp.ui.reader.ReaderScreen
import app.quriva.nativeapp.ui.search.SearchScreen
import app.quriva.nativeapp.ui.settings.SettingsScreen
import app.quriva.nativeapp.ui.theme.QurivaNativeTheme
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val app = application as QurivaApplication
            val prefs by app.container.preferences.flow.collectAsState(initial = UserPreferences())
            val dark = when (prefs.themeMode) {
                "dark" -> true
                "light" -> false
                else -> isSystemInDarkTheme()
            }
            QurivaNativeTheme(darkTheme = dark) {
                QurivaNativeApp()
            }
        }
    }
}

private data class Tab(val label: String, val icon: androidx.compose.ui.graphics.vector.ImageVector)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QurivaNativeApp() {
    val navController = rememberNavController()
    AutoNextHandler()

    fun openReader(id: Int, name: String) {
        val encoded = URLEncoder.encode(name, StandardCharsets.UTF_8.toString())
        navController.navigate("reader/$id/$encoded")
    }

    val bg = Brush.verticalGradient(
        listOf(
            MaterialTheme.colorScheme.background,
            MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f),
            MaterialTheme.colorScheme.background,
        )
    )
    Box(modifier = Modifier.fillMaxSize().background(bg)) {
    NavHost(navController = navController, startDestination = "home") {
        composable("home") {
            HomeScreen(
                onOpenChapter = { chapter -> openReader(chapter.id, chapter.nameSimple) },
                onSearch = { navController.navigate("search") },
                onSettings = { navController.navigate("settings") },
                onOpenNowPlaying = { navController.navigate("nowplaying") },
            )
        }
        composable(
            route = "reader/{chapterId}/{chapterName}",
            arguments = listOf(
                navArgument("chapterId") { type = NavType.IntType },
                navArgument("chapterName") { type = NavType.StringType },
            ),
        ) {
            ReaderScreen(
                onBack = { navController.popBackStack() },
                onInfo = { id, name ->
                    val encoded = java.net.URLEncoder.encode(name, java.nio.charset.StandardCharsets.UTF_8.toString())
                    navController.navigate("info/$id/$encoded")
                },
            )
        }
        composable(
            route = "info/{chapterId}/{chapterName}",
            arguments = listOf(
                navArgument("chapterId") { type = NavType.IntType },
                navArgument("chapterName") { type = NavType.StringType },
            ),
        ) {
            ChapterInfoScreen(onBack = { navController.popBackStack() })
        }
        composable("search") {
            SearchScreen(
                onBack = { navController.popBackStack() },
                onOpen = { id, _ -> openReader(id, "Surah $id") },
            )
        }
        composable("settings") {
            SettingsScreen(onBack = { navController.popBackStack() })
        }
        composable("nowplaying") {
            NowPlayingScreen(onBack = { navController.popBackStack() })
        }
    }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HomeScreen(
    onOpenChapter: (Chapter) -> Unit,
    onSearch: () -> Unit,
    onSettings: () -> Unit,
    onOpenNowPlaying: () -> Unit,
) {
    val tabs = listOf(
        Tab("Read", Icons.AutoMirrored.Outlined.MenuBook),
        Tab("Library", Icons.Outlined.BookmarkBorder),
        Tab("Settings", Icons.Outlined.Settings),
    )
    var selected by rememberSaveable { mutableIntStateOf(0) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Quriva", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                        Text("Native Kotlin", style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                },
                actions = {
                    IconButton(onClick = onSearch) { Icon(Icons.Outlined.Search, contentDescription = "Search") }
                    IconButton(onClick = onSettings) { Icon(Icons.Outlined.Settings, contentDescription = "Settings") }
                },
            )
        },
        bottomBar = {
            Column {
                MiniPlayerBar(onOpen = onOpenNowPlaying)
                NavigationBar {
                    tabs.forEachIndexed { index, tab ->
                        NavigationBarItem(
                            selected = selected == index,
                            onClick = { selected = index },
                            icon = { Icon(tab.icon, contentDescription = tab.label) },
                            label = { Text(tab.label) },
                        )
                    }
                }
            }
        },
    ) { padding ->
        when (selected) {
            0 -> ReadScreen(modifier = Modifier.padding(padding), onOpenChapter = onOpenChapter)
            1 -> LibraryScreen(
                modifier = Modifier.padding(padding),
                onOpen = { surahId -> onOpenChapter(Chapter(surahId, "Surah $surahId", "", "", 0, "")) },
            )
            else -> SettingsScreen(onBack = null)
        }
    }
}

@Composable
private fun ReadScreen(
    modifier: Modifier = Modifier,
    onOpenChapter: (Chapter) -> Unit,
) {
    val app = LocalContext.current.applicationContext as QurivaApplication
    val viewModel: ReadViewModel = viewModel(factory = ReadViewModel.factory(app.container.repository))
    val prefs by app.container.preferences.flow.collectAsState(initial = UserPreferences())
    androidx.compose.runtime.LaunchedEffect(prefs.appLanguage) { viewModel.load(prefs.appLanguage) }
    val state by viewModel.uiState.collectAsState()
    when (val s = state) {
        is ChaptersUiState.Loading -> Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
        is ChaptersUiState.Error -> Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(24.dp)) {
                Text("Could not load surahs", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(6.dp))
                Text(s.message, textAlign = TextAlign.Center, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(12.dp))
                Button(onClick = { viewModel.load() }) {
                    Icon(Icons.Outlined.Refresh, contentDescription = null)
                    Spacer(Modifier.padding(horizontal = 4.dp))
                    Text("Retry")
                }
            }
        }
        is ChaptersUiState.Success -> SurahList(
            modifier = modifier,
            chapters = s.chapters,
            onOpenChapter = onOpenChapter,
            onRefresh = { viewModel.load() },
        )
    }
}

@Composable
private fun SurahList(
    modifier: Modifier = Modifier,
    chapters: List<Chapter>,
    onOpenChapter: (Chapter) -> Unit,
    onRefresh: () -> Unit,
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        item {
            Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Native Kotlin port", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                    Text(
                        "Loaded ${chapters.size} surahs. Reader, synced audio highlight, bookmarks/progress, search, and settings are available in native code. Remaining: chapter info, full background media service/notification, and polish.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
        items(chapters, key = { it.id }) { chapter ->
            Card(modifier = Modifier.fillMaxWidth().clickable { onOpenChapter(chapter) }) {
                Row(
                    modifier = Modifier.padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Text(chapter.id.toString(), style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Column(modifier = Modifier.weight(1f)) {
                        Text(chapter.nameSimple, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                        Text("${chapter.revelationLabel} · ${chapter.versesCount} ayat · ${chapter.translatedName}",
                            style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    Text(chapter.nameArabic, style = MaterialTheme.typography.titleMedium)
                }
            }
        }
        item {
            Spacer(Modifier.height(8.dp))
            Button(onClick = onRefresh, modifier = Modifier.fillMaxWidth()) { Text("Refresh") }
        }
    }
}
