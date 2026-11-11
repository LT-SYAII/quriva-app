import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';

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
    this.timeline,
  });

  final int surahId;
  final String url;
  final MediaItem item;
  final List<VerseTimestamp>? timeline;
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
    _player.positionStream.listen(_updateActiveVerse);
  }

  final AudioPlayer _player;
  String? _loadedId;
  MediaItem? _currentItem;
  int? _currentSurahId;
  int? _currentRecitationId;
  NextSurahResolver? _nextResolver;
  bool _advancing = false;
  List<VerseTimestamp> _timeline = const [];

  /// Currently recited ayah, kept in sync with playback position.
  final ValueNotifier<VerseTimestamp?> activeVerse = ValueNotifier(null);

  Stream<bool> get playingStream =>
      _player.playerStateStream.map((state) => state.playing);

  Stream<Duration> get positionStream => _player.positionStream;

  /// Full player state (playing flag + processing state), for sheets.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Emits whenever surah context changes (piggybacks on player state stream).
  Stream<int?> get currentSurahIdStream =>
      _player.playerStateStream.map((_) => _currentSurahId);

  Duration get duration => _player.duration ?? Duration.zero;

  Duration get position => _player.position;

  bool get playing => _player.playing;

  bool get active => _loadedId != null;

  /// MediaItem currently loaded (used by the mini player bar for title/artist).
  MediaItem? get currentItem => _currentItem;

  /// Streaming url of the currently loaded recitation, or null when idle.
  String? get currentUrl => _loadedId;

  int? get currentSurahId => _currentSurahId;

  int? get currentRecitationId => _currentRecitationId;

  List<VerseTimestamp> get timeline => _timeline;

  void setTimeline(List<VerseTimestamp> timeline) {
    _timeline = timeline;
    _updateActiveVerse(_player.position);
  }

  void _updateActiveVerse(Duration position) {
    if (_timeline.isEmpty) {
      if (activeVerse.value != null) activeVerse.value = null;
      return;
    }
    final ms = position.inMilliseconds;
    for (final entry in _timeline) {
      if (ms >= entry.fromMs && ms <= entry.toMs) {
        if (activeVerse.value?.verseKey != entry.verseKey) {
          activeVerse.value = entry;
        }
        return;
      }
    }
  }

  bool _isSameTrack(int? surahId, int? recitationId, String url) {
    if (surahId != null &&
        recitationId != null &&
        _currentSurahId != null &&
        _currentRecitationId != null) {
      return _currentSurahId == surahId && _currentRecitationId == recitationId;
    }
    return _loadedId == url;
  }

  /// Plays [url] as the current surah track. Optionally tracks context so the
  /// player can auto-advance to the next surah when this one completes.
  Future<void> playSurah({
    required String url,
    required MediaItem item,
    int? surahId,
    int? recitationId,
    NextSurahResolver? nextResolver,
    List<VerseTimestamp>? timeline,
  }) async {
    final same = _isSameTrack(surahId, recitationId, url);

    _currentSurahId = surahId ?? _currentSurahId;
    _currentRecitationId = recitationId ?? _currentRecitationId;
    _nextResolver = nextResolver ?? _nextResolver;
    if (timeline != null) {
      _timeline = timeline;
    } else if (!same) {
      _timeline = const [];
      activeVerse.value = null;
    }

    if (!same || _loadedId != url) {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: item));
      _loadedId = url;
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
    if (playing && _isSameTrack(null, null, url)) {
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
    List<VerseTimestamp>? timeline,
  }) async {
    if (playing && _isSameTrack(surahId, recitationId, url)) {
      await pause();
    } else {
      await playSurah(
        url: url,
        item: item,
        surahId: surahId,
        recitationId: recitationId,
        nextResolver: nextResolver,
        timeline: timeline,
      );
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  /// Next/previous track controls (Spotify-style transport).
  Future<void> skipToNext() => _goToAdjacent(1);

  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 4)) {
      await _player.seek(Duration.zero);
      return;
    }
    await _goToAdjacent(-1);
  }

  Future<void> _autoAdvance() async {
    if (_advancing) return;
    _advancing = true;
    try {
      await _goToAdjacent(1);
    } finally {
      _advancing = false;
    }
  }

  Future<void> _goToAdjacent(int delta) async {
    final resolver = _nextResolver;
    final surahId = _currentSurahId;
    final recitationId = _currentRecitationId;
    if (resolver == null || surahId == null || recitationId == null) return;
    final target = surahId + delta;
    if (target < 1 || target > 114) return;
    try {
      final next = await resolver(target, recitationId);
      if (next == null) return;
      await playSurah(
        url: next.url,
        item: next.item,
        surahId: next.surahId,
        recitationId: recitationId,
        nextResolver: resolver,
        timeline: next.timeline,
      );
    } catch (_) {
      // Best-effort: stay on current track if moving fails.
    }
  }
}
