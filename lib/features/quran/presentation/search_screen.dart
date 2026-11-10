import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/features/quran/data/quran_repository.dart';
import 'package:quriva/features/quran/domain/quran_models.dart';
import 'package:quriva/shared/utils/text_utils.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

enum _SearchStatus { idle, loading, done, error }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  SearchPage? _page;
  String _activeQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  _SearchStatus _status = _SearchStatus.idle;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _status = _SearchStatus.idle;
        _page = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search(query, reset: true);
    });
  }

  Future<void> _search(String query, {required bool reset}) async {
    setState(() {
      _status = _SearchStatus.loading;
      _error = '';
      if (reset) {
        _page = null;
        _currentPage = 1;
      }
      _activeQuery = query;
    });
    final page = reset ? 0 : _currentPage;
    try {
      final result = await ref.read(quranRepositoryProvider).search(
            query,
            page: page,
          );
      if (!mounted) return;
      setState(() {
        _status = _SearchStatus.done;
        _totalPages = result.totalPages;
        _currentPage = result.currentPage;
        _page = reset
            ? result
            : SearchPage(
                query: result.query,
                totalResults: result.totalResults,
                currentPage: result.currentPage,
                totalPages: result.totalPages,
                results: [...?_page?.results, ...result.results],
              );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _SearchStatus.error;
        _error = 'Search failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _page?.results ?? const <SearchVerseResult>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Search the Quran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search in Arabic or by translation keywords',
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _controller.clear(),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: switch (_status) {
              _SearchStatus.idle => const Center(
                  child: Text('Type a keyword, e.g. mercy'),
                ),
              _SearchStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
              _SearchStatus.error => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error, textAlign: TextAlign.center),
                  ),
                ),
              _SearchStatus.done => results.isEmpty
                  ? const Center(child: Text('No results'))
                  : _buildResults(context, results),
            },
          ),
          if (_status == _SearchStatus.done &&
              _page != null &&
              _currentPage < _totalPages)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.tonal(
                onPressed: () => _search(_activeQuery, reset: false),
                child: Text(
                  'Load more (page $_currentPage of $_totalPages)',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<SearchVerseResult> results) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final translation = result.translations.isEmpty
            ? ''
            : cleanTranslationText(
                result.translations.first.text
                    .replaceAll(RegExp(r'</?em>'), ''),
              );
        final parts = result.verseKey.split(':');
        final surahId = int.tryParse(parts.first) ?? 0;
        final verseId = int.tryParse(parts.last) ?? 0;
        return Card(
          child: ListTile(
            title: Text(
              'Ayah ${result.verseKey}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  result.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18, height: 1.9),
                ),
                if (translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(translation, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
            onTap: () => context.push('/surah/$surahId?verse=$verseId'),
          ),
        );
      },
    );
  }
}
