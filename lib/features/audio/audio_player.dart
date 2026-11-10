import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// App-lifetime audio player.
///
/// Deliberately NOT scoped to a screen: when the user leaves the reader —
/// or closes the app UI entirely — playback keeps going and a persistent
/// media notification (play/pause/seek) stays available on Android.
final ChapterAudioPlayer globalAudioPlayer = ChapterAudioPlayer();

class ChapterAudioPlayer {
  ChapterAudioPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;
  String? _loadedId;
  MediaItem? _currentItem;

  Stream<bool> get playingStream =>
      _player.playerStateStream.map((state) => state.playing);

  Stream<Duration> get positionStream => _player.positionStream;

  /// Full player state (playing flag + processing state), for sheets.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Duration get duration => _player.duration ?? Duration.zero;

  bool get playing => _player.playing;

  bool get active => _loadedId != null;

  /// MediaItem currently loaded (used by the mini player bar for title/artist).
  MediaItem? get currentItem => _currentItem;

  /// Streaming url of the currently loaded recitation, or null when idle.
  String? get currentUrl => _loadedId;

  Future<void> play(String url, MediaItem item) async {
    if (_loadedId != item.id) {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: item),
      );
      _loadedId = item.id;
    }
    _currentItem = item;
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> toggle(String url, MediaItem item) async {
    if (playing) {
      await pause();
    } else {
      await play(url, item);
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);
}
