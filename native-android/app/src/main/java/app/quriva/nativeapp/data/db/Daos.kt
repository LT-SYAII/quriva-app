package app.quriva.nativeapp.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import kotlinx.coroutines.flow.Flow

@Dao
interface ChapterDao {
    @Query("SELECT * FROM chapter_cache WHERE language = :language ORDER BY chapterId")
    suspend fun getChapters(language: String): List<ChapterCacheEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<ChapterCacheEntity>)
}

@Dao
interface VerseDao {
    @Query(
        "SELECT * FROM verse_cache WHERE chapterId = :chapterId AND translationId = :translationId ORDER BY verseNumber"
    )
    suspend fun getVerses(chapterId: Int, translationId: Int): List<VerseCacheEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<VerseCacheEntity>)
}

@Dao
interface BookmarkDao {
    @Query("SELECT * FROM bookmarks ORDER BY createdAt DESC")
    fun observeAll(): Flow<List<BookmarkEntity>>

    @Query("SELECT * FROM bookmarks WHERE surahId = :surahId AND verseId = :verseId LIMIT 1")
    suspend fun find(surahId: Int, verseId: Int): BookmarkEntity?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(entity: BookmarkEntity)

    @Query("DELETE FROM bookmarks WHERE surahId = :surahId AND verseId = :verseId")
    suspend fun delete(surahId: Int, verseId: Int)

    @Transaction
    suspend fun toggle(surahId: Int, verseId: Int) {
        if (find(surahId, verseId) == null) insert(BookmarkEntity(surahId = surahId, verseId = verseId))
        else delete(surahId, verseId)
    }
}

@Dao
interface ProgressDao {
    @Query("SELECT * FROM reading_progress WHERE id = 1")
    fun observe(): Flow<ReadingProgressEntity?>

    @Query("SELECT * FROM reading_progress WHERE id = 1")
    suspend fun get(): ReadingProgressEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(entity: ReadingProgressEntity)
}
