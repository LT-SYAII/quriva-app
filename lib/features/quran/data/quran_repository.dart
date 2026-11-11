import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quriva/core/api/quran_com_client.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';

/// Cache-first repository on top of the Quran.com API.
///
/// Nothing is bundled: everything is fetched live and cached locally in
/// SQLite so the app still opens fast (and stays readable) offline.
class QuranRepository {
  const QuranRepository({required this.client, required this.database});

  final QuranComClient client;
  final AppDatabase database;

  Future<List<Chapter>> getChapters(String language) async {
    final cached = await database.getCachedChapters(language);
    if (cached.isNotEmpty) {
      return [
        for (final row in cached)
          Chapter(
            id: row.chapterId,
            nameSimple: row.nameSimple,
            nameArabic: row.nameArabic,
            revelationPlace: row.revelationPlace,
            versesCount: row.versesCount,
            translatedName: row.translatedName,
          ),
      ];
    }
    final chapters = await client.fetchChapters(language);
    await database.insertCachedChapters([
      for (final chapter in chapters)
        ChapterCacheCompanion.insert(
          language: language,
          chapterId: chapter.id,
          nameSimple: chapter.nameSimple,
          nameArabic: chapter.nameArabic,
          revelationPlace: chapter.revelationPlace,
          versesCount: chapter.versesCount,
          translatedName: chapter.translatedName,
        ),
    ]);
    return chapters;
  }

  Future<List<Verse>> getVerses(int chapterId, int translationId) async {
    final cached = await database.getCachedVerses(chapterId, translationId);
    if (cached != null && cached.isNotEmpty) {
      return [
        for (final row in cached)
          Verse(
            chapterId: chapterId,
            number: row.verseNumber,
            arabic: row.arabic,
            translation: row.translation,
          ),
      ];
    }
    final arabicVerses = await client.fetchChapterVerses(chapterId);
    List<String> translations;
    try {
      translations = await client.fetchChapterTranslations(
        chapterId,
        translationId,
      );
    } on QuranComApiException {
      translations = <String>[];
    }
    final rows = <VerseCacheCompanion>[];
    for (final verse in arabicVerses) {
      final translation = translations.length > verse.number - 1
          ? translations[verse.number - 1]
          : '';
      rows.add(
        VerseCacheCompanion(
          chapterId: Value(chapterId),
          verseNumber: Value(verse.number),
          translationId: Value(translationId),
          arabic: Value(verse.text),
          translation: Value(translation),
        ),
      );
    }
    await database.insertCachedVerses(rows);
    return [
      for (final verse in arabicVerses)
        Verse(
          chapterId: chapterId,
          number: verse.number,
          arabic: verse.text,
          translation: translations.length > verse.number - 1
              ? translations[verse.number - 1]
              : '',
        ),
    ];
  }

  Future<ChapterInfo?> getChapterInfo(int chapterId, String language) async {
    final cached = await database.getCachedChapterInfo(chapterId, language);
    if (cached != null) {
      return ChapterInfo(
        shortText: cached.shortText,
        textHtml: cached.textHtml,
        source: cached.source,
      );
    }
    final info = await client.fetchChapterInfo(chapterId, language);
    if (info == null) return null;
    await database.insertCachedChapterInfo(
      ChapterInfoCacheCompanion.insert(
        chapterId: chapterId,
        language: language,
        shortText: info.shortText,
        textHtml: info.textHtml,
        source: info.source,
      ),
    );
    return info;
  }

  /// Ayah timestamps for a chapter recitation (not cached: small payload,
  /// fetched when the reader loads/plays a surah).
  Future<ChapterAudioTimeline> getChapterAudioTimeline(
    int chapterId,
    int recitationId,
  ) => client.fetchChapterAudioTimeline(recitationId, chapterId);

  Future<String?> getChapterAudioUrl(int chapterId, int recitationId) async {
    final cached = await database.getCachedAudioUrl(chapterId, recitationId);
    if (cached != null) return cached;
    final url = await client.fetchChapterAudioUrl(recitationId, chapterId);
    if (url != null) {
      await database.insertCachedAudioUrl(
        AudioUrlCacheCompanion.insert(
          chapterId: chapterId,
          recitationId: recitationId,
          audioUrl: url,
        ),
      );
    }
    return url;
  }

  Future<List<Reciter>> getReciters(String language) =>
      client.fetchRecitations(language);

  /// chapterId → mp3 url for the given reciter (from the reciter's own
  /// catalog on Quran.com). Kept in memory only; lists are small.
  Future<Map<int, String>> getReciterCatalog(int recitationId) =>
      client.fetchReciterCatalog(recitationId);

  Future<List<TranslationResource>> getTranslations(String language) =>
      client.fetchTranslations(language);

  Future<SearchPage> search(String query, {int page = 0}) =>
      client.search(query, page: page, language: 'en');

  Future<void> clearContentCache() => database.clearContentCache();
}

final clientProvider = Provider<QuranComClient>((ref) {
  final client = QuranComClient();
  ref.onDispose(client.close);
  return client;
});

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(
    client: ref.watch(clientProvider),
    database: ref.watch(databaseProvider),
  );
});

final chaptersProvider = FutureProvider.family<List<Chapter>, String>(
  (ref, language) => ref.watch(quranRepositoryProvider).getChapters(language),
);

final readerProvider = FutureProvider.family<List<Verse>, (int, int)>((
  ref,
  args,
) {
  final (chapterId, translationId) = args;
  return ref.watch(quranRepositoryProvider).getVerses(chapterId, translationId);
});

final chapterInfoProvider = FutureProvider.family<ChapterInfo?, (int, String)>((
  ref,
  args,
) {
  final (chapterId, language) = args;
  return ref.watch(quranRepositoryProvider).getChapterInfo(chapterId, language);
});

final chapterAudioUrlProvider = FutureProvider.family<String?, (int, int)>((
  ref,
  args,
) {
  final (chapterId, recitationId) = args;
  return ref
      .watch(quranRepositoryProvider)
      .getChapterAudioUrl(chapterId, recitationId);
});

/// Chapter audio url + ayah timestamps for lyrics-style highlighting.
final chapterAudioTimelineProvider =
    FutureProvider.family<ChapterAudioTimeline, (int, int)>((ref, args) {
      final (chapterId, recitationId) = args;
      return ref
          .watch(quranRepositoryProvider)
          .getChapterAudioTimeline(chapterId, recitationId);
    });

final recitersProvider = FutureProvider.family<List<Reciter>, String>((
  ref,
  language,
) {
  return ref.watch(quranRepositoryProvider).getReciters(language);
});

/// chapterId → audio url for one reciter.
final reciterCatalogProvider = FutureProvider.family<Map<int, String>, int>((
  ref,
  recitationId,
) {
  return ref.watch(quranRepositoryProvider).getReciterCatalog(recitationId);
});

/// reciterId → how many surahs that reciter has published.
/// Lightweight: only reports counts for catalogs already loaded in memory to
/// avoid firing a network request per reciter.
final reciterCountsProvider = Provider<Map<int, int>>((ref) {
  final reciters = ref.watch(recitersProvider('en')).value;
  if (reciters == null) return const <int, int>{};
  final counts = <int, int>{};
  for (final reciter in reciters) {
    final len = ref.watch(reciterCatalogProvider(reciter.id)).value?.length;
    if (len != null) counts[reciter.id] = len;
  }
  return counts;
});

final translationsProvider =
    FutureProvider.family<List<TranslationResource>, String>((ref, language) {
      return ref.watch(quranRepositoryProvider).getTranslations(language);
    });

final readingProgressProvider = FutureProvider<ReadingProgressData?>(
  (ref) => ref.watch(databaseProvider).loadProgress(),
);

/// Common helper so home/bookmarks/reader show the same reciter identity.
String reciterNameFor(List<Reciter>? reciters, int id) {
  for (final reciter in reciters ?? const <Reciter>[]) {
    if (reciter.id == id) return reciter.displayName;
  }
  return 'Reciter #$id';
}

/// Subtitle for reciter lists, e.g. "murattal · 114 surahs".
String reciterSubtitle(Reciter reciter, Map<int, int>? counts) {
  final count = counts?[reciter.id];
  final countText = count == null ? '···' : '$count';
  final style = reciter.style;
  final hasStyle = style != null && style.isNotEmpty;
  return hasStyle ? '$style · $countText surahs' : '$countText surahs';
}
