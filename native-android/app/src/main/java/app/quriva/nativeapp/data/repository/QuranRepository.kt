package app.quriva.nativeapp.data.repository

import app.quriva.nativeapp.data.api.QuranApi
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.model.ChapterAudioTimeline
import app.quriva.nativeapp.data.model.ReaderVerse
import app.quriva.nativeapp.data.model.toDomain
import app.quriva.nativeapp.data.model.toReaderVerse

class QuranRepository(
    private val api: QuranApi = QuranApi.create(),
) {
    suspend fun getChapters(language: String = "en"): List<Chapter> =
        api.chapters(language).chapters.map { it.toDomain() }

    suspend fun getReaderVerses(
        chapterId: Int,
        translationId: Int = 20,
    ): List<ReaderVerse> {
        val arabic = api.versesUthmani(chapterId).verses
        val translations = runCatching {
            api.translations(translationId, chapterId).translations.map { it.text }
        }.getOrDefault(emptyList())
        return arabic.mapIndexed { index, dto ->
            val translation = translations.getOrNull(index).orEmpty()
            dto.toReaderVerse(chapterId, translation)
        }
    }

    suspend fun getChapterAudioTimeline(
        chapterId: Int,
        reciterId: Int = 7,
    ): ChapterAudioTimeline {
        val file = api.chapterRecitation(reciterId, chapterId, segments = true).audioFile
        return file?.toDomain() ?: ChapterAudioTimeline(null, emptyList())
    }
}
