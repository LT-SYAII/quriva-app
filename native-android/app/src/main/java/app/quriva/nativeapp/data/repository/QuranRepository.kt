package app.quriva.nativeapp.data.repository

import app.quriva.nativeapp.data.api.QuranApi
import app.quriva.nativeapp.data.db.BookmarkEntity
import app.quriva.nativeapp.data.db.ChapterCacheEntity
import app.quriva.nativeapp.data.db.QurivaDatabase
import app.quriva.nativeapp.data.db.ReadingProgressEntity
import app.quriva.nativeapp.data.db.VerseCacheEntity
import app.quriva.nativeapp.data.model.Chapter
import app.quriva.nativeapp.data.model.ChapterAudioTimeline
import app.quriva.nativeapp.data.model.ReaderVerse
import app.quriva.nativeapp.data.model.toDomain
import app.quriva.nativeapp.data.model.toReaderVerse
import kotlinx.coroutines.flow.Flow

class QuranRepository(
    private val api: QuranApi,
    private val database: QurivaDatabase,
) {
    private val chapterDao = database.chapterDao()
    private val verseDao = database.verseDao()
    private val bookmarkDao = database.bookmarkDao()
    private val progressDao = database.progressDao()

    suspend fun getChapters(language: String = "en"): List<Chapter> {
        val cached = chapterDao.getChapters(language)
        if (cached.isNotEmpty()) {
            return cached.map {
                Chapter(
                    id = it.chapterId,
                    nameSimple = it.nameSimple,
                    nameArabic = it.nameArabic,
                    revelationPlace = it.revelationPlace,
                    versesCount = it.versesCount,
                    translatedName = it.translatedName,
                )
            }
        }
        val remote = api.chapters(language).chapters.map { it.toDomain() }
        chapterDao.upsertAll(
            remote.map {
                ChapterCacheEntity(
                    language = language,
                    chapterId = it.id,
                    nameSimple = it.nameSimple,
                    nameArabic = it.nameArabic,
                    revelationPlace = it.revelationPlace,
                    versesCount = it.versesCount,
                    translatedName = it.translatedName,
                )
            },
        )
        return remote
    }

    suspend fun getReaderVerses(
        chapterId: Int,
        translationId: Int = 20,
    ): List<ReaderVerse> {
        val cached = verseDao.getVerses(chapterId, translationId)
        if (cached.isNotEmpty()) {
            return cached.map {
                ReaderVerse(
                    chapterId = it.chapterId,
                    number = it.verseNumber,
                    arabic = it.arabic,
                    translation = it.translation,
                )
            }
        }
        val arabic = api.versesUthmani(chapterId).verses
        val translations = runCatching {
            api.translations(translationId, chapterId).translations.map { it.text }
        }.getOrDefault(emptyList())
        val verses = arabic.mapIndexed { index, dto ->
            dto.toReaderVerse(chapterId, translations.getOrNull(index).orEmpty())
        }
        verseDao.upsertAll(
            verses.map {
                VerseCacheEntity(
                    chapterId = it.chapterId,
                    verseNumber = it.number,
                    translationId = translationId,
                    arabic = it.arabic,
                    translation = it.translation,
                )
            },
        )
        return verses
    }

    suspend fun getChapterAudioTimeline(
        chapterId: Int,
        reciterId: Int = 7,
    ): ChapterAudioTimeline {
        val file = api.chapterRecitation(reciterId, chapterId, segments = true).audioFile
        return file?.toDomain() ?: ChapterAudioTimeline(null, emptyList())
    }

    fun observeBookmarks(): Flow<List<BookmarkEntity>> = bookmarkDao.observeAll()

    suspend fun toggleBookmark(surahId: Int, verseId: Int) =
        bookmarkDao.toggle(surahId, verseId)

    fun observeProgress(): Flow<ReadingProgressEntity?> = progressDao.observe()

    suspend fun saveProgress(surahId: Int, verseId: Int) =
        progressDao.upsert(ReadingProgressEntity(surahId = surahId, verseId = verseId))

    suspend fun getCachedChapters(language: String): List<Chapter> =
        chapterDao.getChapters(language).map {
            Chapter(
                id = it.chapterId,
                nameSimple = it.nameSimple,
                nameArabic = it.nameArabic,
                revelationPlace = it.revelationPlace,
                versesCount = it.versesCount,
                translatedName = it.translatedName,
            )
        }
}
