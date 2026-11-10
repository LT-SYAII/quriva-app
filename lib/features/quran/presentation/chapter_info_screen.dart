import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

/// Background information about a surah (name, revelation context, theme).
/// Content comes from the Quran.com API and is attributed in-app.
class ChapterInfoScreen extends ConsumerWidget {
  const ChapterInfoScreen({required this.surahId, super.key});

  final int surahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final info = ref.watch(chapterInfoProvider((surahId, language)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Surah $surahId info'),
        actions: [
          IconButton(
            tooltip: 'Open surah',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => context.push('/surah/$surahId'),
          ),
        ],
      ),
      body: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load surah info.\n$error'),
          ),
        ),
        data: (value) {
          if (value == null || value.textHtml.trim().isEmpty) {
            return const Center(child: Text('No info available for this surah.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (value.shortText.isNotEmpty)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(value.shortText),
                  ),
                ),
              const SizedBox(height: 8),
              _PlainTextSummary(value.textHtml),
              const SizedBox(height: 12),
              Text(
                'Source: ${value.source} — via Quran.com API',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Removes simple HTML tags from the API text so it renders as plain text
/// without pulling in a full HTML parser dependency.
class _PlainTextSummary extends StatelessWidget {
  const _PlainTextSummary(this.html);

  final String html;

  static final _tagExpression = RegExp(r'<[^>]*>');

  @override
  Widget build(BuildContext context) {
    final text = html
        .replaceAll(RegExp(r'<li>\s*</p>'), '\n• ')
        .replaceAll(RegExp(r'</li>'), '\n')
        .replaceAll(RegExp(r'<(h1|h2|h3)[^>]*>'), '\n\n')
        .replaceAll(RegExp(r'</(h1|h2|h3)>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n')
        .replaceAll(_tagExpression, '')
        .replaceAll('\r\n', '\n');
    return Text(
      text.trim(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
    );
  }
}
