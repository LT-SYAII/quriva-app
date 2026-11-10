import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/widgets/glass.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';
  bool _audioOnly = false;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final chapters = ref.watch(chaptersProvider(language));
    final progress = ref.watch(readingProgressProvider);
    final catalog = ref.watch(reciterCatalogProvider(reciterId));
    final reciters = ref.watch(recitersProvider('en'));
    final reciterName = reciterNameFor(reciters.value, reciterId);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Read. Reflect. Live.',
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
                        ),
                      ),
                      GlassPanel(
                        radius: 20,
                        padding: EdgeInsets.zero,
                        onTap: () => context.push('/search'),
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(Icons.travel_explore_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ContinueHero(progress: progress.value),
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
                      const SizedBox(width: 10),
                      FilterChip(
                        label: const Text('Audio only'),
                        selected: _audioOnly,
                        onSelected: (value) => setState(() => _audioOnly = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassPanel(
                    radius: 24,
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
                            onChanged: (value) => setState(() => _query = value),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Filter by name or number',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Surahs',
                style: Theme.of(context).textTheme.titleMedium,
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
                  .where((chapter) =>
                      !_audioOnly || available.containsKey(chapter.id))
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
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 132),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _SurahTile(filtered[index], available),
                ),
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

class _ContinueHero extends ConsumerWidget {
  const _ContinueHero({required this.progress});

  final ReadingProgressData? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (progress == null) {
      return const GlassPanel(
        radius: 26,
        child: _HeroBody(),
      );
    }
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language));
    String title = 'Surah ${progress!.surahId}';
    for (final chapter in chapters.value ?? const <Chapter>[]) {
      if (chapter.id == progress!.surahId) {
        title = '${chapter.nameSimple} — ${chapter.translatedName}';
        break;
      }
    }
    return GlassPanel(
      radius: 22,
      onTap: () => context.push('/surah/${progress!.surahId}'),
      child: Row(
        children: [
          const GlassBadge(child: Icon(Icons.history_rounded, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue reading',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }
}

class _HeroBody extends StatelessWidget {
  const _HeroBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassBadge(
          child: Icon(
            Icons.auto_stories_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'The Quran, beautifully simple.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
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
      child: Row(
        children: [
          const GlassBadge(
            child: Icon(Icons.record_voice_over_rounded, size: 18),
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
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
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
      builder: (buildContext, sheetController) => _ReciterSheet(
        scrollController: sheetController,
      ),
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
          for (final reciter in items)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(reciter.name),
              subtitle: Text(reciterSubtitle(reciter, counts)),
              trailing: selected == reciter.id ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(reciterIdProvider.notifier).setId(reciter.id);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile(this.chapter, this.available);

  final Chapter chapter;
  final Map<int, String> available;

  @override
  Widget build(BuildContext context) {
    final hasAudio = available.containsKey(chapter.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GlassPanel(
        blur: 0,
        onTap: () => context.push('/surah/${chapter.id}'),
        child: Row(
          children: [
            GlassBadge(child: Text('${chapter.id}')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.nameSimple,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${chapter.revelationLabel} · ${chapter.versesCount} verses',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (hasAudio)
              Icon(
                Icons.graphic_eq_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: 10),
            Text(
              chapter.nameArabic,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleLarge,
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
