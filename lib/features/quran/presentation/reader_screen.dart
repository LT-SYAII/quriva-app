import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
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
  ChapterAudioPlayer? _audioPlayer;
  bool _didAnchorJump = false;
  bool _showAudioBar = false;

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
    if (first < 2) return; // index 0 = header, 1 = first verse still at top.
    unawaited(
      ref.read(databaseProvider).saveProgress(widget.surahId, first),
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_saveProgress);
    _audioPlayer?.dispose();
    super.dispose();
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

  Future<void> _openAudioSheet() async {
    setState(() => _showAudioBar = true);
    final player = _audioPlayer ?? (_audioPlayer = ChapterAudioPlayer());
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _AudioSheet(
        player: player,
        surahId: widget.surahId,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Surah ${widget.surahId}'),
        actions: [
          IconButton(
            tooltip: 'Play surah audio',
            icon: const Icon(Icons.headphones_outlined),
            onPressed: surah.hasValue ? _openAudioSheet : null,
          ),
          IconButton(
            tooltip: 'Surah info',
            icon: const Icon(Icons.info_outline),
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
          return Column(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemCount: verses.length + 1,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final title = resolveSurahTitle(context, ref, widget.surahId);
                      return _SurahHeader(title: title);
                    }
                    final verse = verses[index - 1];
                    return _VerseCard(
                      verse: verse,
                      isBookmarked: bookmarked.contains(verse.number),
                      isAnchor: widget.anchorVerse == verse.number,
                      fontSize: fontSize,
                      onToggleBookmark: () => ref
                          .read(databaseProvider)
                          .toggleBookmark(widget.surahId, verse.number),
                    );
                  },
                ),
              ),
              if (_showAudioBar && _audioPlayer != null)
                _AudioBar(
                  player: _audioPlayer!,
                  surahId: widget.surahId,
                  reciterId: reciterId,
                  onClose: () {
                    unawaited(_audioPlayer!.pause());
                    setState(() => _showAudioBar = false);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

String resolveSurahTitle(BuildContext context, WidgetRef ref, int surahId) {
  final language = ref.watch(appLanguageProvider);
  final chapters = ref.watch(chaptersProvider(language)).value;
  for (final chapter in chapters ?? const <Chapter>[]) {
    if (chapter.id == surahId) {
      return '${chapter.nameSimple} · ${chapter.nameArabic}';
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
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (arabic.isNotEmpty)
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            if (arabic.isNotEmpty) const SizedBox(height: 8),
            Text(latin, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isAnchor ? scheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primary.withValues(alpha: .12),
                  foregroundColor: scheme.primary,
                  child: Text(
                    '${verse.number}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
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
              style: TextStyle(fontSize: fontSize, height: 2),
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
      ),
    );
  }
}

class _AudioBar extends ConsumerWidget {
  const _AudioBar({
    required this.player,
    required this.surahId,
    required this.reciterId,
    required this.onClose,
  });

  final ChapterAudioPlayer player;
  final int surahId;
  final int reciterId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<bool>(
      stream: player.playerStateStream.map((state) => state.playing),
      initialData: false,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: playing ? 'Pause' : 'Play',
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  final url = await ref.read(
                    chapterAudioUrlProvider((surahId, reciterId)).future,
                  );
                  if (url != null) await player.toggle(url);
                },
              ),
              IconButton(
                tooltip: 'Stop & hide',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
              Expanded(
                child: Text(
                  playing
                      ? 'Playing surah audio (reciter #$reciterId)'
                      : 'Audio paused',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Controls',
                icon: const Icon(Icons.queue_music_outlined),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (context) => _AudioSheet(
                    player: player,
                    surahId: surahId,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AudioSheet extends ConsumerWidget {
  const _AudioSheet({required this.player, required this.surahId});

  final ChapterAudioPlayer player;
  final int surahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciterId = ref.watch(reciterIdProvider);
    final audioUrl = ref.watch(chapterAudioUrlProvider((surahId, reciterId)));
    final resolvedUrl = audioUrl.value;

    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, stateSnapshot) {
        final playing = stateSnapshot.data?.playing ?? false;
        final processing = stateSnapshot.data?.processingState;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final durationMs = player.duration.inMilliseconds;
            final max =
                durationMs > 0 ? durationMs.toDouble() : 1.0;
            final positionMs = position.inMilliseconds.clamp(0, durationMs > 0 ? durationMs : 1);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Surah audio',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Reciter #$reciterId'),
                  const SizedBox(height: 12),
                  Slider(
                    value: positionMs.toDouble().clamp(0, max),
                    max: max,
                    onChanged: durationMs > 0
                        ? (value) => player.seek(
                              Duration(milliseconds: value.round()),
                            )
                        : null,
                  ),
                  Row(
                    children: [
                      Text(_clock(position)),
                      const Spacer(),
                      Text(_clock(player.duration)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        tooltip: playing ? 'Pause' : 'Play',
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        onPressed: resolvedUrl == null
                            ? null
                            : () => player.toggle(resolvedUrl),
                      ),
                    ],
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
            const Icon(Icons.cloud_off_outlined, size: 56),
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
