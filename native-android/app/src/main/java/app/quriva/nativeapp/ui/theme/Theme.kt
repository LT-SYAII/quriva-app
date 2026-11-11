package app.quriva.nativeapp.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColors = darkColorScheme(
    primary = Color(0xFFF5F5F5),
    onPrimary = Color(0xFF050505),
    secondary = Color(0xFFBDBDBD),
    onSecondary = Color(0xFF0A0A0A),
    background = Color(0xFF050505),
    onBackground = Color(0xFFF2F2F2),
    surface = Color(0xFF101012),
    onSurface = Color(0xFFF2F2F2),
    surfaceVariant = Color(0xFF1A1B1E),
    onSurfaceVariant = Color(0xFFB8B8B8),
    outline = Color(0x33FFFFFF),
)

private val LightColors = lightColorScheme(
    primary = Color(0xFF111111),
    onPrimary = Color.White,
    secondary = Color(0xFF444444),
    onSecondary = Color.White,
    background = Color(0xFFF7F7F7),
    onBackground = Color(0xFF101010),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF101010),
    surfaceVariant = Color(0xFFEDEDED),
    onSurfaceVariant = Color(0xFF4A4A4A),
    outline = Color(0x22000000),
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
