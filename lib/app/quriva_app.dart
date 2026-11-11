import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quriva/app/router.dart';
import 'package:quriva/app/theme.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';
import 'package:quriva/shared/widgets/landscape_background.dart';

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
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Stack(
          children: [
            const Positioned.fill(child: LandscapeBackground()),
            Positioned.fill(
              child: ColoredBox(
                color: isDark
                    ? Colors.black.withValues(alpha: .35)
                    : Colors.white.withValues(alpha: .30),
              ),
            ),
            Positioned.fill(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}
