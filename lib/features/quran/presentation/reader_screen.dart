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
  bool _barHidden = false;

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

  Future<void> _openAudioSheet(
    BuildContext context,
    String surahTitle,
    String reciterName,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _AudioSheet(
        surahId: widget.surahId,
        surahTitle: surahTitle,
        reciterName: reciterName,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final translationId = ref.watch(translationIdProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final surah = ref.watch(readerProvider((widget.surahId, translationId)));
    final reciters = ref.watch(recitersProvider('en'));
    final reciterName = reciterNameFor(reciters.value, reciterId);
    final surahTitle = resolveSurahTitle(ref, widget.surahId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Surah ${widget.surahId}'),
        actions: [
          IconButton(
            tooltip: 'Play surah audio',
            icon: const Icon(Icons.headphones_rounded),
            onPressed: surah.hasValue
                ? () => _openAudioSheet(context, surahTitle, reciterName)
                : null,
          ),
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
          return Stack(
            children: [
              ScrollablePositionedList.builder(
                itemCount: verses.length + 1,
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _SurahHeader(title: surahTitle);
                  }
                  final verse = verses[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _VerseCard(
                      verse: verse,
                      isBookmarked: bookmarked.contains(verse.number),
                      isAnchor: widget.anchorVerse == verse.number,
                      fontSize: fontSize,
                      onToggleBookmark: () => ref
                          .read(databaseProvider)
                          .toggleBookmark(widget.surahId, verse.number),
                    ),
                  );
                },
              ),
              if (globalAudioPlayer.active && !_barHidden)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: _FloatingAudioBar(
                    onHide: () => setState(() => _barHidden = true),
                  ),
                ),
            ],
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

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final parts = title.split(' · ');
    final latin = parts.isEmpty ? 'Surah' : parts.first;
    final arabic = parts.length > 1 ? parts.last : '';
    return GlassPanel(
      radius: 26,
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
    required this.onToggleBookmark,
  });

  final Verse verse;
  final bool isBookmarked;
  final bool isAnchor;
  final double fontSize;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassPanel(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GlassBadge(child: Text('${verse.number}')),
              const Spacer(),
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
            style: TextStyle(fontSize: fontSize, height: 2, color: scheme.onSurface),
          ),
          if (verse.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            SelectableText(
              verse.translation,
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

/// Floating frosted mini player, pinned to the bottom of the reader while a
/// recitation is loaded. Reflects whatever the *global* player is doing —
/// including a surah loaded from another screen.
class _FloatingAudioBar extends StatelessWidget {
  const _FloatingAudioBar({required this.onHide});

  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final url = globalAudioPlayer.currentUrl;
    final item = globalAudioPlayer.currentItem;
    return StreamBuilder<bool>(
      stream: globalAudioPlayer.playingStream,
      initialData: globalAudioPlayer.playing,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return GlassPanel(
          radius: 24,
          blur: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                child: Text(
                  item?.title ?? 'Recitation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              IconButton(
                tooltip: playing ? 'Pause' : 'Play',
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: (url == null || item == null)
                    ? null
                    : () => globalAudioPlayer.toggle(url, item),
              ),
              IconButton(
                tooltip: 'Hide mini player',
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

class _AudioSheet extends ConsumerWidget {
  const _AudioSheet({
    required this.surahId,
    required this.surahTitle,
    required this.reciterName,
  });

  final int surahId;
  final String surahTitle;
  final String reciterName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciterId = ref.watch(reciterIdProvider);
    final catalog = ref.watch(reciterCatalogProvider(reciterId));
    final url = catalog.value?[surahId];
    final item = url == null
        ? null
        : MediaItem(
            id: url,
            album: 'Quriva',
            title: surahTitle,
            artist: reciterName,
            playable: true,
          );

    return StreamBuilder<PlayerState>(
      stream: globalAudioPlayer.playerStateStream,
      builder: (context, stateSnapshot) {
        final playing = stateSnapshot.data?.playing ?? false;
        final processing = stateSnapshot.data?.processingState;
        return StreamBuilder<Duration>(
          stream: globalAudioPlayer.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final durationMs = globalAudioPlayer.duration.inMilliseconds;
            final max = durationMs > 0 ? durationMs.toDouble() : 1.0;
            final positionMs = position.inMilliseconds
                .clamp(0, durationMs > 0 ? durationMs : 1);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(surahTitle,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    reciterName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: positionMs.toDouble().clamp(0, max),
                    max: max,
                    onChanged: durationMs > 0
                        ? (value) => globalAudioPlayer.seek(
                              Duration(milliseconds: value.round()),
                            )
                        : null,
                  ),
                  Row(
                    children: [
                      Text(_clock(position)),
                      const Spacer(),
                      Text(_clock(globalAudioPlayer.duration)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  IconButton.filled(
                    tooltip: playing ? 'Pause' : 'Play',
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: (url == null || item == null)
                        ? null
                        : () => globalAudioPlayer.toggle(url, item),
                  ),
                  if (url == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'This surah is not available on the selected reciter.',
                      ),
                    ),
                  if (processing == ProcessingState.loading ||
                      processing == ProcessingState.buffering)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _clock(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
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
