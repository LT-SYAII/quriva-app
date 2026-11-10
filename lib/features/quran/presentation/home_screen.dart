import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language));
    final progress = ref.watch(readingProgressProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
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
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Read. Reflect. Live.',
                              style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Global search',
                        icon: const Icon(Icons.travel_explore_outlined),
                        onPressed: () => context.push('/search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  progress.maybeWhen(
                    data: (value) => value == null
                        ? const SizedBox.shrink()
                        : _ContinueReadingCard(surahId: value.surahId),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  SearchBar(
                    hintText: 'Filter surah by name or number',
                    leading: const Icon(Icons.search),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 20),
                  Text('Surahs', style: Theme.of(context).textTheme.titleLarge),
                ],
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
                onRetry: () =>
                    ref.invalidate(chaptersProvider(language)),
              ),
            ),
            data: (items) {
              final filtered = items.where(_matchesQuery).toList();
              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No surah matches your filter')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _SurahTile(filtered[index]),
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

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard({required this.surahId});

  final int surahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language));

    return chapters.maybeWhen(
      data: (items) {
        Chapter? chapter;
        if (surahId >= 1 && surahId <= items.length) chapter = items[surahId - 1];
        if (chapter == null) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Continue reading'),
            subtitle: Text(
              '${chapter.id}. ${chapter.nameSimple} — ${chapter.translatedName}',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.push('/surah/${chapter!.id}'),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(child: Text('${chapter.id}')),
        title: Text(chapter.nameSimple),
        subtitle: Text(
          'Surah no. ${chapter.id} · ${chapter.revelationLabel} · '
          '${chapter.versesCount} verses',
        ),
        trailing: Text(
          chapter.nameArabic,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => context.push('/surah/${chapter.id}'),
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
              Icons.cloud_off_outlined,
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
