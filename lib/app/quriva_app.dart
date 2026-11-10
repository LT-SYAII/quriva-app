import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quriva/app/router.dart';
import 'package:quriva/app/theme.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

class QurivaApp extends ConsumerWidget {
  const QurivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Quriva',
      debugShowCheckedModeBanner: false,
      theme: QurivaTheme.light,
      darkTheme: QurivaTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
