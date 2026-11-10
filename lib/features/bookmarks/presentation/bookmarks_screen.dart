import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/core/database/app_database.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final progress = ref.watch(readingProgressProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Library',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: bookmarks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('$error')),
              data: (items) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  children: [
                    progress.maybeWhen(
                      data: (value) => value == null
                          ? const SizedBox.shrink()
                          : _ContinueCard(progress: value),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmarked ayat (${items.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (items.isEmpty) const _EmptyState(),
                    for (final item in items)
                      _BookmarkTile(surahId: item.surahId, verseId: item.verseId),
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

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.progress});

  final ReadingProgressData progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language)).value;
    String name = 'Surah ${progress.surahId}';
    for (final chapter in chapters ?? const <Chapter>[]) {
      if (chapter.id == progress.surahId) {
        name = '${chapter.nameSimple} — ${chapter.translatedName}';
        break;
      }
    }
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.history),
        title: const Text('Continue reading'),
        subtitle: Text(name),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.push('/surah/${progress.surahId}'),
      ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.surahId, required this.verseId});

  final int surahId;
  final int verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationId = ref.watch(translationIdProvider);
    final verses = ref
        .watch(readerProvider((surahId, translationId)))
        .value;

    Verse? verse;
    for (final candidate in verses ?? const <Verse>[]) {
      if (candidate.number == verseId) {
        verse = candidate;
        break;
      }
    }
    final chapterName = _chapterName(context, ref, surahId);

    return Card(
      child: ListTile(
        title: Text('$chapterName · Ayah $verseId'),
        subtitle: verse == null
            ? const Text('Tap to open in the reader')
            : Text(
                verse.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17),
              ),
        trailing: IconButton(
          tooltip: 'Remove bookmark',
          icon: const Icon(Icons.bookmark_remove_outlined),
          onPressed: () =>
              ref.read(databaseProvider).toggleBookmark(surahId, verseId),
        ),
        onTap: () => context.push('/surah/$surahId?verse=$verseId'),
      ),
    );
  }

  String _chapterName(BuildContext context, WidgetRef ref, int id) {
    final language = ref.watch(appLanguageProvider);
    final chapters = ref.watch(chaptersProvider(language)).value;
    for (final chapter in chapters ?? const <Chapter>[]) {
      if (chapter.id == id) return '${chapter.nameSimple} ${chapter.nameArabic}';
    }
    return 'Surah $id';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_add_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No bookmarks yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Save an ayah while reading and it will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
