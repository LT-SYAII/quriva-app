import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quriva/app/quriva_app.dart';
import 'package:quriva/features/settings/presentation/preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          ref.watch(preferencesInitProvider);
          return child ?? const QurivaApp();
        },
      ),
    ),
  );
}
