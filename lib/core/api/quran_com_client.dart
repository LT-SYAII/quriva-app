import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quriva/features/quran/domain/quran_models.dart';

/// Thin client for the official Quran.com API (v4).
///
/// All Quran content (verses, translations, chapter metadata, recitations
/// and search) is fetched over the network from
/// https://api.quran.com — nothing is bundled into the app binary.
///
/// See ATTRIBUTIONS.md and https://quran.com/api for details.
class QuranComClient {
  QuranComClient({http.Client? client, Uri? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl =
            baseUrl ?? Uri.https('api.quran.com', '/api/v4');

  final http.Client _client;
  final Uri baseUrl;

  static const Duration _timeout = Duration(seconds: 20);

  Future<dynamic> _getJson(String path, [Map<String, String>? query]) async {
    final uri = baseUrl.replace(path: '${baseUrl.path}$path', queryParameters: {
      ...baseUrl.queryParameters,
      ...?query,
    });
    http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } catch (error) {
      throw QuranComApiException(
        'Could not reach Quran.com API. Check your connection. '
        '(${uri.host}) [$error]',
      );
    }
    if (response.statusCode != 200) {
      throw QuranComApiException(
        'Quran.com API error (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<Chapter>> fetchChapters(String language) async {
    final data = await _getJson('/chapters', {'language': language});
    return [
      for (final item in (data['chapters'] as List))
        Chapter.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<VerseText>> fetchChapterVerses(int chapterNumber) async {
    final data = await _getJson(
      '/quran/verses/uthmani',
      {'chapter_number': '$chapterNumber'},
    );
    return [
      for (final item in (data['verses'] as List))
        VerseText.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<String>> fetchChapterTranslations(
    int chapterNumber,
    int translationId,
  ) async {
    final data = await _getJson(
      '/quran/translations/$translationId',
      {'chapter_number': '$chapterNumber'},
    );
    return [
      for (final item in (data['translations'] as List))
        (item as Map<String, dynamic>)['text'] as String? ?? '',
    ];
  }

  Future<ChapterInfo?> fetchChapterInfo(
    int chapterNumber,
    String language,
  ) async {
    final data = await _getJson(
      '/chapters/$chapterNumber/info',
      {'language': language},
    );
    final info = data['chapter_info'];
    if (info is! Map<String, dynamic>) return null;
    return ChapterInfo.fromJson(info);
  }

  Future<String?> fetchChapterAudioUrl(int recitationId, int chapterNumber) async {
    final data = await _getJson(
      '/chapter_recitations/$recitationId/$chapterNumber',
    );
    final file = data['audio_file'];
    if (file is! Map<String, dynamic>) return null;
    return file['audio_url'] as String?;
  }

  Future<List<Reciter>> fetchRecitations(String language) async {
    final data = await _getJson(
      '/resources/recitations',
      {'language': language},
    );
    return [
      for (final item in (data['recitations'] as List))
        Reciter.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Full per-reciter catalog: every surah this reciter has recorded,
  /// mapped chapterId → mp3 url. Powers the "filter surah by reciter" list.
  Future<Map<int, String>> fetchReciterCatalog(int recitationId) async {
    final data = await _getJson('/chapter_recitations/$recitationId');
    final files = data['audio_files'] as List? ?? const [];
    return {
      for (final file in files)
        (file as Map<String, dynamic>)['chapter_id'] as int? ?? 0:
            file['audio_url'] as String? ?? '',
    }..remove(0);
  }

  Future<List<TranslationResource>> fetchTranslations(String language) async {
    final data = await _getJson(
      '/resources/translations',
      {'language': language},
    );
    return [
      for (final item in (data['translations'] as List))
        TranslationResource.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<SearchPage> search(
    String query, {
    int page = 0,
    int size = 25,
    String language = 'en',
  }) async {
    final data = await _getJson(
      '/search',
      {
        'q': query,
        'page': '$page',
        'size': '$size',
        'language': language,
      },
    );
    return SearchPage.fromJson(data['search'] as Map<String, dynamic>);
  }

  void close() => _client.close();
}

class QuranComApiException implements Exception {
  const QuranComApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
