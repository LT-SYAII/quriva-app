import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quriva/app/theme.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/utils/text_utils.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';
import 'package:quriva/shared/widgets/ui_kit.dart';
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
  int? _lastAutoScrolledVerse;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_saveProgress);
    globalAudioPlayer.activeVerse.addListener(_onActiveVerseChanged);
  }

  @override
  void dispose() {
    globalAudioPlayer.activeVerse.removeListener(_onActiveVerseChanged);
    _itemPositionsListener.itemPositions.removeListener(_saveProgress);
    super.dispose();
  }

  void _onActiveVerseChanged() {
    final active = globalAudioPlayer.activeVerse.value;
    if (!mounted || active == null) return;
    if (active.chapterId != widget.surahId) return;
    if (!globalAudioPlayer.playing) return;
    if (_lastAutoScrolledVerse == active.verseNumber) return;
    _lastAutoScrolledVerse = active.verseNumber;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_itemScrollController.isAttached) return;
      _itemScrollController.scrollTo(
        index: active.verseNumber,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
        alignment: .12,
      );
    });
  }

  DateTime? _lastProgressSave;
  int? _lastSavedVerse;

  void _saveProgress() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b)
        .index;
    if (first < 2) return;
    final now = DateTime.now();
    if (_lastSavedVerse == first &&
        _lastProgressSave != null &&
        now.difference(_lastProgressSave!) < const Duration(seconds: 2)) {
      return;
    }
    _lastSavedVerse = first;
    _lastProgressSave = now;
    unawaited(ref.read(databaseProvider).saveProgress(widget.surahId, first));
  }

  void _jumpToAnchorOnce() {
    final anchor = widget.anchorVerse;
    if (_didAnchorJump || anchor == null || anchor < 1) return;
    _didAnchorJump = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_itemScrollController.isAttached) return;
      _itemScrollController.jumpTo(index: anchor);
    });
  }

  void _scrollToActiveVerse() {
    final active = globalAudioPlayer.activeVerse.value;
    if (active == null || active.chapterId != widget.surahId) return;
    if (!_itemScrollController.isAttached) return;
    _itemScrollController.scrollTo(
      index: active.verseNumber,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      alignment: .12,
    );
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
      final timeline = await ref.read(
        chapterAudioTimelineProvider((nextSurahId, recitationId)).future,
      );
      final url = timeline.audioUrl;
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
        timeline: timeline.timestamps,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleSurahAudio({
    required String? url,
    required String? fallbackUrl,
    required String surahTitle,
    required String reciterName,
    required int recitationId,
    required List<VerseTimestamp> timeline,
  }) async {
    if (url == null || url.isEmpty) {
      _showAudioMessage(
        'Audio is not available for this surah and reciter yet.',
      );
      return;
    }
    if (!mounted) return;
    final item = MediaItem(
      id: url,
      album: 'Quriva',
      title: surahTitle,
      artist: reciterName,
      playable: true,
    );
    final ok = await globalAudioPlayer.toggleSurah(
      url: url,
      item: item,
      surahId: widget.surahId,
      recitationId: recitationId,
      nextResolver: _resolveNext,
      timeline: timeline,
      fallbackUrl: fallbackUrl,
    );
    if (!mounted || ok) return;
    final message =
        globalAudioPlayer.error.value ??
        'Could not load the recitation. Check your connection.';
    _showAudioMessage(
      message,
      retry: () => _toggleSurahAudio(
        url: url,
        fallbackUrl: fallbackUrl,
        surahTitle: surahTitle,
        reciterName: reciterName,
        recitationId: recitationId,
        timeline: timeline,
      ),
    );
  }

  void _showAudioMessage(String message, {VoidCallback? retry}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: retry == null
            ? null
            : SnackBarAction(label: 'Retry', onPressed: retry),
      ),
    );
  }

  void _showTypographySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _TypographySheet(
        initialSize: ref.read(arabicFontSizeProvider),
        onChanged: (value) =>
            ref.read(arabicFontSizeProvider.notifier).setSize(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final translationId = ref.watch(translationIdProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final surah = ref.watch(readerProvider((widget.surahId, translationId)));
    final reciters = ref.watch(recitersProvider('en'));
    final chapters = ref.watch(chaptersProvider(language));
    final catalog = ref.watch(reciterCatalogProvider(reciterId));
    final directAudio = ref.watch(
      chapterAudioUrlProvider((widget.surahId, reciterId)),
    );
    final timelineAsync = ref.watch(
      chapterAudioTimelineProvider((widget.surahId, reciterId)),
    );

    final reciterName = reciterNameFor(reciters.value, reciterId);
    final chapter = chapters.value
        ?.where((item) => item.id == widget.surahId)
        .firstOrNull;
    final surahTitle = chapter == null
        ? _titleFor(widget.surahId)
        : '${chapter.nameSimple} · ${chapter.translatedName}';

    final catalogUrl = catalog.value?[widget.surahId];
    final directUrl = directAudio.value;
    final timelineUrl = timelineAsync.value?.audioUrl;
    final candidates = [
      directUrl,
      timelineUrl,
      catalogUrl,
    ].whereType<String>().where((url) => url.isNotEmpty).toList();
    final audioUrl = candidates.firstOrNull;
    final fallbackUrl = candidates.where((url) => url != audioUrl).firstOrNull;
    final timeline =
        timelineAsync.value?.timestamps ?? const <VerseTimestamp>[];
    final audioLoading =
        (audioUrl == null || audioUrl.isEmpty) &&
        (directAudio.isLoading || catalog.isLoading || timelineAsync.isLoading);
    final audioUnavailable =
        (audioUrl == null || audioUrl.isEmpty) &&
        !audioLoading &&
        (directAudio.hasError || catalog.hasError || timelineAsync.hasError);

    ref.listen<AsyncValue<ChapterAudioTimeline>>(
      chapterAudioTimelineProvider((widget.surahId, reciterId)),
      (previous, next) {
        final data = next.value;
        if (data == null || data.timestamps.isEmpty) return;
        if (globalAudioPlayer.currentSurahId == widget.surahId &&
            globalAudioPlayer.currentRecitationId == reciterId) {
          globalAudioPlayer.setTimeline(data.timestamps);
        }
      },
    );

    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          final bookmarked = {for (final item in bookmarks) item.verseId};
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          return ValueListenableBuilder<PlaybackStatus>(
            valueListenable: globalAudioPlayer.status,
            builder: (context, playbackStatus, _) {
              return StreamBuilder<PlayerState>(
                stream: globalAudioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playing =
                      snapshot.data?.playing ?? globalAudioPlayer.playing;
                  final activeThisSurah =
                      globalAudioPlayer.currentSurahId == widget.surahId;
                  final processing = snapshot.data?.processingState;
                  final buffering =
                      activeThisSurah &&
                      (globalAudioPlayer.loading ||
                          processing == ProcessingState.loading ||
                          processing == ProcessingState.buffering);
                  final showBar =
                      globalAudioPlayer.active && !_hideBar && !buffering;
                  return Stack(
                    children: [
                      ValueListenableBuilder<VerseTimestamp?>(
                        valueListenable: globalAudioPlayer.activeVerse,
                        builder: (context, active, _) {
                          final activeNumber =
                              (active != null &&
                                  active.chapterId == widget.surahId)
                              ? active.verseNumber
                              : null;
                          return ScrollablePositionedList.builder(
                            itemCount: verses.length + 1,
                            itemScrollController: _itemScrollController,
                            itemPositionsListener: _itemPositionsListener,
                            padding: EdgeInsets.fromLTRB(
                              14,
                              topInset + 84,
                              14,
                              showBar ? 132 + bottomInset : 32 + bottomInset,
                            ),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _SurahHero(
                                  chapter: chapter,
                                  surahTitle: surahTitle,
                                  reciterName: reciterName,
                                  playing: playing && activeThisSurah,
                                  buffering: buffering,
                                  audioAvailable:
                                      audioUrl != null && audioUrl.isNotEmpty,
                                  audioLoading: audioLoading,
                                  audioUnavailable: audioUnavailable,
                                  timeline: timeline,
                                  onPlay: () => _toggleSurahAudio(
                                    url: audioUrl,
                                    fallbackUrl: fallbackUrl,
                                    surahTitle: surahTitle.split(' · ').first,
                                    reciterName: reciterName,
                                    recitationId: reciterId,
                                    timeline: timeline,
                                  ),
                                );
                              }
                              final verse = verses[index - 1];
                              final isActive = activeNumber == verse.number;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: _VerseCard(
                                  verse: verse,
                                  totalVerses: verses.length,
                                  isBookmarked: bookmarked.contains(
                                    verse.number,
                                  ),
                                  isAnchor: widget.anchorVerse == verse.number,
                                  isActive: isActive,
                                  isPlaying:
                                      isActive && playing && activeThisSurah,
                                  fontSize: fontSize,
                                  audioAvailable:
                                      audioUrl != null && audioUrl.isNotEmpty,
                                  onToggleBookmark: () => ref
                                      .read(databaseProvider)
                                      .toggleBookmark(
                                        widget.surahId,
                                        verse.number,
                                      ),
                                  onPlay: () => _toggleSurahAudio(
                                    url: audioUrl,
                                    fallbackUrl: fallbackUrl,
                                    surahTitle: surahTitle.split(' · ').first,
                                    reciterName: reciterName,
                                    recitationId: reciterId,
                                    timeline: timeline,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: _ReaderTopBar(
                            title:
                                chapter?.nameSimple ??
                                'Surah ${widget.surahId}',
                            subtitle: reciterName,
                            onBack: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                            onTypography: _showTypographySheet,
                            onInfo: () =>
                                context.push('/surah-info/${widget.surahId}'),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12 + bottomInset,
                        child: AnimatedSlide(
                          offset: showBar ? Offset.zero : const Offset(0, 1.4),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: showBar ? 1 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: _NowPlayingBar(
                              onHide: () => setState(() => _hideBar = true),
                              onLocate: _scrollToActiveVerse,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onTypography,
    required this.onInfo,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onTypography;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: GlassPanel(
        radius: 24,
        blur: 0,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: onBack,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: .1,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Text size',
              icon: const Icon(Icons.text_fields_rounded, size: 20),
              onPressed: onTypography,
            ),
            IconButton(
              tooltip: 'Surah info',
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              onPressed: onInfo,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahHero extends StatelessWidget {
  const _SurahHero({
    required this.chapter,
    required this.surahTitle,
    required this.reciterName,
    required this.playing,
    required this.buffering,
    required this.audioAvailable,
    required this.audioLoading,
    required this.audioUnavailable,
    required this.timeline,
    required this.onPlay,
  });

  final Chapter? chapter;
  final String surahTitle;
  final String reciterName;
  final bool playing;
  final bool buffering;
  final bool audioAvailable;
  final bool audioLoading;
  final bool audioUnavailable;
  final List<VerseTimestamp> timeline;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final parts = surahTitle.split(' · ');
    final latin = parts.isEmpty ? 'Surah' : parts.first;
    final translated = parts.length > 1 ? parts.last : '';
    final revelation = chapter?.revelationPlace ?? '';
    final revelationLabel = revelation.isEmpty
        ? ''
        : '${revelation[0].toUpperCase()}${revelation.substring(1)}';
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: QurivaTheme.dark,
      child: Builder(
        builder: (context) => ClipRRect(
          borderRadius: BorderRadius.circular(30),
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
                        Colors.black.withValues(alpha: .10),
                        Colors.black.withValues(alpha: .34),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassChip(
                          label: 'SURAH ${chapter?.id ?? ''}'.trim(),
                          dense: true,
                        ),
                        const Spacer(),
                        if (revelationLabel.isNotEmpty)
                          GlassChip(
                            label: revelationLabel,
                            icon: Icons.place_outlined,
                            dense: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      chapter?.nameArabic ?? '',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 42,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      latin,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.4,
                          ),
                    ),
                    if (translated.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        translated,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (chapter != null)
                          GlassChip(
                            label: '${chapter!.versesCount} ayat',
                            icon: Icons.format_list_numbered_rounded,
                            dense: true,
                          ),
                        GlassChip(
                          label: reciterName,
                          icon: Icons.graphic_eq_rounded,
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HeroPlayButton(
                          playing: playing,
                          buffering: buffering,
                          enabled: audioAvailable,
                          loading: audioLoading,
                          onPressed: onPlay,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audioUnavailable
                                    ? 'Audio unavailable'
                                    : playing
                                    ? 'Now reciting'
                                    : audioLoading
                                    ? 'Preparing recitation…'
                                    : 'Listen to this surah',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                audioUnavailable
                                    ? 'Try another reciter in settings.'
                                    : audioLoading
                                    ? 'Finding the best audio source…'
                                    : timeline.isNotEmpty
                                    ? 'Ayah-by-ayah follow-along enabled'
                                    : 'Chapter recitation',
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPlayButton extends StatelessWidget {
  const _HeroPlayButton({
    required this.playing,
    required this.buffering,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool playing;
  final bool buffering;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: enabled && !buffering ? onPressed : null,
        child: buffering
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : Icon(
                playing
                    ? Icons.pause_rounded
                    : loading
                    ? Icons.downloading_rounded
                    : Icons.play_arrow_rounded,
                size: 30,
              ),
      ),
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.onHide, required this.onLocate});

  final VoidCallback onHide;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: globalAudioPlayer.playerStateStream,
      initialData: null,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? globalAudioPlayer.playing;
        final processing = snapshot.data?.processingState;
        final buffering =
            globalAudioPlayer.loading ||
            processing == ProcessingState.loading ||
            processing == ProcessingState.buffering;
        final item = globalAudioPlayer.currentItem;
        final surahId = globalAudioPlayer.currentSurahId;
        final reciterId = globalAudioPlayer.currentRecitationId;
        final title =
            item?.title ?? (surahId != null ? 'Surah $surahId' : 'Recitation');
        final artist = item?.artist ?? '';
        return GlassPanel(
          radius: 24,
          blur: 0,
          padding: EdgeInsets.zero,
          onTap: () => context.push('/now-playing'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
                child: Row(
                  children: [
                    const Hero(
                      tag: 'now-playing-artwork',
                      child: LandscapeArtwork(size: 46, radius: 13),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              EqualizerBars(
                                active: playing,
                                height: 11,
                                barWidth: 2,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          ValueListenableBuilder<VerseTimestamp?>(
                            valueListenable: globalAudioPlayer.activeVerse,
                            builder: (context, active, _) {
                              final ayah = active?.chapterId == surahId
                                  ? 'Ayah ${active!.verseNumber}'
                                  : '';
                              return Text(
                                [
                                  if (ayah.isNotEmpty) ayah,
                                  artist,
                                ].where((part) => part.isNotEmpty).join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
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
                      tooltip: 'Jump to current ayah',
                      icon: const Icon(Icons.my_location_rounded, size: 19),
                      onPressed: onLocate,
                    ),
                    IconButton(
                      tooltip: playing ? 'Pause' : 'Play',
                      icon: buffering
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                      onPressed: buffering
                          ? null
                          : () async {
                              if (playing) {
                                await globalAudioPlayer.pause();
                              } else {
                                final url = globalAudioPlayer.currentUrl;
                                final currentItem =
                                    globalAudioPlayer.currentItem;
                                if (url != null && currentItem != null) {
                                  final ok = await globalAudioPlayer.playSurah(
                                    url: url,
                                    item: currentItem,
                                    surahId: surahId,
                                    recitationId: reciterId,
                                  );
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          globalAudioPlayer.error.value ??
                                              'Could not resume playback.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                    ),
                    IconButton(
                      tooltip: 'Next surah',
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: globalAudioPlayer.skipToNext,
                    ),
                    IconButton(
                      tooltip: 'Hide player',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: onHide,
                    ),
                  ],
                ),
              ),
              StreamBuilder<Duration>(
                stream: globalAudioPlayer.positionStream,
                builder: (context, posSnapshot) {
                  final total = globalAudioPlayer.duration.inMilliseconds;
                  final ms = posSnapshot.data?.inMilliseconds ?? 0;
                  final value = total > 0 ? (ms / total).clamp(0.0, 1.0) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: GlassProgressLine(
                      value: processing == ProcessingState.completed
                          ? 1
                          : value,
                      height: 2.5,
                      active: true,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.verse,
    required this.totalVerses,
    required this.isBookmarked,
    required this.isAnchor,
    required this.isActive,
    required this.isPlaying,
    required this.fontSize,
    required this.audioAvailable,
    required this.onToggleBookmark,
    required this.onPlay,
  });

  final Verse verse;
  final int totalVerses;
  final bool isBookmarked;
  final bool isAnchor;
  final bool isActive;
  final bool isPlaying;
  final double fontSize;
  final bool audioAvailable;
  final VoidCallback onToggleBookmark;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;
    final translation = cleanTranslationText(verse.translation);
    final radius = BorderRadius.circular(26);

    Future<void> copy(String text, String label) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$label copied')));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: isActive
              ? scheme.onSurface.withValues(alpha: .38)
              : base.withValues(alpha: isDark ? .10 : .07),
          width: isActive ? 1.2 : 1,
        ),
        color: isActive
            ? base.withValues(alpha: isDark ? .10 : .05)
            : base.withValues(alpha: isDark ? .045 : .025),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GlassBadge(
                    size: 34,
                    child: Text(
                      '${verse.number}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isActive)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EqualizerBars(
                          active: isPlaying,
                          height: 12,
                          barWidth: 2.2,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPlaying ? 'NOW RECITING' : 'PAUSED HERE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  else if (isAnchor)
                    const GlassChip(label: 'SEARCH MATCH', dense: true),
                  const Spacer(),
                  IconButton(
                    tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                    visualDensity: VisualDensity.compact,
                    iconSize: 21,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    onPressed: onToggleBookmark,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    iconSize: 21,
                    icon: const Icon(Icons.more_horiz_rounded),
                    onSelected: (value) {
                      switch (value) {
                        case 'arabic':
                          copy(verse.arabic, 'Arabic text');
                        case 'translation':
                          copy(translation, 'Translation');
                        case 'both':
                          copy(
                            '${verse.arabic}\n\n$translation',
                            'Ayah and translation',
                          );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'arabic',
                        child: Text('Copy Arabic'),
                      ),
                      PopupMenuItem(
                        value: 'translation',
                        child: Text('Copy translation'),
                      ),
                      PopupMenuItem(value: 'both', child: Text('Copy both')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                verse.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 2.05,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              if (translation.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: scheme.onSurface.withValues(alpha: .18),
                        width: 2,
                      ),
                    ),
                  ),
                  child: SelectableText(
                    translation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'AYAH ${verse.number} OF $totalVerses',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: scheme.onSurfaceVariant.withValues(alpha: .85),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: audioAvailable ? onPlay : null,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: Icon(
                      isActive && isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 17,
                    ),
                    label: Text(
                      isActive && isPlaying ? 'Pause' : 'Listen',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypographySheet extends StatefulWidget {
  const _TypographySheet({required this.initialSize, required this.onChanged});

  final double initialSize;
  final ValueChanged<double> onChanged;

  @override
  State<_TypographySheet> createState() => _TypographySheetState();
}

class _TypographySheetState extends State<_TypographySheet> {
  late double _size = widget.initialSize;

  void _update(double value) {
    setState(() => _size = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionLabel(title: 'Reading comfort'),
            const SizedBox(height: 14),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: _size, height: 1.9),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  tooltip: 'Smaller text',
                  onPressed: _size > 24 ? () => _update(_size - 2) : null,
                  icon: const Icon(Icons.text_decrease_rounded),
                ),
                Expanded(
                  child: Slider(
                    value: _size.clamp(24, 52),
                    min: 24,
                    max: 52,
                    divisions: 14,
                    label: _size.round().toString(),
                    onChanged: _update,
                  ),
                ),
                IconButton(
                  tooltip: 'Larger text',
                  onPressed: _size < 52 ? () => _update(_size + 2) : null,
                  icon: const Icon(Icons.text_increase_rounded),
                ),
              ],
            ),
            Text(
              'Arabic text size · ${_size.round()}pt',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
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
