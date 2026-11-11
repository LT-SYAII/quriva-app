import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';
import 'package:quriva/shared/widgets/ui_kit.dart';

/// Spotify-style persistent mini player, shown above the bottom navigation.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackStatus>(
      valueListenable: globalAudioPlayer.status,
      builder: (context, playbackStatus, _) {
        return StreamBuilder<PlayerState>(
          stream: globalAudioPlayer.playerStateStream,
          builder: (context, snapshot) {
            if (!globalAudioPlayer.active &&
                playbackStatus == PlaybackStatus.idle) {
              return const SizedBox.shrink();
            }
            final playing = snapshot.data?.playing ?? globalAudioPlayer.playing;
            final processing = snapshot.data?.processingState;
            final loading =
                playbackStatus == PlaybackStatus.loading ||
                processing == ProcessingState.loading ||
                processing == ProcessingState.buffering;
            final item = globalAudioPlayer.currentItem;
            final title = item?.title ?? 'Recitation';
            final artist = item?.artist ?? '';
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                ),
                child: GlassPanel(
                  radius: 22,
                  blur: 10,
                  padding: EdgeInsets.zero,
                  onTap: () => context.push('/now-playing'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(9, 8, 5, 8),
                        child: Row(
                          children: [
                            const Hero(
                              tag: 'now-playing-artwork',
                              child: LandscapeArtwork(size: 46, radius: 13),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 260,
                                          ),
                                          child: Text(
                                            title,
                                            key: ValueKey(title),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      EqualizerBars(
                                        active: playing,
                                        height: 10,
                                        barWidth: 2,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  ValueListenableBuilder<VerseTimestamp?>(
                                    valueListenable:
                                        globalAudioPlayer.activeVerse,
                                    builder: (context, active, _) {
                                      final ayah =
                                          active?.chapterId ==
                                              globalAudioPlayer.currentSurahId
                                          ? 'Ayah ${active!.verseNumber}'
                                          : '';
                                      final subtitle =
                                          playbackStatus == PlaybackStatus.error
                                          ? 'Playback failed · tap play to retry'
                                          : [
                                              if (ayah.isNotEmpty) ayah,
                                              if (artist.isNotEmpty) artist,
                                            ].join(' · ');
                                      return Text(
                                        subtitle.isEmpty
                                            ? 'Recitation'
                                            : subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: playing ? 'Pause' : 'Play',
                              visualDensity: VisualDensity.compact,
                              icon: loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      playing
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                              onPressed: loading
                                  ? null
                                  : () => _toggle(context, playing),
                            ),
                            IconButton(
                              tooltip: 'Next surah',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.skip_next_rounded),
                              onPressed: globalAudioPlayer.skipToNext,
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: globalAudioPlayer.positionStream,
                        builder: (context, posSnapshot) {
                          final total =
                              globalAudioPlayer.duration.inMilliseconds;
                          final ms = posSnapshot.data?.inMilliseconds ?? 0;
                          final value = total > 0
                              ? (ms / total).clamp(0.0, 1.0)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: GlassProgressLine(
                              value: processing == ProcessingState.completed
                                  ? 1
                                  : value,
                              height: 2,
                              active: playing,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context, bool playing) async {
    if (playing) {
      await globalAudioPlayer.pause();
      return;
    }
    final bool ok;
    if (globalAudioPlayer.hasError) {
      ok = await globalAudioPlayer.retry();
    } else {
      final url = globalAudioPlayer.currentUrl;
      final current = globalAudioPlayer.currentItem;
      if (url == null || current == null) return;
      ok = await globalAudioPlayer.playSurah(
        url: url,
        item: current,
        surahId: globalAudioPlayer.currentSurahId,
        recitationId: globalAudioPlayer.currentRecitationId,
      );
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            globalAudioPlayer.error.value ?? 'Could not resume playback.',
          ),
        ),
      );
    }
  }
}
