import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final appLanguage = ref.watch(appLanguageProvider);
    final translationId = ref.watch(translationIdProvider);
    final reciterId = ref.watch(reciterIdProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setMode(value);
                }
              },
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_themeLabel(mode)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Chapter names'),
                  subtitle: const Text('Language for surah list and titles'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'id', label: Text('ID')),
                    ],
                    selected: {appLanguage},
                    onSelectionChanged: (selection) async {
                      final value = selection.first;
                      ref.invalidate(chaptersProvider(appLanguage));
                      await ref
                          .read(appLanguageProvider.notifier)
                          .setLanguage(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.translate_outlined),
                  title: const Text('Translation'),
                  subtitle: Text(_translationLabel(translationId)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectTranslationSheet(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.headphones_outlined),
                  title: const Text('Reciter'),
                  subtitle: Text(
                    reciterLabel(ref.watch(
                      recitersProvider('en'),
                    ).value, reciterId),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectReciterSheet(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Reading',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arabic text size · ${fontSize.round()}'),
                  Slider(
                    min: 22,
                    max: 44,
                    divisions: 11,
                    value: fontSize,
                    label: fontSize.round().toString(),
                    onChanged: (value) {
                      ref.read(arabicFontSizeProvider.notifier).setSize(value);
                    },
                  ),
                  Center(
                    child: Text(
                      'ٱلۡقُرۡءَانُ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Data & storage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Clear cached content'),
                  subtitle: const Text(
                    'Removes cached ayat, translations, surah info and audio '
                    'links. Bookmarks are kept. Content is re-downloaded when '
                    'you read while online.',
                  ),
                  isThreeLine: true,
                  onTap: () => _confirmClearCache(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Data source'),
                  subtitle: const Text(
                    'Content is fetched live from the official Quran.com API '
                    '(v4); audio streams from Quranicaudio. Nothing is bundled: '
                    'the app stays small.\n'
                    'No accounts. No analytics. No tracking.',
                  ),
                  isThreeLine: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apps_outlined),
                  title: const Text('Quriva'),
                  subtitle: const Text(
                    'Version 0.1.0\nRead. Reflect. Live.',
                  ),
                  isThreeLine: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('Project repository'),
                  subtitle: const Text('github.com/LT-SYAII/quriva-app'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Use system theme',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  String _translationLabel(int translationId) => switch (translationId) {
        20 => 'Saheeh International (English)',
        33 => 'Ministry of Islamic Affairs (Indonesian)',
        _ => 'Translation resource #$translationId',
      };

  Future<void> _selectTranslationSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .7,
        maxChildSize: .92,
        expand: false,
        builder: (context, sheetScrollController) => _TranslationPicker(
          scrollController: sheetScrollController,
        ),
      ),
    );
  }

  Future<void> _selectReciterSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .6,
        maxChildSize: .9,
        expand: false,
        builder: (context, sheetScrollController) => _ReciterPicker(
          scrollController: sheetScrollController,
        ),
      ),
    );
  }

  void _confirmClearCache(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cached content?'),
        content: const Text(
          'Cached ayat, translations, surah info and audio links are removed '
          'from this device. Bookmarks and your last reading position are '
          'kept. Content will be re-fetched while reading online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(quranRepositoryProvider).clearContentCache();
              ref.invalidate(chaptersProvider(ref.read(appLanguageProvider)));
              ref.invalidate(translationsProvider('en'));
              ref.invalidate(recitersProvider('en'));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content cache cleared.')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

String reciterLabel(List<Reciter>? reciters, int reciterId) {
  for (final reciter in reciters ?? const <Reciter>[]) {
    if (reciter.id == reciterId) return reciter.displayName;
  }
  return 'Reciter #$reciterId';
}

class _TranslationPicker extends ConsumerStatefulWidget {
  const _TranslationPicker({required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<_TranslationPicker> createState() => _TranslationPickerState();
}

class _TranslationPickerState extends ConsumerState<_TranslationPicker> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future(() => ref.read(quranRepositoryProvider).getTranslations('en'));
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.watch(translationsProvider('en'));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter by name / author / language',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: translations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load translations.\n$error'),
              ),
            ),
            data: (items) {
              final query = _query.trim().toLowerCase();
              final filtered = items
                  .where((item) =>
                      query.isEmpty ||
                      item.name.toLowerCase().contains(query) ||
                      item.authorName.toLowerCase().contains(query) ||
                      item.languageName.toLowerCase().contains(query))
                  .toList();
              final englishOrIndo = filtered
                  .where((item) => _priority(item.languageName) == 0)
                  .toList();
              final other = filtered
                  .where((item) => _priority(item.languageName) != 0)
                  .toList();
              return ListView(
                controller: widget.scrollController,
                children: [
                  for (final translation in englishOrIndo) _tile(context, translation),
                  if (englishOrIndo.isNotEmpty && other.isNotEmpty)
                    const Divider(height: 1),
                  for (final translation in other) _tile(context, translation),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  int _priority(String language) {
    final value = language.toLowerCase();
    if (value == 'english' || value == 'indonesian') return 0;
    return 1;
  }

  Widget _tile(BuildContext context, TranslationResource translation) {
    final selected = translation.id == ref.watch(translationIdProvider);
    return ListTile(
      title: Text(translation.name),
      subtitle: Text('${translation.authorName} · ${translation.languageName}'),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(translationIdProvider.notifier).setId(translation.id);
        Navigator.of(context).pop();
      },
    );
  }
}

class _ReciterPicker extends ConsumerWidget {
  const _ReciterPicker({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(recitersProvider('en'));
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
        children: [
          for (final reciter in items)
            ListTile(
              title: Text(reciter.name),
              subtitle: reciter.style?.isEmpty ?? false
                  ? null
                  : Text(reciter.style ?? ''),
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
