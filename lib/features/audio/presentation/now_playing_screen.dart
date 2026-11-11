import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quriva/app/theme.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/utils/text_utils.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';
import 'package:quriva/shared/widgets/ui_kit.dart';

/// Full-screen Spotify-style player with lyrics-style ayah highlighting.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: QurivaTheme.dark,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ValueListenableBuilder<int>(
          valueListenable: globalAudioPlayer.trackRevision,
          builder: (context, revision, _) =>
              _NowPlayingContent(key: ValueKey(revision)),
        ),
      ),
    );
  }
}

class _NowPlayingContent extends ConsumerWidget {
  const _NowPlayingContent({super.key});

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
    final item = globalAudioPlayer.currentItem;
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language));
    final chapterList = chapters.value ?? const <Chapter>[];
    final chapter = chapterList.where((c) => c.id == surahId).firstOrNull;
    final nextChapter = surahId == null || surahId >= 114
        ? null
        : chapterList.where((c) => c.id == surahId + 1).firstOrNull;
    final title = chapter?.nameSimple ?? item?.title ?? 'Nothing playing';
    final reciter = item?.artist ?? '';
    final versesAsync = surahId == null
        ? null
        : ref.watch(readerProvider((surahId, translationId)));
    final verses = versesAsync?.value ?? const <Verse>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 420) context.pop();
        },
        child: Stack(
          children: [
            const Positioned.fill(child: LandscapeBackground()),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .18),
                      Colors.black.withValues(alpha: .48),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ValueListenableBuilder<PlaybackStatus>(
                valueListenable: globalAudioPlayer.status,
                builder: (context, playbackStatus, _) {
                  return StreamBuilder<PlayerState>(
                    stream: globalAudioPlayer.playerStateStream,
                    builder: (context, stateSnapshot) {
                      final playing =
                          stateSnapshot.data?.playing ??
                          globalAudioPlayer.playing;
                      final processing = stateSnapshot.data?.processingState;
                      final loading =
                          playbackStatus == PlaybackStatus.loading ||
                          processing == ProcessingState.loading ||
                          processing == ProcessingState.buffering;
                      return Column(
                        children: [
                          _TopBar(
                            onClose: () => context.pop(),
                            onInfo: surahId == null
                                ? null
                                : () => context.push('/surah-info/$surahId'),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    22,
                                    0,
                                    22,
                                    10,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight - 10,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const _ArtworkCard(),
                                        const SizedBox(height: 20),
                                        Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -.3,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                reciter.isEmpty
                                                    ? 'Quriva'
                                                    : reciter,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (chapter != null) ...[
                                          const SizedBox(height: 10),
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 7,
                                            runSpacing: 6,
                                            children: [
                                              GlassChip(
                                                label: 'SURAH ${chapter.id}',
                                                dense: true,
                                              ),
                                              GlassChip(
                                                label:
                                                    '${chapter.revelationLabel} · ${chapter.versesCount} ayat',
                                                dense: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        _LyricsCard(
                                          verses: verses,
                                          surahId: surahId,
                                          totalVerses: chapter?.versesCount,
                                        ),
                                        const SizedBox(height: 14),
                                        if (nextChapter != null &&
                                            surahId != null)
                                          _UpNextRow(
                                            title: nextChapter.nameSimple,
                                            subtitle:
                                                'Surah ${nextChapter.id} · ${nextChapter.versesCount} ayat',
                                            onTap: globalAudioPlayer.skipToNext,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (playbackStatus == PlaybackStatus.error)
                            _ErrorBanner(
                              message:
                                  globalAudioPlayer.error.value ??
                                  'Playback failed.',
                              onRetry: globalAudioPlayer.retry,
                            ),
                          StreamBuilder<Duration>(
                            stream: globalAudioPlayer.positionStream,
                            builder: (context, posSnapshot) {
                              final position =
                                  posSnapshot.data ??
                                  globalAudioPlayer.position;
                              final duration = globalAudioPlayer.duration;
                              final max = duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0;
                              final value = position.inMilliseconds
                                  .clamp(0, max.toInt())
                                  .toDouble();
                              final buffered = globalAudioPlayer
                                  .bufferedPosition
                                  .inMilliseconds
                                  .clamp(0, max.toInt())
                                  .toDouble();
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  6,
                                  24,
                                  0,
                                ),
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3,
                                        inactiveTrackColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: .12),
                                        secondaryActiveTrackColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: .20),
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 15,
                                            ),
                                      ),
                                      child: Slider(
                                        value: value,
                                        max: max,
                                        secondaryTrackValue: buffered,
                                        onChanged: duration.inMilliseconds > 0
                                            ? (v) => globalAudioPlayer.seek(
                                                Duration(
                                                  milliseconds: v.round(),
                                                ),
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
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _clock(duration),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
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
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  tooltip: 'Previous / restart',
                                  iconSize: 32,
                                  icon: const Icon(Icons.skip_previous_rounded),
                                  onPressed: globalAudioPlayer.active
                                      ? globalAudioPlayer.skipToPrevious
                                      : null,
                                ),
                                _PlayControl(
                                  playing: playing,
                                  loading: loading,
                                  enabled: globalAudioPlayer.active,
                                  onPressed: () => _toggle(context, playing),
                                ),
                                IconButton(
                                  tooltip: 'Next surah',
                                  iconSize: 32,
                                  icon: const Icon(Icons.skip_next_rounded),
                                  onPressed: globalAudioPlayer.active
                                      ? globalAudioPlayer.skipToNext
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onInfo});

  final VoidCallback onClose;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GlassIconButton(
                icon: Icons.keyboard_arrow_down_rounded,
                tooltip: 'Close player',
                onPressed: onClose,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Quriva recitation',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant.withValues(alpha: .75),
                      ),
                    ),
                  ],
                ),
              ),
              GlassIconButton(
                icon: Icons.info_outline_rounded,
                tooltip: 'Surah info',
                onPressed: onInfo,
              ),
            ],
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
    final size = (width * .68).clamp(210.0, 340.0);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size + 36,
      height: size + 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .86,
            height: size * .86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.onSurface.withValues(alpha: .18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: .22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .42),
                  blurRadius: 48,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Stack(
                children: [
                  Hero(
                    tag: 'now-playing-artwork',
                    child: LandscapeArtwork(size: size, radius: 34),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: .16),
                            Colors.transparent,
                            Colors.black.withValues(alpha: .18),
                          ],
                          stops: const [0, .45, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: GlassChip(
                      label: 'HOLY QURAN',
                      icon: Icons.menu_book_rounded,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsCard extends StatelessWidget {
  const _LyricsCard({
    required this.verses,
    required this.surahId,
    required this.totalVerses,
  });

  final List<Verse> verses;
  final int? surahId;
  final int? totalVerses;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
        final total = totalVerses ?? verses.length;
        final fraction = active == null || total == 0
            ? 0.0
            : (active.verseNumber / total).clamp(0.0, 1.0);
        return GlassPanel(
          radius: 24,
          blur: 20,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            children: [
              Row(
                children: [
                  EqualizerBars(
                    active: globalAudioPlayer.playing,
                    height: 12,
                    barWidth: 2.2,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    active == null
                        ? 'AYAH HIGHLIGHT'
                        : 'AYAH ${active.verseNumber} / $total',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (active != null) ...[
                    _AyahStepButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous ayah',
                      onPressed: active.verseNumber > 1
                          ? () => globalAudioPlayer.seekToVerse(
                              active.verseNumber - 1,
                            )
                          : null,
                    ),
                    _AyahStepButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next ayah',
                      onPressed: active.verseNumber < total
                          ? () => globalAudioPlayer.seekToVerse(
                              active.verseNumber + 1,
                            )
                          : null,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              GlassProgressLine(
                value: fraction,
                height: 2,
                active: active != null,
              ),
              const SizedBox(height: 14),
              if (arabic.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Play a surah to follow along, ayah by ayah.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                  ),
                )
              else ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  child: Text(
                    arabic,
                    key: ValueKey(active?.verseKey),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.85,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: Text(
                      translation,
                      key: ValueKey('t-${active?.verseKey}'),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.55,
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

class _AyahStepButton extends StatelessWidget {
  const _AyahStepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 18,
      blur: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      onTap: onTap,
      child: Row(
        children: [
          const GlassBadge(
            size: 30,
            child: Icon(Icons.queue_music_rounded, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.skip_next_rounded, size: 18),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: GlassPanel(
        radius: 16,
        blur: 0,
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 17, color: scheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(onPressed: () => onRetry(), child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PlayControl extends StatelessWidget {
  const _PlayControl({
    required this.playing,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final bool playing;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: CircularProgressIndicator(
              value: loading ? null : 1,
              strokeWidth: 2.5,
              color: scheme.onSurface.withValues(alpha: .22),
            ),
          ),
          SizedBox(
            width: 68,
            height: 68,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              onPressed: enabled && !loading ? onPressed : null,
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 36,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
