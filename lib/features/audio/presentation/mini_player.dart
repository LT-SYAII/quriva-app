import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';

/// Spotify-style persistent mini player, shown above the bottom navigation.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: globalAudioPlayer.playerStateStream,
      builder: (context, snapshot) {
        if (!globalAudioPlayer.active) return const SizedBox.shrink();
        final playing = snapshot.data?.playing ?? globalAudioPlayer.playing;
        final processing = snapshot.data?.processingState;
        final item = globalAudioPlayer.currentItem;
        final title = item?.title ?? 'Recitation';
        final artist = item?.artist ?? '';
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GlassPanel(
            radius: 20,
            blur: 22,
            padding: EdgeInsets.zero,
            onTap: () => context.push('/now-playing'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                  child: Row(
                    children: [
                      const LandscapeArtwork(size: 44, radius: 12),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (artist.isNotEmpty)
                              Text(
                                artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: playing ? 'Pause' : 'Play',
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onPressed: () {
                          if (playing) {
                            globalAudioPlayer.pause();
                          } else {
                            final url = globalAudioPlayer.currentUrl;
                            final current = globalAudioPlayer.currentItem;
                            if (url != null && current != null) {
                              globalAudioPlayer.playSurah(
                                url: url,
                                item: current,
                                surahId: globalAudioPlayer.currentSurahId,
                                recitationId:
                                    globalAudioPlayer.currentRecitationId,
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Next surah',
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: globalAudioPlayer.skipToNext,
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Duration>(
                  stream: globalAudioPlayer.positionStream,
                  builder: (context, posSnapshot) {
                    final total = globalAudioPlayer.duration.inMilliseconds;
                    final ms = posSnapshot.data?.inMilliseconds ?? 0;
                    final value = total > 0
                        ? (ms / total).clamp(0.0, 1.0)
                        : 0.0;
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: LinearProgressIndicator(
                        value: processing == ProcessingState.completed
                            ? 1
                            : value,
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
