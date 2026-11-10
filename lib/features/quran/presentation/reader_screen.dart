import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/utils/text_utils.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.surahId, this.anchorVerse, super.key});

  final int surahId;

  /// Optional verse number to open and highlight (used from search results).
  final int? anchorVerse;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  bool _didAnchorJump = false;
  bool _hideBar = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_saveProgress);
  }

  void _saveProgress() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b)
        .index;
    if (first < 2) return;
    unawaited(
      ref.read(databaseProvider).saveProgress(widget.surahId, first),
    );
  }

  void _jumpToAnchorOnce() {
    final anchor = widget.anchorVerse;
    if (_didAnchorJump || anchor == null || anchor < 1) return;
    _didAnchorJump = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _itemScrollController.jumpTo(index: anchor);
    });
  }

  String _titleFor(int surahId) {
    final language = ref.read(appLanguageProvider);
    final chapters = ref.read(chaptersProvider(language)).value;
    for (final chapter in chapters ?? const <Chapter>[]) {
      if (chapter.id == surahId) return chapter.nameSimple;
    }
    return 'Surah $surahId';
  }

  Future<NextSurah?> _resolveNext(int nextSurahId, int recitationId) async {
    try {
      final catalog =
          await ref.read(reciterCatalogProvider(recitationId).future);
      final url = catalog[nextSurahId];
      if (url == null || url.isEmpty) return null;
      final title = _titleFor(nextSurahId);
      final reciters = ref.read(recitersProvider('en')).value;
      final reciter = reciterNameFor(reciters, recitationId);
      return NextSurah(
        surahId: nextSurahId,
        url: url,
        item: MediaItem(
          id: url,
          album: 'Quriva',
          title: title,
          artist: reciter,
          playable: true,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _toggleSurahAudio({
    required String? url,
    required String surahTitle,
    required String reciterName,
    required int recitationId,
  }) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio not available for this surah/reciter.'),
        ),
      );
      return;
    }
    final item = MediaItem(
      id: url,
      album: 'Quriva',
      title: surahTitle,
      artist: reciterName,
      playable: true,
    );
    unawaited(
      globalAudioPlayer.toggleSurah(
        url: url,
        item: item,
        surahId: widget.surahId,
        recitationId: recitationId,
        nextResolver: _resolveNext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationId = ref.watch(translationIdProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final surah = ref.watch(readerProvider((widget.surahId, translationId)));
    final reciters = ref.watch(recitersProvider('en'));
    final catalog = ref.watch(reciterCatalogProvider(reciterId));
    final reciterName = reciterNameFor(reciters.value, reciterId);
    final surahTitle = resolveSurahTitle(ref, widget.surahId);
    final audioUrl = catalog.value?[widget.surahId];

    return Scaffold(
      appBar: AppBar(
        title: Text(surahTitle.split(' · ').first),
        actions: [
          IconButton(
            tooltip: 'Surah info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => context.push('/surah-info/${widget.surahId}'),
          ),
        ],
      ),
      body: surah.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ReaderError(
          message: '$error',
          onRetry: () =>
              ref.invalidate(readerProvider((widget.surahId, translationId))),
        ),
        data: (verses) {
          _jumpToAnchorOnce();
          final bookmarks =
              ref.watch(bookmarksProvider).value ?? const <Bookmark>[];
          final bookmarked = {
            for (final item in bookmarks) item.verseId,
          };
          final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
          return StreamBuilder<PlayerState>(
            stream: globalAudioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final activeThisSurah =
                  globalAudioPlayer.currentSurahId == widget.surahId;
              final processing = snapshot.data?.processingState;
              final buffering = activeThisSurah &&
                  (processing == ProcessingState.loading ||
                      processing == ProcessingState.buffering);
              final showBar = globalAudioPlayer.active && !_hideBar;
              return Stack(
                children: [
                  ScrollablePositionedList.builder(
                    itemCount: verses.length + 1,
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: EdgeInsets.fromLTRB(
                      14,
                      8,
                      14,
                      showBar ? 110 + bottomInset : 32 + bottomInset,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _SurahHeader(
                          title: surahTitle,
                          reciterName: reciterName,
                          audioAvailable:
                              audioUrl != null && audioUrl.isNotEmpty,
                          playing: playing && activeThisSurah,
                          buffering: buffering,
                          onPlay: () => _toggleSurahAudio(
                            url: audioUrl,
                            surahTitle: surahTitle.split(' · ').first,
                            reciterName: reciterName,
                            recitationId: reciterId,
                          ),
                        );
                      }
                      final verse = verses[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _VerseCard(
                          verse: verse,
                          isBookmarked: bookmarked.contains(verse.number),
                          isAnchor: widget.anchorVerse == verse.number,
                          fontSize: fontSize,
                          isPlaying: playing && activeThisSurah,
                          audioAvailable:
                              audioUrl != null && audioUrl.isNotEmpty,
                          onToggleBookmark: () => ref
                              .read(databaseProvider)
                              .toggleBookmark(widget.surahId, verse.number),
                          onPlay: () => _toggleSurahAudio(
                            url: audioUrl,
                            surahTitle: surahTitle.split(' · ').first,
                            reciterName: reciterName,
                            recitationId: reciterId,
                          ),
                        ),
                      );
                    },
                  ),
                  if (showBar)
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12 + bottomInset,
                      child: _NowPlayingBar(
                        onHide: () => setState(() => _hideBar = true),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String resolveSurahTitle(WidgetRef ref, int surahId) {
  final language = ref.watch(appLanguageProvider);
  final chapters = ref.watch(chaptersProvider(language)).value;
  for (final chapter in chapters ?? const <Chapter>[]) {
    if (chapter.id == surahId) {
      return '${chapter.nameSimple} · ${chapter.translatedName}';
    }
  }
  return 'Surah $surahId';
}

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.onHide});

  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: globalAudioPlayer.playerStateStream,
      initialData: null,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? globalAudioPlayer.playing;
        final item = globalAudioPlayer.currentItem;
        final surahId = globalAudioPlayer.currentSurahId;
        final reciterId = globalAudioPlayer.currentRecitationId;
        final title = item?.title ??
            (surahId != null ? 'Surah $surahId' : 'Recitation');
        final artist = item?.artist ?? '';
        return GlassPanel(
          radius: 22,
          blur: 18,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              GlassBadge(
                child: Icon(
                  playing ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (artist.isNotEmpty)
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: () async {
                  if (playing) {
                    await globalAudioPlayer.pause();
                  } else {
                    final url = globalAudioPlayer.currentUrl;
                    final currentItem = globalAudioPlayer.currentItem;
                    if (url != null && currentItem != null) {
                      await globalAudioPlayer.playSurah(
                        url: url,
                        item: currentItem,
                        surahId: surahId,
                        recitationId: reciterId,
                      );
                    }
                  }
                },
              ),
              IconButton(
                tooltip: 'Hide player',
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onHide,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.title,
    required this.reciterName,
    required this.audioAvailable,
    required this.playing,
    required this.buffering,
    required this.onPlay,
  });

  final String title;
  final String reciterName;
  final bool audioAvailable;
  final bool playing;
  final bool buffering;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final parts = title.split(' · ');
    final latin = parts.isEmpty ? 'Surah' : parts.first;
    final arabic = parts.length > 1 ? parts.last : '';
    return GlassPanel(
      radius: 26,
      blur: 0,
      child: Column(
        children: [
          if (arabic.isNotEmpty)
            Text(
              arabic,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          const SizedBox(height: 4),
          Text(latin, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (buffering)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton.filledTonal(
                  tooltip: playing ? 'Pause surah' : 'Play surah',
                  onPressed: audioAvailable ? onPlay : null,
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  audioAvailable
                      ? (playing ? 'Playing · $reciterName' : reciterName)
                      : 'Audio unavailable for this reciter',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.verse,
    required this.isBookmarked,
    required this.isAnchor,
    required this.fontSize,
    required this.isPlaying,
    required this.audioAvailable,
    required this.onToggleBookmark,
    required this.onPlay,
  });

  final Verse verse;
  final bool isBookmarked;
  final bool isAnchor;
  final double fontSize;
  final bool isPlaying;
  final bool audioAvailable;
  final VoidCallback onToggleBookmark;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final translation = cleanTranslationText(verse.translation);
    return GlassPanel(
      radius: 22,
      blur: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GlassBadge(child: Text('${verse.number}')),
              const Spacer(),
              IconButton(
                tooltip: isPlaying ? 'Pause audio' : 'Play surah audio',
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                ),
                onPressed: audioAvailable ? onPlay : null,
              ),
              IconButton(
                tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
                ),
                onPressed: onToggleBookmark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            verse.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: fontSize,
              height: 2,
              color: scheme.onSurface,
            ),
          ),
          if (translation.isNotEmpty) ...[
            const SizedBox(height: 14),
            SelectableText(
              translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56),
            const SizedBox(height: 16),
            Text(
              'Could not load verses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
