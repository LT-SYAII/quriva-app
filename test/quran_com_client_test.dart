import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quriva/core/api/quran_com_client.dart';

http.Client _mockClient(
  String path,
  Map<String, String> query,
  Object body,
) {
  return MockClient((request) async {
    final actual = request.url;
    final expected = Uri.https('api.quran.com', '/api/v4$path');
    expect(actual.host, 'api.quran.com');
    if (actual.path == expected.path) {
      for (final entry in query.entries) {
        expect(actual.queryParameters[entry.key], entry.value,
            reason: '$path query ${entry.key}');
      }
    }
    return http.Response(
      jsonEncode(body),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

void main() {
  test('client parses chapters response', () async {
    final client = QuranComClient(
      client: _mockClient('/chapters', {'language': 'en'}, {
        'chapters': [
          {
            'id': 112,
            'name_simple': 'Al-Ikhlas',
            'name_arabic': 'الإخلاص',
            'revelation_place': 'makkah',
            'verses_count': 4,
            'translated_name': {'name': 'The Sincerity'},
          },
        ],
      }),
    );
    final chapters = await client.fetchChapters('en');
    expect(chapters, hasLength(1));
    expect(chapters.first.nameSimple, 'Al-Ikhlas');
    expect(chapters.first.revelationLabel, 'Makkah');
    client.close();
  });

  test('client parses uthmani verses and extracts verse numbers', () async {
    final client = QuranComClient(
      client: _mockClient(
        '/quran/verses/uthmani',
        {'chapter_number': '1'},
        {
          'verses': [
            {'id': 1, 'verse_key': '1:1', 'text_uthmani': 'بِسْمِ ٱللَّهِ'},
            {'id': 2, 'verse_key': '1:2', 'text_uthmani': 'ٱلْحَمْدُ لِلَّهِ'},
          ],
        },
      ),
    );
    final verses = await client.fetchChapterVerses(1);
    expect(verses, hasLength(2));
    expect(verses.last.number, 2);
    expect(verses.first.text, contains('بِسْمِ'));
    client.close();
  });

  test('client exposes chapter audio url', () async {
    final client = QuranComClient(
      client: _mockClient('/chapter_recitations/7/112', const {}, {
        'audio_file': {
          'id': 1133,
          'chapter_id': 112,
          'format': 'mp3',
          'audio_url':
              'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/112.mp3',
        },
      }),
    );
    final url = await client.fetchChapterAudioUrl(7, 112);
    expect(url, isNotNull);
    expect(url, endsWith('112.mp3'));
    client.close();
  });

  test('client surfaces API failures as typed exceptions', () async {
    final client = QuranComClient(
      client: MockClient((request) async => http.Response('nope', 404)),
    );
    await expectLater(
      client.fetchChapters('en'),
      throwsA(isA<QuranComApiException>()),
    );
    client.close();
  });

  test('client parses search pages', () async {
    final client = QuranComClient(
      client: _mockClient(
        '/search',
        {'q': 'mercy', 'page': '0', 'size': '25', 'language': 'en'},
        {
          'search': {
            'query': 'mercy',
            'total_results': 2156,
            'current_page': 1,
            'total_pages': 719,
            'results': [
              {
                'verse_key': '7:151',
                'verse_id': 1105,
                'text': 'قَالَ',
                'translations': [
                  {'name': 'M. Pickthall', 'text': 'mercy'},
                ],
              },
            ],
          },
        },
      ),
    );
    final page = await client.search('mercy');
    expect(page.totalResults, 2156);
    expect(page.results.first.verseKey, '7:151');
    expect(page.results.first.translations.first.name, 'M. Pickthall');
    client.close();
  });
}
