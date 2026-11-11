package app.quriva.nativeapp.data.repository

import app.quriva.nativeapp.data.api.QuranApi
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.model.toDomain

class QuranRepository(
    private val api: QuranApi = QuranApi.create(),
) {
    suspend fun getChapters(language: String = "en"): List<Chapter> =
        api.chapters(language).chapters.map { it.toDomain() }
}
