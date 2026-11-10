import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class Bookmarks extends Table {
  IntColumn get surahId => integer()();
  IntColumn get verseId => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {surahId, verseId};
}

class ReadingProgress extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get surahId => integer()();
  IntColumn get verseId => integer()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cache for chapter metadata, keyed by the UI language used to fetch it.
class ChapterCache extends Table {
  TextColumn get language => text()();
  IntColumn get chapterId => integer()();
  TextColumn get nameSimple => text()();
  TextColumn get nameArabic => text()();
  TextColumn get revelationPlace => text()();
  IntColumn get versesCount => integer()();
  TextColumn get translatedName => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {language, chapterId};
}

/// Cache for individual verses: Arabic Uthmani text plus one translation.
class VerseCache extends Table {
  IntColumn get chapterId => integer()();
  IntColumn get verseNumber => integer()();
  IntColumn get translationId => integer()();
  TextColumn get arabic => text()();
  TextColumn get translation => text().withDefault(const Constant(''))();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {chapterId, translationId};
}

class ChapterInfoCache extends Table {
  IntColumn get chapterId => integer()();
  TextColumn get language => text()();
  TextColumn get shortText => text()();
  TextColumn get textHtml => text()();
  TextColumn get source => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {chapterId, language};
}

class AudioUrlCache extends Table {
  IntColumn get chapterId => integer()();
  IntColumn get recitationId => integer()();
  TextColumn get audioUrl => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {chapterId, recitationId};
}

@DriftDatabase(
  tables: [
    Bookmarks,
    ReadingProgress,
    ChapterCache,
    VerseCache,
    ChapterInfoCache,
    AudioUrlCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? driftDatabase(name: 'quriva'));

  @override
  int get schemaVersion => 2;

  // ---------------------------------------------------------------------------
  // Bookmarks
  // ---------------------------------------------------------------------------

  Stream<List<Bookmark>> watchBookmarks() =>
      (select(bookmarks)..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
          .watch();

  Future<void> toggleBookmark(int surahId, int verseId) async {
    final existing = await (select(bookmarks)
          ..where((row) =>
              row.surahId.equals(surahId) & row.verseId.equals(verseId)))
        .getSingleOrNull();
    if (existing == null) {
      await into(bookmarks).insert(
        BookmarksCompanion.insert(surahId: surahId, verseId: verseId),
      );
    } else {
      await (delete(bookmarks)
            ..where((row) =>
                row.surahId.equals(surahId) & row.verseId.equals(verseId)))
          .go();
    }
  }

  // ---------------------------------------------------------------------------
  // Reading progress
  // ---------------------------------------------------------------------------

  Future<void> saveProgress(int surahId, int verseId) =>
      into(readingProgress).insertOnConflictUpdate(
        ReadingProgressCompanion.insert(
          id: const Value(1),
          surahId: surahId,
          verseId: verseId,
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<ReadingProgressData?> loadProgress() => (select(readingProgress)
        ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
      .getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Content caches
  // ---------------------------------------------------------------------------

  Future<List<ChapterCacheData>> getCachedChapters(String language) =>
      (select(chapterCache)
            ..where((row) => row.language.equals(language))
            ..orderBy([(row) => OrderingTerm.asc(row.chapterId)]))
          .get();

  Future<void> insertCachedChapters(List<ChapterCacheCompanion> rows) =>
      batch((store) {
        store.insertAll(chapterCache, rows, mode: InsertMode.insertOrReplace);
      });

  Future<List<VerseCacheData>?> getCachedVerses(
    int chapterId,
    int translationId,
  ) async {
    final rows = await (select(verseCache)
          ..where((row) =>
              row.chapterId.equals(chapterId) &
              row.translationId.equals(translationId))
          ..orderBy([(row) => OrderingTerm.asc(row.verseNumber)]))
        .get();
    return rows.isEmpty ? null : rows;
  }

  Future<void> insertCachedVerses(List<VerseCacheCompanion> rows) => batch(
        (store) => store.insertAll(verseCache, rows, mode: InsertMode.insertOrReplace),
      );

  Future<ChapterInfoCacheData?> getCachedChapterInfo(
    int chapterId,
    String language,
  ) =>
      (select(chapterInfoCache)
            ..where((row) =>
                row.chapterId.equals(chapterId) & row.language.equals(language)))
          .getSingleOrNull();

  Future<void> insertCachedChapterInfo(ChapterInfoCacheCompanion row) =>
      into(chapterInfoCache).insertOnConflictUpdate(row);

  Future<String?> getCachedAudioUrl(int chapterId, int recitationId) =>
      (select(audioUrlCache)
            ..where((row) =>
                row.chapterId.equals(chapterId) &
                row.recitationId.equals(recitationId)))
          .getSingleOrNull()
          .then((row) => row?.audioUrl);

  Future<void> insertCachedAudioUrl(AudioUrlCacheCompanion row) =>
      into(audioUrlCache).insertOnConflictUpdate(row);

  Future<void> clearContentCache() => batch((store) {
        store.deleteAll(chapterCache);
        store.deleteAll(verseCache);
        store.deleteAll(chapterInfoCache);
        store.deleteAll(audioUrlCache);
      });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final bookmarksProvider = StreamProvider<List<Bookmark>>(
  (ref) => ref.watch(databaseProvider).watchBookmarks(),
);
