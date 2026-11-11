import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/app/theme.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/audio/audio_player.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/widgets/glass.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';
import 'package:quriva/shared/widgets/ui_kit.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _audioOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final chapters = ref.watch(chaptersProvider(language));
    final progress = ref.watch(readingProgressProvider);
    final catalog = ref.watch(reciterCatalogProvider(reciterId));
    final reciters = ref.watch(recitersProvider('en'));
    final reciterName = reciterNameFor(reciters.value, reciterId);
    final chapterList = chapters.value ?? const <Chapter>[];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quriva',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.2,
                                  ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Read. Reflect. Live.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    letterSpacing: .2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GlassIconButton(
                        icon: Icons.travel_explore_rounded,
                        tooltip: 'Search the Quran',
                        size: 46,
                        onPressed: () => context.push('/search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FeaturedCard(
                    progress: progress.value,
                    chapters: chapterList,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ReciterChip(
                          reciterName: reciterName,
                          catalog: catalog,
                          onTap: () => _showReciterSheet(context, ref),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassChip(
                        label: 'Audio only',
                        icon: _audioOnly
                            ? Icons.check_rounded
                            : Icons.graphic_eq_rounded,
                        selected: _audioOnly,
                        onTap: () => setState(() => _audioOnly = !_audioOnly),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassPanel(
                    radius: 20,
                    blur: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Filter by name or number',
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear filter',
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const MetaLabel(
                        icon: Icons.menu_book_rounded,
                        label: '114 surahs',
                      ),
                      const SizedBox(width: 14),
                      const MetaLabel(
                        icon: Icons.auto_stories_rounded,
                        label: '6,236 ayat',
                      ),
                      const Spacer(),
                      if (chapters.hasValue)
                        Text(
                          '${chapterList.length} loaded',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            sliver: SliverToBoxAdapter(
              child: SectionLabel(
                title: 'Surahs',
                trailing: catalog.value == null
                    ? null
                    : Text(
                        '${catalog.value!.length} with audio',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),
          chapters.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _ErrorView(
                message: '$error',
                onRetry: () => ref.invalidate(chaptersProvider(language)),
              ),
            ),
            data: (items) {
              final available = catalog.value ?? const <int, String>{};
              final filtered = items
                  .where(_matchesQuery)
                  .where(
                    (chapter) =>
                        !_audioOnly || available.containsKey(chapter.id),
                  )
                  .toList();
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _audioOnly
                          ? 'No surahs match for this reciter.'
                          : 'No surah matches your filter',
                    ),
                  ),
                );
              }
              return StreamBuilder<int?>(
                stream: globalAudioPlayer.currentSurahIdStream,
                builder: (context, snapshot) {
                  final activeId =
                      snapshot.data ?? globalAudioPlayer.currentSurahId;
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 200),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _SurahTile(
                        filtered[index],
                        available,
                        playing:
                            activeId == filtered[index].id &&
                            globalAudioPlayer.playing,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  bool _matchesQuery(Chapter chapter) {
    final query = _query.trim().toLowerCase();
    return query.isEmpty ||
        chapter.id.toString() == query ||
        chapter.versesCount.toString() == query ||
        chapter.nameSimple.toLowerCase().contains(query) ||
        chapter.translatedName.toLowerCase().contains(query) ||
        chapter.nameArabic.contains(query);
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.progress, required this.chapters});

  final ReadingProgressData? progress;
  final List<Chapter> chapters;

  Chapter? get _chapter {
    final id = progress?.surahId ?? 1;
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _chapter;
    final surahId = chapter?.id ?? 1;
    final hasProgress = progress != null;
    final total = chapter?.versesCount ?? 7;
    final verse = hasProgress ? progress!.verseId.clamp(1, total) : 1;
    final fraction = hasProgress ? (verse / total).clamp(0.0, 1.0) : 0.0;
    final title = chapter?.nameSimple ?? 'Al-Fatihah';
    final translated = chapter?.translatedName ?? 'The Opening';
    final arabic = chapter?.nameArabic ?? 'الفاتحة';
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: QurivaTheme.dark,
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () => context.push('/surah/$surahId'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                const Positioned.fill(child: LandscapeBackground()),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: .12),
                          Colors.black.withValues(alpha: .42),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: -4,
                  child: Text(
                    arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 76,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .12),
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
                            label: hasProgress
                                ? 'CONTINUE READING'
                                : 'START HERE',
                            icon: hasProgress
                                ? Icons.history_rounded
                                : Icons.auto_stories_rounded,
                            dense: true,
                          ),
                          const Spacer(),
                          GlassChip(label: '$total AYAT', dense: true),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.5,
                            ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        translated,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: .72),
                        ),
                      ),
                      if (hasProgress) ...[
                        const SizedBox(height: 14),
                        GlassProgressLine(
                          value: fraction,
                          height: 3,
                          active: true,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ayah $verse of $total · ${(fraction * 100).round()}% read',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: .72),
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          MetaLabel(
                            icon: Icons.schedule_rounded,
                            label: chapter?.revelationLabel ?? 'Makki',
                          ),
                          const SizedBox(width: 14),
                          MetaLabel(
                            icon: Icons.format_list_numbered_rounded,
                            label: '$total ayat',
                          ),
                          const Spacer(),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.onSurface,
                            ),
                            child: Icon(
                              hasProgress
                                  ? Icons.arrow_forward_rounded
                                  : Icons.play_arrow_rounded,
                              color: scheme.surface,
                              size: 24,
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
      ),
    );
  }
}

class _ReciterChip extends ConsumerWidget {
  const _ReciterChip({
    required this.reciterName,
    required this.catalog,
    required this.onTap,
  });

  final String reciterName;
  final AsyncValue<Map<int, String>> catalog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = catalog.value?.length;
    final subtitle = switch (count) {
      null => 'Loading reciter…',
      _ => '$count / 114 surahs available',
    };
    return GlassPanel(
      radius: 20,
      blur: 0,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const GlassBadge(
            size: 34,
            child: Icon(Icons.record_voice_over_rounded, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reciterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.unfold_more_rounded, size: 18),
        ],
      ),
    );
  }
}

Future<void> _showReciterSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: .72,
      maxChildSize: .95,
      expand: false,
      builder: (buildContext, sheetController) =>
          _ReciterSheet(scrollController: sheetController),
    ),
  );
}

class _ReciterSheet extends ConsumerWidget {
  const _ReciterSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(recitersProvider('en'));
    final counts = ref.watch(reciterCountsProvider);
    final selected = ref.watch(reciterIdProvider);

    return reciters.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load reciters.\n$error'),
        ),
      ),
      data: (items) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: SectionLabel(
              title: 'Choose reciter',
              trailing: Text(
                '${items.length} voices',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          for (final reciter in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: GlassBadge(
                  size: 36,
                  child: Text(
                    '${reciter.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(reciter.name),
                subtitle: Text(reciterSubtitle(reciter, counts)),
                trailing: selected == reciter.id
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () {
                  ref.read(reciterIdProvider.notifier).setId(reciter.id);
                  Navigator.of(context).pop();
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile(this.chapter, this.available, {required this.playing});

  final Chapter chapter;
  final Map<int, String> available;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final hasAudio = available.containsKey(chapter.id);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GlassPanel(
        radius: 18,
        blur: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        onTap: () => context.push('/surah/${chapter.id}'),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.onSurface.withValues(alpha: .14),
                    scheme.onSurface.withValues(alpha: .04),
                  ],
                ),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: .12),
                ),
              ),
              child: playing
                  ? EqualizerBars(active: true, height: 16, barWidth: 2.4)
                  : Text(
                      '${chapter.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.nameSimple,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${chapter.revelationLabel} · ${chapter.versesCount} ayat',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (hasAudio) ...[
                        const SizedBox(width: 7),
                        Icon(
                          Icons.graphic_eq_rounded,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              chapter.nameArabic,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: scheme.onSurfaceVariant.withValues(alpha: .8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load content',
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
