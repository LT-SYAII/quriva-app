import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quriva/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:quriva/features/quran/presentation/chapter_info_screen.dart';
import 'package:quriva/features/quran/presentation/home_screen.dart';
import 'package:quriva/features/quran/presentation/reader_screen.dart';
import 'package:quriva/features/quran/presentation/search_screen.dart';
import 'package:quriva/features/settings/presentation/settings_screen.dart';
import 'package:quriva/shared/widgets/app_shell.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(
              path: '/bookmarks',
              builder: (context, state) => const BookmarksScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/surah/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null || id < 1 || id > 114) {
              return const Scaffold(body: Center(child: Text('Surah not found')));
            }
            final anchor = int.tryParse(
              state.uri.queryParameters['verse'] ?? '',
            );
            return ReaderScreen(surahId: id, anchorVerse: anchor);
          },
        ),
        GoRoute(
          path: '/surah-info/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null || id < 1 || id > 114) {
              return const Scaffold(body: Center(child: Text('Surah not found')));
            }
            return ChapterInfoScreen(surahId: id);
          },
        ),
      ],
    );

final router = buildRouter();
