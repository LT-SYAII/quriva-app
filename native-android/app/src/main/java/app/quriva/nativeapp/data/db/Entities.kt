package app.quriva.nativeapp.data.db

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "chapter_cache",
    primaryKeys = ["language", "chapterId"],
)
data class ChapterCacheEntity(
    val language: String,
    val chapterId: Int,
    val nameSimple: String,
    val nameArabic: String,
    val revelationPlace: String,
    val versesCount: Int,
    val translatedName: String,
)

@Entity(
    tableName = "verse_cache",
    primaryKeys = ["chapterId", "verseNumber", "translationId"],
)
data class VerseCacheEntity(
    val chapterId: Int,
    val verseNumber: Int,
    val translationId: Int,
    val arabic: String,
    val translation: String,
)

@Entity(
    tableName = "bookmarks",
    indices = [Index(value = ["surahId", "verseId"], unique = true)],
)
data class BookmarkEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val surahId: Int,
    val verseId: Int,
    val createdAt: Long = System.currentTimeMillis(),
)

@Entity(tableName = "reading_progress")
data class ReadingProgressEntity(
    @PrimaryKey val id: Int = 1,
    val surahId: Int,
    val verseId: Int,
    val updatedAt: Long = System.currentTimeMillis(),
)
