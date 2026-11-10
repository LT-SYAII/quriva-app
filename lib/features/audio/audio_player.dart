import 'package:just_audio/just_audio.dart';

/// Chapter audio playback (a single mp3 per surah served by quran.com /
/// Quranicaudio). Managed per screen — closed when the widget is disposed.
class ChapterAudioPlayer {
  ChapterAudioPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _playing = false;
  String? _loadedUrl;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get playing => _playing;

  Future<void> play(String url) async {
    if (_loadedUrl != url) {
      await _player.setUrl(url);
      _loadedUrl = url;
    }
    await _player.play();
    _playing = true;
  }

  Future<void> pause() async {
    await _player.pause();
    _playing = false;
  }

  Future<void> toggle(String url) async {
    if (_playing) {
      await pause();
    } else {
      await play(url);
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> dispose() async => _player.dispose();
}
