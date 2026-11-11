package app.quriva.nativeapp

import android.app.Application
import app.quriva.nativeapp.data.api.QuranApi
import app.quriva.nativeapp.data.db.QurivaDatabase
import app.quriva.nativeapp.data.preferences.UserPreferencesRepository
import app.quriva.nativeapp.data.repository.QuranRepository

class QurivaApplication : Application() {
    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        container = AppContainer(this)
    }
}

class AppContainer(app: Application) {
    private val api = QuranApi.create()
    private val database = QurivaDatabase.get(app)
    val preferences = UserPreferencesRepository(app)
    val repository = QuranRepository(api = api, database = database)
}
