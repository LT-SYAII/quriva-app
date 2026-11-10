import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences. Everything is stored locally on the device via
/// SharedPreferences — no accounts, no tracking, no analytics.
///
/// Notifiers only expose setters; the boot-time [preferencesInitProvider]
/// seeds their state from local storage.

class ThemeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, mode.name);
  }

  Future<void> setStored(String? name) async {
    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

/// UI language for chapter names ('en' or 'id').
class AppLanguageController extends Notifier<String> {
  static const _key = 'app_language';

  @override
  String build() => 'en';

  Future<void> setLanguage(String language) async {
    state = language;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, language);
  }

  Future<void> setStored(String? value) async =>
      state = value ?? 'en';
}

final appLanguageProvider =
    NotifierProvider<AppLanguageController, String>(AppLanguageController.new);

/// Selected translation resource id (from quran.com/resources/translations).
/// Defaults: 20 = Saheeh International (EN), 33 = Indonesian Islamic Affairs.
class TranslationController extends Notifier<int> {
  static const _key = 'translation_id';

  @override
  int build() => 20;

  Future<void> setId(int id) async {
    state = id;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_key, id);
  }

  Future<void> setStored(int? id, String appLanguage) async =>
      state = id ?? (appLanguage == 'id' ? 33 : 20);
}

final translationIdProvider =
    NotifierProvider<TranslationController, int>(TranslationController.new);

/// Selected recitation id (from quran.com/resources/recitations).
/// Default 7 is Mishari Rashid al-Afasy (murattal).
class ReciterController extends Notifier<int> {
  static const _key = 'reciter_id';

  @override
  int build() => 7;

  Future<void> setId(int id) async {
    state = id;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_key, id);
  }

  Future<void> setStored(int? id) async => state = id ?? 7;
}

final reciterIdProvider =
    NotifierProvider<ReciterController, int>(ReciterController.new);

class ArabicFontSizeController extends Notifier<double> {
  static const _key = 'arabic_font_size';

  @override
  double build() => 30;

  Future<void> setSize(double value) async {
    state = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_key, value);
  }

  Future<void> setStored(double? value) async =>
      state = value ?? 30;
}

final arabicFontSizeProvider =
    NotifierProvider<ArabicFontSizeController, double>(
  ArabicFontSizeController.new,
);

/// Seeds every preference from local storage once at startup.
final preferencesInitProvider = FutureProvider<void>((ref) async {
  final preferences = await SharedPreferences.getInstance();

  final language = preferences.getString('app_language');
  await ref.read(appLanguageProvider.notifier).setStored(language);
  await ref
      .read(translationIdProvider.notifier)
      .setStored(preferences.getInt('translation_id'), language ?? 'en');
  await ref
      .read(reciterIdProvider.notifier)
      .setStored(preferences.getInt('reciter_id'));
  await ref
      .read(arabicFontSizeProvider.notifier)
      .setStored(preferences.getDouble('arabic_font_size'));
  await ref
      .read(themeControllerProvider.notifier)
      .setStored(preferences.getString('theme_mode'));
});
