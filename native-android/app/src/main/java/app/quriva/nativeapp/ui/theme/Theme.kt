package app.quriva.nativeapp.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColors = darkColorScheme(
    primary = Color.White,
    onPrimary = Color(0xFF050505),
    background = Color(0xFF050505),
    onBackground = Color.White,
    surface = Color(0xFF0E0E0F),
    onSurface = Color.White,
    surfaceVariant = Color(0xFF161618),
    onSurfaceVariant = Color(0xFFB7B7B7),
)

private val LightColors = lightColorScheme(
    primary = Color(0xFF0A0A0A),
    onPrimary = Color.White,
    background = Color(0xFFFAFAFA),
    onBackground = Color(0xFF0A0A0A),
    surface = Color.White,
    onSurface = Color(0xFF0A0A0A),
    surfaceVariant = Color(0xFFF0F0F0),
    onSurfaceVariant = Color(0xFF4A4A4A),
)

@Composable
fun QurivaNativeTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        content = content,
    )
}
