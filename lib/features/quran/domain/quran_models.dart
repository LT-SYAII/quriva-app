/// Domain models for content fetched from the Quran.com API (v4).
library;

class Chapter {
  const Chapter({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.revelationPlace,
    required this.versesCount,
    required this.translatedName,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final translatedName = json['translated_name'] as Map<String, dynamic>?;
    return Chapter(
      id: json['id'] as int,
      nameSimple: json['name_simple'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ?? '',
      revelationPlace: json['revelation_place'] as String? ?? '',
      versesCount: json['verses_count'] as int? ?? 0,
      translatedName:
          translatedName?['name'] as String? ??
          json['name_simple'] as String? ??
          '',
    );
  }

  final int id;
  final String nameSimple;
  final String nameArabic;
  final String revelationPlace;
  final int versesCount;
  final String translatedName;

  String get revelationLabel =>
      revelationPlace == 'makkah' ? 'Makkah' : 'Madinah';
}

class VerseText {
  const VerseText({required this.number, required this.text});

  factory VerseText.fromJson(Map<String, dynamic> json) {
    final key = json['verse_key'] as String? ?? '0:0';
    final number = int.tryParse(key.split(':').last) ?? 0;
    return VerseText(
      number: number,
      text: json['text_uthmani'] as String? ?? '',
    );
  }

  final int number;
  final String text;
}

class Verse {
  const Verse({
    required this.chapterId,
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int chapterId;
  final int number;
  final String arabic;
  final String translation;

  String get key => '$chapterId:$number';
}

class ChapterInfo {
  const ChapterInfo({
    required this.shortText,
    required this.textHtml,
    required this.source,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) => ChapterInfo(
    shortText: json['short_text'] as String? ?? '',
    textHtml: json['text'] as String? ?? '',
    source: json['source'] as String? ?? '',
  );

  final String shortText;
  final String textHtml;
  final String source;
}

class Reciter {
  const Reciter({required this.id, required this.name, required this.style});

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
    id: json['id'] as int,
    name: json['reciter_name'] as String? ?? 'Unknown reciter',
    style: json['style'] as String?,
  );

  final int id;
  final String name;
  final String? style;

  String get displayName =>
      style == null || style!.isEmpty ? name : '$name ($style)';
}

class TranslationResource {
  const TranslationResource({
    required this.id,
    required this.name,
    required this.authorName,
    required this.languageName,
  });

  factory TranslationResource.fromJson(Map<String, dynamic> json) =>
      TranslationResource(
        id: json['id'] as int,
        name: json['name'] as String? ?? 'Unknown translation',
        authorName: json['author_name'] as String? ?? '',
        languageName: json['language_name'] as String? ?? '',
      );

  final int id;
  final String name;
  final String authorName;
  final String languageName;
}

class SearchPage {
  const SearchPage({
    required this.query,
    required this.totalResults,
    required this.currentPage,
    required this.totalPages,
    required this.results,
  });

  factory SearchPage.fromJson(Map<String, dynamic> json) => SearchPage(
    query: json['query'] as String? ?? '',
    totalResults: json['total_results'] as int? ?? 0,
    currentPage: json['current_page'] as int? ?? 1,
    totalPages: json['total_pages'] as int? ?? 1,
    results: [
      for (final item in (json['results'] as List? ?? []))
        SearchVerseResult.fromJson(item as Map<String, dynamic>),
    ],
  );

  final String query;
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final List<SearchVerseResult> results;
}

class SearchVerseResult {
  const SearchVerseResult({
    required this.verseKey,
    required this.arabicText,
    required this.translations,
  });

  factory SearchVerseResult.fromJson(Map<String, dynamic> json) =>
      SearchVerseResult(
        verseKey: json['verse_key'] as String? ?? '',
        arabicText: json['text'] as String? ?? '',
        translations: [
          for (final item in (json['translations'] as List? ?? []))
            SearchTranslation.fromJson(item as Map<String, dynamic>),
        ],
      );

  final String verseKey;
  final String arabicText;
  final List<SearchTranslation> translations;
}

class SearchTranslation {
  const SearchTranslation({required this.name, required this.text});

  factory SearchTranslation.fromJson(Map<String, dynamic> json) =>
      SearchTranslation(
        name: json['name'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );

  final String name;
  final String text;
}

/// Timeline entry mapping an ayah to its position inside a chapter recitation.
class VerseTimestamp {
  const VerseTimestamp({
    required this.verseKey,
    required this.fromMs,
    required this.toMs,
  });

  factory VerseTimestamp.fromJson(Map<String, dynamic> json) => VerseTimestamp(
    verseKey: json['verse_key'] as String? ?? '',
    fromMs: (json['timestamp_from'] as num?)?.toInt() ?? 0,
    toMs: (json['timestamp_to'] as num?)?.toInt() ?? 0,
  );

  final String verseKey;
  final int fromMs;
  final int toMs;

  int get chapterId => int.tryParse(verseKey.split(':').first) ?? 0;
  int get verseNumber => int.tryParse(verseKey.split(':').last) ?? 0;
  Duration get from => Duration(milliseconds: fromMs);
  Duration get to => Duration(milliseconds: toMs);
}

/// Chapter recitation with optional ayah timestamps (lyrics-style sync).
class ChapterAudioTimeline {
  const ChapterAudioTimeline({
    required this.audioUrl,
    required this.timestamps,
  });

  final String? audioUrl;
  final List<VerseTimestamp> timestamps;
}
