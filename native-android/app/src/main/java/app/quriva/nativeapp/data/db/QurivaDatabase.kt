package app.quriva.nativeapp.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [
        ChapterCacheEntity::class,
        VerseCacheEntity::class,
        BookmarkEntity::class,
        ReadingProgressEntity::class,
    ],
    version = 1,
    exportSchema = false,
)
abstract class QurivaDatabase : RoomDatabase() {
    abstract fun chapterDao(): ChapterDao
    abstract fun verseDao(): VerseDao
    abstract fun bookmarkDao(): BookmarkDao
    abstract fun progressDao(): ProgressDao

    companion object {
        @Volatile private var INSTANCE: QurivaDatabase? = null

        fun get(context: Context): QurivaDatabase = INSTANCE ?: synchronized(this) {
            INSTANCE ?: Room.databaseBuilder(
                context.applicationContext,
                QurivaDatabase::class.java,
                "quriva_native.db",
            ).build().also { INSTANCE = it }
        }
    }
}
