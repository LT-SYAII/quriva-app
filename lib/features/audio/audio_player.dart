import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// App-lifetime audio player.
///
/// Deliberately NOT scoped to a screen: when the user leaves the reader —
/// or closes the app UI entirely — playback keeps going and a persistent
/// media notification (play/pause/seek) stays available on Android.
final ChapterAudioPlayer globalAudioPlayer = ChapterAudioPlayer();

class NextSurah {
  const NextSurah({
    required this.surahId,
    required this.url,
    required this.item,
  });

  final int surahId;
  final String url;
  final MediaItem item;
}

/// Resolves the next surah track for auto-advance (returns null to stop).
typedef NextSurahResolver = Future<NextSurah?> Function(
  int nextSurahId,
  int recitationId,
);

class ChapterAudioPlayer {
  ChapterAudioPlayer() : _player = AudioPlayer() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        unawaited(_autoAdvance());
      }
    });
  }

  final AudioPlayer _player;
  String? _loadedId;
  MediaItem? _currentItem;
  int? _currentSurahId;
  int? _currentRecitationId;
  NextSurahResolver? _nextResolver;
  bool _advancing = false;

  Stream<bool> get playingStream =>
      _player.playerStateStream.map((state) => state.playing);

  Stream<Duration> get positionStream => _player.positionStream;

  /// Full player state (playing flag + processing state), for sheets.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Emits the surah id currently loaded/playing (or null).
  Stream<int?> get currentSurahIdStream => _player.playerStateStream.map(
        (_) => _currentSurahId,
      );

  Duration get duration => _player.duration ?? Duration.zero;

  bool get playing => _player.playing;

  bool get active => _loadedId != null;

  /// MediaItem currently loaded (used by the mini player bar for title/artist).
  MediaItem? get currentItem => _currentItem;

  /// Streaming url of the currently loaded recitation, or null when idle.
  String? get currentUrl => _loadedId;

  int? get currentSurahId => _currentSurahId;

  int? get currentRecitationId => _currentRecitationId;

  /// Plays [url] as the current surah track. Optionally tracks context so the
  /// player can auto-advance to the next surah when this one completes.
  Future<void> playSurah({
    required String url,
    required MediaItem item,
    int? surahId,
    int? recitationId,
    NextSurahResolver? nextResolver,
  }) async {
    _currentSurahId = surahId ?? _currentSurahId;
    _currentRecitationId = recitationId ?? _currentRecitationId;
    _nextResolver = nextResolver ?? _nextResolver;

    if (_loadedId != item.id) {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: item),
      );
      _loadedId = item.id;
    }
    _currentItem = item;
    await _player.play();
  }

  /// Back-compat: play without explicit surah context.
  Future<void> play(String url, MediaItem item) =>
      playSurah(url: url, item: item);

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> toggle(String url, MediaItem item) async {
    if (playing && _loadedId == item.id) {
      await pause();
    } else {
      await play(url, item);
    }
  }

  Future<void> toggleSurah({
    required String url,
    required MediaItem item,
    int? surahId,
    int? recitationId,
    NextSurahResolver? nextResolver,
  }) async {
    if (playing && _loadedId == item.id) {
      await pause();
    } else {
      await playSurah(
        url: url,
        item: item,
        surahId: surahId,
        recitationId: recitationId,
        nextResolver: nextResolver,
      );
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> _autoAdvance() async {
    if (_advancing) return;
    final resolver = _nextResolver;
    final surahId = _currentSurahId;
    final recitationId = _currentRecitationId;
    if (resolver == null || surahId == null || recitationId == null) return;
    final nextId = surahId + 1;
    if (nextId > 114) return;
    _advancing = true;
    try {
      final next = await resolver(nextId, recitationId);
      if (next == null) return;
      await playSurah(
        url: next.url,
        item: next.item,
        surahId: next.surahId,
        recitationId: recitationId,
        nextResolver: resolver,
      );
    } catch (_) {
      // Best-effort: stay on completed track if advancing fails.
    } finally {
      _advancing = false;
    }
  }
}
