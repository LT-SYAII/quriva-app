import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/app/quriva_app.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In release, uncaught widget errors can otherwise leave a blank screen.
  ErrorWidget.builder = (details) {
    return Material(
      color: const Color(0xFF050505),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Something went wrong.\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  };
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // ignore: avoid_print
      print(details.exceptionAsString());
    }
  };

  // Background playback + media notification (lock screen / ongoing popup).
  // Best-effort: if init fails the app must still launch; playback will just
  // run without a system notification/media-session tags.
  var audioBackgroundReady = false;
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'app.quriva.audio',
      androidNotificationChannelName: 'Quriva playback',
      androidNotificationChannelDescription: 'Recitation playback for Quriva.',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationClickStartsActivity: true,
    );
    audioBackgroundReady = true;
  } catch (_) {
    // Ignore: keep the app usable without background-audio integration.
  }
  globalAudioPlayer.setBackgroundReady(audioBackgroundReady);

  runApp(const ProviderScope(child: _Boot()));
}

class _Boot extends ConsumerWidget {
  const _Boot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed preferences (fire-and-forget); app renders immediately with defaults.
    ref.watch(preferencesInitProvider);
    return const QurivaApp();
  }
}
