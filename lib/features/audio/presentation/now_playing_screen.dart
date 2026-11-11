import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/utils/text_utils.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';

/// Full-screen Spotify-style player with lyrics-style ayah highlighting.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  String _clock(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationId = ref.watch(translationIdProvider);
    final surahId = globalAudioPlayer.currentSurahId;
    final reciterId = globalAudioPlayer.currentRecitationId;
    final item = globalAudioPlayer.currentItem;
    final chapters = ref.watch(
      chaptersProvider(ref.watch(appLanguageProvider)),
    );
    final chapter = chapters.value?.where((c) => c.id == surahId).firstOrNull;
    final title = chapter?.nameSimple ?? item?.title ?? 'Nothing playing';
    final reciter = item?.artist ?? '';

    final versesAsync = surahId == null
        ? null
        : ref.watch(readerProvider((surahId, translationId)));

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: LandscapeBackground()),
          SafeArea(
            child: StreamBuilder<PlayerState>(
              stream: globalAudioPlayer.playerStateStream,
              builder: (context, stateSnapshot) {
                final playing =
                    stateSnapshot.data?.playing ?? globalAudioPlayer.playing;
                final processing = stateSnapshot.data?.processingState;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Close player',
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            onPressed: () => context.pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'NOW PLAYING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Surah info',
                            icon: const Icon(Icons.info_outline_rounded),
                            onPressed: surahId == null
                                ? null
                                : () => context.push('/surah-info/$surahId'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 20,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const _ArtworkCard(),
                                  const SizedBox(height: 22),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (reciter.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reciter,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  _LyricsCard(
                                    verses:
                                        versesAsync?.value ?? const <Verse>[],
                                    surahId: surahId,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    StreamBuilder<Duration>(
                      stream: globalAudioPlayer.positionStream,
                      builder: (context, posSnapshot) {
                        final position =
                            posSnapshot.data ?? globalAudioPlayer.position;
                        final duration = globalAudioPlayer.duration;
                        final max = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;
                        final value = position.inMilliseconds
                            .clamp(0, max.toInt())
                            .toDouble();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  value: value,
                                  max: max,
                                  onChanged: duration.inMilliseconds > 0
                                      ? (v) => globalAudioPlayer.seek(
                                          Duration(milliseconds: v.round()),
                                        )
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _clock(position),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      _clock(duration),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: 'Previous / restart',
                            iconSize: 34,
                            icon: const Icon(Icons.skip_previous_rounded),
                            onPressed: globalAudioPlayer.active
                                ? globalAudioPlayer.skipToPrevious
                                : null,
                          ),
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: globalAudioPlayer.active
                                  ? () {
                                      if (playing) {
                                        globalAudioPlayer.pause();
                                      } else {
                                        final url =
                                            globalAudioPlayer.currentUrl;
                                        final current =
                                            globalAudioPlayer.currentItem;
                                        if (url != null && current != null) {
                                          globalAudioPlayer.playSurah(
                                            url: url,
                                            item: current,
                                            surahId: surahId,
                                            recitationId: reciterId,
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              child: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 38,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next surah',
                            iconSize: 34,
                            icon: const Icon(Icons.skip_next_rounded),
                            onPressed: globalAudioPlayer.active
                                ? globalAudioPlayer.skipToNext
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (processing == ProcessingState.loading ||
                        processing == ProcessingState.buffering)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: 90,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final size = width.clamp(240.0, 420.0) * .74;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LandscapeArtwork(size: size, radius: 30),
    );
  }
}

class _LyricsCard extends StatelessWidget {
  const _LyricsCard({required this.verses, required this.surahId});

  final List<Verse> verses;
  final int? surahId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VerseTimestamp?>(
      valueListenable: globalAudioPlayer.activeVerse,
      builder: (context, active, _) {
        final matching =
            active != null && active.chapterId == surahId && verses.isNotEmpty
            ? verses.where((v) => v.number == active.verseNumber).firstOrNull
            : null;
        final arabic = matching?.arabic ?? '';
        final translation = matching == null
            ? ''
            : cleanTranslationText(matching.translation);
        return GlassPanel(
          radius: 22,
          blur: 0,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            children: [
              Text(
                active == null ? 'AYAH HIGHLIGHT' : active.verseKey,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (arabic.isEmpty)
                Text(
                  'Play a surah to follow along, ayah by ayah.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    arabic,
                    key: ValueKey(active?.verseKey),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 24, height: 1.9),
                  ),
                ),
                if (translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      translation,
                      key: ValueKey('t-${active?.verseKey}'),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
