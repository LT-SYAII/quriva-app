import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/app/quriva_app.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background playback + media notification (lock screen / ongoing popup).
  await JustAudioBackground.init(
    androidNotificationChannelId: 'app.quriva.audio',
    androidNotificationChannelName: 'Quriva playback',
    androidNotificationChannelDescription: 'Recitation playback for Quriva.',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationClickStartsActivity: true,
  );

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          ref.watch(preferencesInitProvider);
          return child ?? const QurivaApp();
        },
      ),
    ),
  );
}
