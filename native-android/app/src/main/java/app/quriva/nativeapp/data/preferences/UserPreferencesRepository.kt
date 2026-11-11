package app.quriva.nativeapp.data.preferences

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "quriva_prefs")

data class UserPreferences(
    val appLanguage: String = "en",
    val translationId: Int = 20,
    val reciterId: Int = 7,
    val themeMode: String = "system",
)

class UserPreferencesRepository(private val context: Context) {
    private object Keys {
        val APP_LANGUAGE = stringPreferencesKey("app_language")
        val TRANSLATION_ID = intPreferencesKey("translation_id")
        val RECITER_ID = intPreferencesKey("reciter_id")
        val THEME_MODE = stringPreferencesKey("theme_mode")
    }

    val flow: Flow<UserPreferences> = context.dataStore.data.map { prefs ->
        UserPreferences(
            appLanguage = prefs[Keys.APP_LANGUAGE] ?: "en",
            translationId = prefs[Keys.TRANSLATION_ID] ?: 20,
            reciterId = prefs[Keys.RECITER_ID] ?: 7,
            themeMode = prefs[Keys.THEME_MODE] ?: "system",
        )
    }

    suspend fun setTranslationId(id: Int) {
        context.dataStore.edit { it[Keys.TRANSLATION_ID] = id }
    }

    suspend fun setReciterId(id: Int) {
        context.dataStore.edit { it[Keys.RECITER_ID] = id }
    }

    suspend fun setAppLanguage(language: String) {
        context.dataStore.edit { it[Keys.APP_LANGUAGE] = language }
    }

    suspend fun setThemeMode(mode: String) {
        context.dataStore.edit { it[Keys.THEME_MODE] = mode }
    }
}
