import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';

/// High level playback state that is easy to render in the UI.
enum PlaybackStatus { idle, loading, playing, paused, error }

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

class _PlayRequest {
  const _PlayRequest({
    required this.url,
    required this.item,
    required this.fallbackUrl,
    this.surahId,
    this.recitationId,
    this.nextResolver,
    this.timeline,
  });

  final String url;
  final String? fallbackUrl;
  final MediaItem item;
  final int? surahId;
  final int? recitationId;
  final NextSurahResolver? nextResolver;
  final List<VerseTimestamp>? timeline;
}

class ChapterAudioPlayer {
  ChapterAudioPlayer() : _player = AudioPlayer() {
    _player.playerStateStream.listen(
      _onPlayerState,
      onError: (Object error, StackTrace stack) => _setError(error),
    );
    _player.positionStream.listen(_updateActiveVerse);
  }

  static const Duration _loadTimeout = Duration(seconds: 30);

  final AudioPlayer _player;
  String? _loadedId;
  MediaItem? _currentItem;
  int? _currentSurahId;
  int? _currentRecitationId;
  NextSurahResolver? _nextResolver;
  bool _advancing = false;
  List<VerseTimestamp> _timeline = const [];
  _PlayRequest? _lastRequest;
  int _loadToken = 0;
  bool _starting = false;

  /// Currently recited ayah, kept in sync with playback position.
  final ValueNotifier<VerseTimestamp?> activeVerse = ValueNotifier(null);

  /// Coarse playback state for play buttons, loaders and error banners.
  final ValueNotifier<PlaybackStatus> status = ValueNotifier(
    PlaybackStatus.idle,
  );

  /// Human readable error for the last failed load/play attempt.
  final ValueNotifier<String?> error = ValueNotifier(null);

  /// Incremented whenever the active surah/reciter metadata changes. Screens
  /// use this to refresh chapter and lyrics providers after skip/auto-advance.
  final ValueNotifier<int> trackRevision = ValueNotifier(0);

  Stream<bool> get playingStream =>
      _player.playerStateStream.map((state) => state.playing);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  /// Emits whenever surah context changes (piggybacks on player state stream).
  Stream<int?> get currentSurahIdStream =>
      _player.playerStateStream.map((_) => _currentSurahId);

  Duration get duration => _player.duration ?? Duration.zero;

  Duration get position => _player.position;

  Duration get bufferedPosition => _player.bufferedPosition;

  bool get playing => _player.playing;

  bool get loading => status.value == PlaybackStatus.loading;

  bool get hasError => status.value == PlaybackStatus.error;

  bool get active => _loadedId != null || _currentItem != null;

  /// MediaItem currently loaded (used by the mini player bar for title/artist).
  MediaItem? get currentItem => _currentItem;

  /// Streaming url of the currently loaded recitation, or null when idle.
  String? get currentUrl => _loadedId;

  int? get currentSurahId => _currentSurahId;

  int? get currentRecitationId => _currentRecitationId;

  List<VerseTimestamp> get timeline => _timeline;

  /// Fraction of the current track already buffered, for seek bars.
  double get bufferedFraction {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (bufferedPosition.inMilliseconds / total).clamp(0.0, 1.0);
  }

  void _onPlayerState(PlayerState state) {
    if (state.processingState == ProcessingState.completed) {
      status.value = PlaybackStatus.paused;
      if (!_advancing) unawaited(_autoAdvance());
      return;
    }
    if (_starting) return;
    if (state.playing) {
      status.value = PlaybackStatus.playing;
    } else if (_loadedId != null && status.value != PlaybackStatus.error) {
      status.value = PlaybackStatus.paused;
    }
  }

  void _setError(Object exception) {
    error.value = _friendlyError(exception);
    status.value = PlaybackStatus.error;
    _starting = false;
  }

  String _friendlyError(Object exception) {
    final text = exception.toString().toLowerCase();
    if (text.contains('404') || text.contains('not found')) {
      return 'This recitation is not available right now.';
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return 'The recitation took too long to load. Check your connection.';
    }
    if (text.contains('source error') ||
        text.contains('http') ||
        text.contains('socket') ||
        text.contains('connection')) {
      return 'Could not load the recitation. Check your connection and retry.';
    }
    return 'Could not play this recitation. Please retry.';
  }

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
  ///
  /// Returns true when playback was started (or resumed) successfully.
  /// [fallbackUrl] is tried once when the primary URL fails to load.
  Future<bool> playSurah({
    required String url,
    required MediaItem item,
    int? surahId,
    int? recitationId,
    NextSurahResolver? nextResolver,
    List<VerseTimestamp>? timeline,
    String? fallbackUrl,
  }) async {
    final same = _isSameTrack(surahId, recitationId, url);
    final metadataChanged =
        !same ||
        _currentItem?.id != item.id ||
        _currentItem?.title != item.title ||
        _currentItem?.artist != item.artist;
    final request = _PlayRequest(
      url: url,
      fallbackUrl: fallbackUrl,
      item: item,
      surahId: surahId,
      recitationId: recitationId,
      nextResolver: nextResolver ?? _nextResolver,
      timeline: timeline,
    );
    _lastRequest = request;

    _currentSurahId = surahId ?? _currentSurahId;
    _currentRecitationId = recitationId ?? _currentRecitationId;
    _nextResolver = request.nextResolver;
    _currentItem = item;
    if (metadataChanged) trackRevision.value++;
    if (timeline != null) {
      _timeline = timeline;
    } else if (!same) {
      _timeline = const [];
      activeVerse.value = null;
    }

    // When the fallback source was loaded successfully, resuming the same
    // track must not retry the failed primary URL all over again.
    final needsReload = !same || (_loadedId != url && _loadedId != fallbackUrl);
    if (!needsReload) {
      _starting = true;
      error.value = null;
      status.value = PlaybackStatus.playing;
      try {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        unawaited(
          _player.play().catchError((Object exception, StackTrace stack) {
            _setError(exception);
          }),
        );
        _starting = false;
        return true;
      } catch (exception) {
        _setError(exception);
        return false;
      }
    }

    final token = ++_loadToken;
    _starting = true;
    error.value = null;
    status.value = PlaybackStatus.loading;
    activeVerse.value = null;

    final loaded = await _loadSource(
      url,
      item,
      fallbackUrl: fallbackUrl,
      token: token,
    );
    if (token != _loadToken) return false;
    if (!loaded) return false;

    _starting = false;
    status.value = PlaybackStatus.playing;
    try {
      unawaited(
        _player.play().catchError((Object exception, StackTrace stack) {
          _setError(exception);
        }),
      );
      return true;
    } catch (exception) {
      _setError(exception);
      return false;
    }
  }

  Future<bool> _loadSource(
    String url,
    MediaItem item, {
    required int token,
    String? fallbackUrl,
  }) async {
    Future<void> load(String candidate) async {
      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(candidate), tag: item))
          .timeout(_loadTimeout);
    }

    try {
      await load(url);
      if (token != _loadToken) return false;
      _loadedId = url;
      return true;
    } catch (exception) {
      if (token != _loadToken) return false;
      final fallback = fallbackUrl;
      if (fallback != null && fallback.isNotEmpty && fallback != url) {
        try {
          await load(fallback);
          if (token != _loadToken) return false;
          _loadedId = fallback;
          return true;
        } catch (fallbackException) {
          if (token != _loadToken) return false;
          _loadedId = null;
          _setError(fallbackException);
          return false;
        }
      }
      _loadedId = null;
      _setError(exception);
      return false;
    }
  }

  /// Retries the last failed load with the same source/fallback.
  Future<bool> retry() async {
    final request = _lastRequest;
    if (request == null) return false;
    return playSurah(
      url: request.url,
      item: request.item,
      surahId: request.surahId,
      recitationId: request.recitationId,
      nextResolver: request.nextResolver,
      timeline: request.timeline,
      fallbackUrl: request.fallbackUrl,
    );
  }

  /// Back-compat: play without explicit surah context.
  Future<bool> play(String url, MediaItem item) =>
      playSurah(url: url, item: item);

  Future<void> pause() async {
    await _player.pause();
    status.value = PlaybackStatus.paused;
  }

  Future<void> toggle(String url, MediaItem item) async {
    if (playing && _isSameTrack(null, null, url)) {
      await pause();
    } else {
      await play(url, item);
    }
  }

  Future<bool> toggleSurah({
    required String url,
    required MediaItem item,
    int? surahId,
    int? recitationId,
    NextSurahResolver? nextResolver,
    List<VerseTimestamp>? timeline,
    String? fallbackUrl,
  }) async {
    if (playing && _isSameTrack(surahId, recitationId, url)) {
      await pause();
      return true;
    }
    return playSurah(
      url: url,
      item: item,
      surahId: surahId,
      recitationId: recitationId,
      nextResolver: nextResolver,
      timeline: timeline,
      fallbackUrl: fallbackUrl,
    );
  }

  Future<void> seek(Duration position) => _player.seek(position);

  /// Jumps to the start of [verseNumber] in the current timeline.
  Future<void> seekToVerse(int verseNumber, {bool resume = true}) async {
    VerseTimestamp? target;
    for (final entry in _timeline) {
      if (entry.verseNumber == verseNumber) {
        target = entry;
        break;
      }
    }
    if (target == null) return;
    await _player.seek(target.from);
    _updateActiveVerse(target.from);
    if (resume && !_player.playing) {
      unawaited(_player.play());
    }
  }

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
