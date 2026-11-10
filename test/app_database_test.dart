import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quriva/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async => database.close());

  test('bookmark can be added and removed', () async {
    await database.toggleBookmark(112, 1);
    expect(await database.select(database.bookmarks).get(), hasLength(1));

    await database.toggleBookmark(112, 1);
    expect(await database.select(database.bookmarks).get(), isEmpty);
  });

  test('bookmark rows are independent', () async {
    await database.toggleBookmark(1, 1);
    await database.toggleBookmark(1, 2);
    expect(await database.select(database.bookmarks).get(), hasLength(2));

    await database.toggleBookmark(1, 2);
    expect(
      (await database.select(database.bookmarks).get()).single.verseId,
      1,
    );
  });

  test('reading progress keeps a single latest row', () async {
    await database.saveProgress(1, 7);
    await database.saveProgress(2, 255);

    final progress = await database.loadProgress();
    expect(progress, isNotNull);
    expect(progress!.surahId, 2);
    expect(
      await database.select(database.readingProgress).get(),
      hasLength(1),
    );
  });
}
