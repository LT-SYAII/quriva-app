// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [surahId, verseId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahId, verseId};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int surahId;
  final int verseId;
  final DateTime createdAt;
  const Bookmark({
    required this.surahId,
    required this.verseId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_id'] = Variable<int>(surahId);
    map['verse_id'] = Variable<int>(verseId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      surahId: Value(surahId),
      verseId: Value(verseId),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      surahId: serializer.fromJson<int>(json['surahId']),
      verseId: serializer.fromJson<int>(json['verseId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahId': serializer.toJson<int>(surahId),
      'verseId': serializer.toJson<int>(verseId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({int? surahId, int? verseId, DateTime? createdAt}) =>
      Bookmark(
        surahId: surahId ?? this.surahId,
        verseId: verseId ?? this.verseId,
        createdAt: createdAt ?? this.createdAt,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(surahId, verseId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.surahId == this.surahId &&
          other.verseId == this.verseId &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> surahId;
  final Value<int> verseId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.surahId = const Value.absent(),
    this.verseId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required int surahId,
    required int verseId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : surahId = Value(surahId),
       verseId = Value(verseId);
  static Insertable<Bookmark> custom({
    Expression<int>? surahId,
    Expression<int>? verseId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (surahId != null) 'surah_id': surahId,
      if (verseId != null) 'verse_id': verseId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? surahId,
    Value<int>? verseId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      surahId: surahId ?? this.surahId,
      verseId: verseId ?? this.verseId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, surahId, verseId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressData extends DataClass
    implements Insertable<ReadingProgressData> {
  final int id;
  final int surahId;
  final int verseId;
  final DateTime updatedAt;
  const ReadingProgressData({
    required this.id,
    required this.surahId,
    required this.verseId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['verse_id'] = Variable<int>(verseId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      id: Value(id),
      surahId: Value(surahId),
      verseId: Value(verseId),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressData(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      verseId: serializer.fromJson<int>(json['verseId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'verseId': serializer.toJson<int>(verseId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressData copyWith({
    int? id,
    int? surahId,
    int? verseId,
    DateTime? updatedAt,
  }) => ReadingProgressData(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    verseId: verseId ?? this.verseId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingProgressData copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressData(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressData(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surahId, verseId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressData &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.verseId == this.verseId &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressData> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> verseId;
  final Value<DateTime> updatedAt;
  const ReadingProgressCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.verseId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int verseId,
    this.updatedAt = const Value.absent(),
  }) : surahId = Value(surahId),
       verseId = Value(verseId);
  static Insertable<ReadingProgressData> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? verseId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (verseId != null) 'verse_id': verseId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? verseId,
    Value<DateTime>? updatedAt,
  }) {
    return ReadingProgressCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      verseId: verseId ?? this.verseId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChapterCacheTable extends ChapterCache
    with TableInfo<$ChapterCacheTable, ChapterCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSimpleMeta = const VerificationMeta(
    'nameSimple',
  );
  @override
  late final GeneratedColumn<String> nameSimple = GeneratedColumn<String>(
    'name_simple',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revelationPlaceMeta = const VerificationMeta(
    'revelationPlace',
  );
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
    'revelation_place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versesCountMeta = const VerificationMeta(
    'versesCount',
  );
  @override
  late final GeneratedColumn<int> versesCount = GeneratedColumn<int>(
    'verses_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedNameMeta = const VerificationMeta(
    'translatedName',
  );
  @override
  late final GeneratedColumn<String> translatedName = GeneratedColumn<String>(
    'translated_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    language,
    chapterId,
    nameSimple,
    nameArabic,
    revelationPlace,
    versesCount,
    translatedName,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('name_simple')) {
      context.handle(
        _nameSimpleMeta,
        nameSimple.isAcceptableOrUnknown(data['name_simple']!, _nameSimpleMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSimpleMeta);
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
        _revelationPlaceMeta,
        revelationPlace.isAcceptableOrUnknown(
          data['revelation_place']!,
          _revelationPlaceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationPlaceMeta);
    }
    if (data.containsKey('verses_count')) {
      context.handle(
        _versesCountMeta,
        versesCount.isAcceptableOrUnknown(
          data['verses_count']!,
          _versesCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versesCountMeta);
    }
    if (data.containsKey('translated_name')) {
      context.handle(
        _translatedNameMeta,
        translatedName.isAcceptableOrUnknown(
          data['translated_name']!,
          _translatedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translatedNameMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {language, chapterId};
  @override
  ChapterCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterCacheData(
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      nameSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_simple'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      revelationPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place'],
      )!,
      versesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verses_count'],
      )!,
      translatedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_name'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ChapterCacheTable createAlias(String alias) {
    return $ChapterCacheTable(attachedDatabase, alias);
  }
}

class ChapterCacheData extends DataClass
    implements Insertable<ChapterCacheData> {
  final String language;
  final int chapterId;
  final String nameSimple;
  final String nameArabic;
  final String revelationPlace;
  final int versesCount;
  final String translatedName;
  final DateTime fetchedAt;
  const ChapterCacheData({
    required this.language,
    required this.chapterId,
    required this.nameSimple,
    required this.nameArabic,
    required this.revelationPlace,
    required this.versesCount,
    required this.translatedName,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['language'] = Variable<String>(language);
    map['chapter_id'] = Variable<int>(chapterId);
    map['name_simple'] = Variable<String>(nameSimple);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['revelation_place'] = Variable<String>(revelationPlace);
    map['verses_count'] = Variable<int>(versesCount);
    map['translated_name'] = Variable<String>(translatedName);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ChapterCacheCompanion toCompanion(bool nullToAbsent) {
    return ChapterCacheCompanion(
      language: Value(language),
      chapterId: Value(chapterId),
      nameSimple: Value(nameSimple),
      nameArabic: Value(nameArabic),
      revelationPlace: Value(revelationPlace),
      versesCount: Value(versesCount),
      translatedName: Value(translatedName),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ChapterCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterCacheData(
      language: serializer.fromJson<String>(json['language']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      nameSimple: serializer.fromJson<String>(json['nameSimple']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      revelationPlace: serializer.fromJson<String>(json['revelationPlace']),
      versesCount: serializer.fromJson<int>(json['versesCount']),
      translatedName: serializer.fromJson<String>(json['translatedName']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'language': serializer.toJson<String>(language),
      'chapterId': serializer.toJson<int>(chapterId),
      'nameSimple': serializer.toJson<String>(nameSimple),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'revelationPlace': serializer.toJson<String>(revelationPlace),
      'versesCount': serializer.toJson<int>(versesCount),
      'translatedName': serializer.toJson<String>(translatedName),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ChapterCacheData copyWith({
    String? language,
    int? chapterId,
    String? nameSimple,
    String? nameArabic,
    String? revelationPlace,
    int? versesCount,
    String? translatedName,
    DateTime? fetchedAt,
  }) => ChapterCacheData(
    language: language ?? this.language,
    chapterId: chapterId ?? this.chapterId,
    nameSimple: nameSimple ?? this.nameSimple,
    nameArabic: nameArabic ?? this.nameArabic,
    revelationPlace: revelationPlace ?? this.revelationPlace,
    versesCount: versesCount ?? this.versesCount,
    translatedName: translatedName ?? this.translatedName,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ChapterCacheData copyWithCompanion(ChapterCacheCompanion data) {
    return ChapterCacheData(
      language: data.language.present ? data.language.value : this.language,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      nameSimple: data.nameSimple.present
          ? data.nameSimple.value
          : this.nameSimple,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      versesCount: data.versesCount.present
          ? data.versesCount.value
          : this.versesCount,
      translatedName: data.translatedName.present
          ? data.translatedName.value
          : this.translatedName,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCacheData(')
          ..write('language: $language, ')
          ..write('chapterId: $chapterId, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('versesCount: $versesCount, ')
          ..write('translatedName: $translatedName, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    language,
    chapterId,
    nameSimple,
    nameArabic,
    revelationPlace,
    versesCount,
    translatedName,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterCacheData &&
          other.language == this.language &&
          other.chapterId == this.chapterId &&
          other.nameSimple == this.nameSimple &&
          other.nameArabic == this.nameArabic &&
          other.revelationPlace == this.revelationPlace &&
          other.versesCount == this.versesCount &&
          other.translatedName == this.translatedName &&
          other.fetchedAt == this.fetchedAt);
}

class ChapterCacheCompanion extends UpdateCompanion<ChapterCacheData> {
  final Value<String> language;
  final Value<int> chapterId;
  final Value<String> nameSimple;
  final Value<String> nameArabic;
  final Value<String> revelationPlace;
  final Value<int> versesCount;
  final Value<String> translatedName;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ChapterCacheCompanion({
    this.language = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.nameSimple = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.versesCount = const Value.absent(),
    this.translatedName = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterCacheCompanion.insert({
    required String language,
    required int chapterId,
    required String nameSimple,
    required String nameArabic,
    required String revelationPlace,
    required int versesCount,
    required String translatedName,
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : language = Value(language),
       chapterId = Value(chapterId),
       nameSimple = Value(nameSimple),
       nameArabic = Value(nameArabic),
       revelationPlace = Value(revelationPlace),
       versesCount = Value(versesCount),
       translatedName = Value(translatedName);
  static Insertable<ChapterCacheData> custom({
    Expression<String>? language,
    Expression<int>? chapterId,
    Expression<String>? nameSimple,
    Expression<String>? nameArabic,
    Expression<String>? revelationPlace,
    Expression<int>? versesCount,
    Expression<String>? translatedName,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (language != null) 'language': language,
      if (chapterId != null) 'chapter_id': chapterId,
      if (nameSimple != null) 'name_simple': nameSimple,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (versesCount != null) 'verses_count': versesCount,
      if (translatedName != null) 'translated_name': translatedName,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterCacheCompanion copyWith({
    Value<String>? language,
    Value<int>? chapterId,
    Value<String>? nameSimple,
    Value<String>? nameArabic,
    Value<String>? revelationPlace,
    Value<int>? versesCount,
    Value<String>? translatedName,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ChapterCacheCompanion(
      language: language ?? this.language,
      chapterId: chapterId ?? this.chapterId,
      nameSimple: nameSimple ?? this.nameSimple,
      nameArabic: nameArabic ?? this.nameArabic,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      versesCount: versesCount ?? this.versesCount,
      translatedName: translatedName ?? this.translatedName,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (nameSimple.present) {
      map['name_simple'] = Variable<String>(nameSimple.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (versesCount.present) {
      map['verses_count'] = Variable<int>(versesCount.value);
    }
    if (translatedName.present) {
      map['translated_name'] = Variable<String>(translatedName.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCacheCompanion(')
          ..write('language: $language, ')
          ..write('chapterId: $chapterId, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('versesCount: $versesCount, ')
          ..write('translatedName: $translatedName, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseCacheTable extends VerseCache
    with TableInfo<$VerseCacheTable, VerseCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseNumberMeta = const VerificationMeta(
    'verseNumber',
  );
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
    'verse_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<int> translationId = GeneratedColumn<int>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicMeta = const VerificationMeta('arabic');
  @override
  late final GeneratedColumn<String> arabic = GeneratedColumn<String>(
    'arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    verseNumber,
    translationId,
    arabic,
    translation,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
        _verseNumberMeta,
        verseNumber.isAcceptableOrUnknown(
          data['verse_number']!,
          _verseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('arabic')) {
      context.handle(
        _arabicMeta,
        arabic.isAcceptableOrUnknown(data['arabic']!, _arabicMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId, translationId};
  @override
  VerseCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseCacheData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      verseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_number'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}translation_id'],
      )!,
      arabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $VerseCacheTable createAlias(String alias) {
    return $VerseCacheTable(attachedDatabase, alias);
  }
}

class VerseCacheData extends DataClass implements Insertable<VerseCacheData> {
  final int chapterId;
  final int verseNumber;
  final int translationId;
  final String arabic;
  final String translation;
  final DateTime fetchedAt;
  const VerseCacheData({
    required this.chapterId,
    required this.verseNumber,
    required this.translationId,
    required this.arabic,
    required this.translation,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<int>(chapterId);
    map['verse_number'] = Variable<int>(verseNumber);
    map['translation_id'] = Variable<int>(translationId);
    map['arabic'] = Variable<String>(arabic);
    map['translation'] = Variable<String>(translation);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  VerseCacheCompanion toCompanion(bool nullToAbsent) {
    return VerseCacheCompanion(
      chapterId: Value(chapterId),
      verseNumber: Value(verseNumber),
      translationId: Value(translationId),
      arabic: Value(arabic),
      translation: Value(translation),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory VerseCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseCacheData(
      chapterId: serializer.fromJson<int>(json['chapterId']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      translationId: serializer.fromJson<int>(json['translationId']),
      arabic: serializer.fromJson<String>(json['arabic']),
      translation: serializer.fromJson<String>(json['translation']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<int>(chapterId),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'translationId': serializer.toJson<int>(translationId),
      'arabic': serializer.toJson<String>(arabic),
      'translation': serializer.toJson<String>(translation),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  VerseCacheData copyWith({
    int? chapterId,
    int? verseNumber,
    int? translationId,
    String? arabic,
    String? translation,
    DateTime? fetchedAt,
  }) => VerseCacheData(
    chapterId: chapterId ?? this.chapterId,
    verseNumber: verseNumber ?? this.verseNumber,
    translationId: translationId ?? this.translationId,
    arabic: arabic ?? this.arabic,
    translation: translation ?? this.translation,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  VerseCacheData copyWithCompanion(VerseCacheCompanion data) {
    return VerseCacheData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      verseNumber: data.verseNumber.present
          ? data.verseNumber.value
          : this.verseNumber,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      arabic: data.arabic.present ? data.arabic.value : this.arabic,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseCacheData(')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('translationId: $translationId, ')
          ..write('arabic: $arabic, ')
          ..write('translation: $translation, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    verseNumber,
    translationId,
    arabic,
    translation,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseCacheData &&
          other.chapterId == this.chapterId &&
          other.verseNumber == this.verseNumber &&
          other.translationId == this.translationId &&
          other.arabic == this.arabic &&
          other.translation == this.translation &&
          other.fetchedAt == this.fetchedAt);
}

class VerseCacheCompanion extends UpdateCompanion<VerseCacheData> {
  final Value<int> chapterId;
  final Value<int> verseNumber;
  final Value<int> translationId;
  final Value<String> arabic;
  final Value<String> translation;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const VerseCacheCompanion({
    this.chapterId = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.translationId = const Value.absent(),
    this.arabic = const Value.absent(),
    this.translation = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseCacheCompanion.insert({
    required int chapterId,
    required int verseNumber,
    required int translationId,
    required String arabic,
    this.translation = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       verseNumber = Value(verseNumber),
       translationId = Value(translationId),
       arabic = Value(arabic);
  static Insertable<VerseCacheData> custom({
    Expression<int>? chapterId,
    Expression<int>? verseNumber,
    Expression<int>? translationId,
    Expression<String>? arabic,
    Expression<String>? translation,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (translationId != null) 'translation_id': translationId,
      if (arabic != null) 'arabic': arabic,
      if (translation != null) 'translation': translation,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseCacheCompanion copyWith({
    Value<int>? chapterId,
    Value<int>? verseNumber,
    Value<int>? translationId,
    Value<String>? arabic,
    Value<String>? translation,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return VerseCacheCompanion(
      chapterId: chapterId ?? this.chapterId,
      verseNumber: verseNumber ?? this.verseNumber,
      translationId: translationId ?? this.translationId,
      arabic: arabic ?? this.arabic,
      translation: translation ?? this.translation,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<int>(translationId.value);
    }
    if (arabic.present) {
      map['arabic'] = Variable<String>(arabic.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseCacheCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('translationId: $translationId, ')
          ..write('arabic: $arabic, ')
          ..write('translation: $translation, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterInfoCacheTable extends ChapterInfoCache
    with TableInfo<$ChapterInfoCacheTable, ChapterInfoCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterInfoCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortTextMeta = const VerificationMeta(
    'shortText',
  );
  @override
  late final GeneratedColumn<String> shortText = GeneratedColumn<String>(
    'short_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textHtmlMeta = const VerificationMeta(
    'textHtml',
  );
  @override
  late final GeneratedColumn<String> textHtml = GeneratedColumn<String>(
    'text_html',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    language,
    shortText,
    textHtml,
    source,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_info_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterInfoCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('short_text')) {
      context.handle(
        _shortTextMeta,
        shortText.isAcceptableOrUnknown(data['short_text']!, _shortTextMeta),
      );
    } else if (isInserting) {
      context.missing(_shortTextMeta);
    }
    if (data.containsKey('text_html')) {
      context.handle(
        _textHtmlMeta,
        textHtml.isAcceptableOrUnknown(data['text_html']!, _textHtmlMeta),
      );
    } else if (isInserting) {
      context.missing(_textHtmlMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId, language};
  @override
  ChapterInfoCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterInfoCacheData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      shortText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_text'],
      )!,
      textHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_html'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ChapterInfoCacheTable createAlias(String alias) {
    return $ChapterInfoCacheTable(attachedDatabase, alias);
  }
}

class ChapterInfoCacheData extends DataClass
    implements Insertable<ChapterInfoCacheData> {
  final int chapterId;
  final String language;
  final String shortText;
  final String textHtml;
  final String source;
  final DateTime fetchedAt;
  const ChapterInfoCacheData({
    required this.chapterId,
    required this.language,
    required this.shortText,
    required this.textHtml,
    required this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<int>(chapterId);
    map['language'] = Variable<String>(language);
    map['short_text'] = Variable<String>(shortText);
    map['text_html'] = Variable<String>(textHtml);
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ChapterInfoCacheCompanion toCompanion(bool nullToAbsent) {
    return ChapterInfoCacheCompanion(
      chapterId: Value(chapterId),
      language: Value(language),
      shortText: Value(shortText),
      textHtml: Value(textHtml),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ChapterInfoCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterInfoCacheData(
      chapterId: serializer.fromJson<int>(json['chapterId']),
      language: serializer.fromJson<String>(json['language']),
      shortText: serializer.fromJson<String>(json['shortText']),
      textHtml: serializer.fromJson<String>(json['textHtml']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<int>(chapterId),
      'language': serializer.toJson<String>(language),
      'shortText': serializer.toJson<String>(shortText),
      'textHtml': serializer.toJson<String>(textHtml),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ChapterInfoCacheData copyWith({
    int? chapterId,
    String? language,
    String? shortText,
    String? textHtml,
    String? source,
    DateTime? fetchedAt,
  }) => ChapterInfoCacheData(
    chapterId: chapterId ?? this.chapterId,
    language: language ?? this.language,
    shortText: shortText ?? this.shortText,
    textHtml: textHtml ?? this.textHtml,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ChapterInfoCacheData copyWithCompanion(ChapterInfoCacheCompanion data) {
    return ChapterInfoCacheData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      language: data.language.present ? data.language.value : this.language,
      shortText: data.shortText.present ? data.shortText.value : this.shortText,
      textHtml: data.textHtml.present ? data.textHtml.value : this.textHtml,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterInfoCacheData(')
          ..write('chapterId: $chapterId, ')
          ..write('language: $language, ')
          ..write('shortText: $shortText, ')
          ..write('textHtml: $textHtml, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(chapterId, language, shortText, textHtml, source, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterInfoCacheData &&
          other.chapterId == this.chapterId &&
          other.language == this.language &&
          other.shortText == this.shortText &&
          other.textHtml == this.textHtml &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class ChapterInfoCacheCompanion extends UpdateCompanion<ChapterInfoCacheData> {
  final Value<int> chapterId;
  final Value<String> language;
  final Value<String> shortText;
  final Value<String> textHtml;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ChapterInfoCacheCompanion({
    this.chapterId = const Value.absent(),
    this.language = const Value.absent(),
    this.shortText = const Value.absent(),
    this.textHtml = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterInfoCacheCompanion.insert({
    required int chapterId,
    required String language,
    required String shortText,
    required String textHtml,
    required String source,
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       language = Value(language),
       shortText = Value(shortText),
       textHtml = Value(textHtml),
       source = Value(source);
  static Insertable<ChapterInfoCacheData> custom({
    Expression<int>? chapterId,
    Expression<String>? language,
    Expression<String>? shortText,
    Expression<String>? textHtml,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (language != null) 'language': language,
      if (shortText != null) 'short_text': shortText,
      if (textHtml != null) 'text_html': textHtml,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterInfoCacheCompanion copyWith({
    Value<int>? chapterId,
    Value<String>? language,
    Value<String>? shortText,
    Value<String>? textHtml,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ChapterInfoCacheCompanion(
      chapterId: chapterId ?? this.chapterId,
      language: language ?? this.language,
      shortText: shortText ?? this.shortText,
      textHtml: textHtml ?? this.textHtml,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (shortText.present) {
      map['short_text'] = Variable<String>(shortText.value);
    }
    if (textHtml.present) {
      map['text_html'] = Variable<String>(textHtml.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterInfoCacheCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('language: $language, ')
          ..write('shortText: $shortText, ')
          ..write('textHtml: $textHtml, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioUrlCacheTable extends AudioUrlCache
    with TableInfo<$AudioUrlCacheTable, AudioUrlCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioUrlCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recitationIdMeta = const VerificationMeta(
    'recitationId',
  );
  @override
  late final GeneratedColumn<int> recitationId = GeneratedColumn<int>(
    'recitation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    recitationId,
    audioUrl,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_url_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioUrlCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('recitation_id')) {
      context.handle(
        _recitationIdMeta,
        recitationId.isAcceptableOrUnknown(
          data['recitation_id']!,
          _recitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recitationIdMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId, recitationId};
  @override
  AudioUrlCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioUrlCacheData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      recitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recitation_id'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $AudioUrlCacheTable createAlias(String alias) {
    return $AudioUrlCacheTable(attachedDatabase, alias);
  }
}

class AudioUrlCacheData extends DataClass
    implements Insertable<AudioUrlCacheData> {
  final int chapterId;
  final int recitationId;
  final String audioUrl;
  final DateTime fetchedAt;
  const AudioUrlCacheData({
    required this.chapterId,
    required this.recitationId,
    required this.audioUrl,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<int>(chapterId);
    map['recitation_id'] = Variable<int>(recitationId);
    map['audio_url'] = Variable<String>(audioUrl);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  AudioUrlCacheCompanion toCompanion(bool nullToAbsent) {
    return AudioUrlCacheCompanion(
      chapterId: Value(chapterId),
      recitationId: Value(recitationId),
      audioUrl: Value(audioUrl),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory AudioUrlCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioUrlCacheData(
      chapterId: serializer.fromJson<int>(json['chapterId']),
      recitationId: serializer.fromJson<int>(json['recitationId']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<int>(chapterId),
      'recitationId': serializer.toJson<int>(recitationId),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  AudioUrlCacheData copyWith({
    int? chapterId,
    int? recitationId,
    String? audioUrl,
    DateTime? fetchedAt,
  }) => AudioUrlCacheData(
    chapterId: chapterId ?? this.chapterId,
    recitationId: recitationId ?? this.recitationId,
    audioUrl: audioUrl ?? this.audioUrl,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  AudioUrlCacheData copyWithCompanion(AudioUrlCacheCompanion data) {
    return AudioUrlCacheData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      recitationId: data.recitationId.present
          ? data.recitationId.value
          : this.recitationId,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioUrlCacheData(')
          ..write('chapterId: $chapterId, ')
          ..write('recitationId: $recitationId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chapterId, recitationId, audioUrl, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioUrlCacheData &&
          other.chapterId == this.chapterId &&
          other.recitationId == this.recitationId &&
          other.audioUrl == this.audioUrl &&
          other.fetchedAt == this.fetchedAt);
}

class AudioUrlCacheCompanion extends UpdateCompanion<AudioUrlCacheData> {
  final Value<int> chapterId;
  final Value<int> recitationId;
  final Value<String> audioUrl;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const AudioUrlCacheCompanion({
    this.chapterId = const Value.absent(),
    this.recitationId = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioUrlCacheCompanion.insert({
    required int chapterId,
    required int recitationId,
    required String audioUrl,
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       recitationId = Value(recitationId),
       audioUrl = Value(audioUrl);
  static Insertable<AudioUrlCacheData> custom({
    Expression<int>? chapterId,
    Expression<int>? recitationId,
    Expression<String>? audioUrl,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (recitationId != null) 'recitation_id': recitationId,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioUrlCacheCompanion copyWith({
    Value<int>? chapterId,
    Value<int>? recitationId,
    Value<String>? audioUrl,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return AudioUrlCacheCompanion(
      chapterId: chapterId ?? this.chapterId,
      recitationId: recitationId ?? this.recitationId,
      audioUrl: audioUrl ?? this.audioUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (recitationId.present) {
      map['recitation_id'] = Variable<int>(recitationId.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioUrlCacheCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('recitationId: $recitationId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $ChapterCacheTable chapterCache = $ChapterCacheTable(this);
  late final $VerseCacheTable verseCache = $VerseCacheTable(this);
  late final $ChapterInfoCacheTable chapterInfoCache = $ChapterInfoCacheTable(
    this,
  );
  late final $AudioUrlCacheTable audioUrlCache = $AudioUrlCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarks,
    readingProgress,
    chapterCache,
    verseCache,
    chapterInfoCache,
    audioUrlCache,
  ];
}

typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required int surahId,
  required int verseId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> surahId,
  Value<int> verseId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahId = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                surahId: surahId,
                verseId: verseId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int surahId,
                required int verseId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                surahId: surahId,
                verseId: verseId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, Bookmark>(table),
                  BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<int> id,
      required int surahId,
      required int verseId,
      Value<DateTime> updatedAt,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<int> id,
      Value<int> surahId,
      Value<int> verseId,
      Value<DateTime> updatedAt,
    });

class $$ReadingProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (
            ReadingProgressData,
            BaseReferences<
              _$AppDatabase,
              $ReadingProgressTable,
              ReadingProgressData
            >,
          ),
          ReadingProgressData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingProgressCompanion(
                id: id,
                surahId: surahId,
                verseId: verseId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int verseId,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                id: id,
                surahId: surahId,
                verseId: verseId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingProgressTable, ReadingProgressData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadingProgressTable,
                    ReadingProgressData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTable,
      ReadingProgressData,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (
        ReadingProgressData,
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData
        >,
      ),
      ReadingProgressData,
      PrefetchHooks Function()
    >;
typedef $$ChapterCacheTableCreateCompanionBuilder =
    ChapterCacheCompanion Function({
      required String language,
      required int chapterId,
      required String nameSimple,
      required String nameArabic,
      required String revelationPlace,
      required int versesCount,
      required String translatedName,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });
typedef $$ChapterCacheTableUpdateCompanionBuilder =
    ChapterCacheCompanion Function({
      Value<String> language,
      Value<int> chapterId,
      Value<String> nameSimple,
      Value<String> nameArabic,
      Value<String> revelationPlace,
      Value<int> versesCount,
      Value<String> translatedName,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ChapterCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterCacheTable> {
  $$ChapterCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterCacheTable> {
  $$ChapterCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterCacheTable> {
  $$ChapterCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ChapterCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterCacheTable,
          ChapterCacheData,
          $$ChapterCacheTableFilterComposer,
          $$ChapterCacheTableOrderingComposer,
          $$ChapterCacheTableAnnotationComposer,
          $$ChapterCacheTableCreateCompanionBuilder,
          $$ChapterCacheTableUpdateCompanionBuilder,
          (
            ChapterCacheData,
            BaseReferences<_$AppDatabase, $ChapterCacheTable, ChapterCacheData>,
          ),
          ChapterCacheData,
          PrefetchHooks Function()
        > {
  $$ChapterCacheTableTableManager(_$AppDatabase db, $ChapterCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> language = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<String> nameSimple = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> revelationPlace = const Value.absent(),
                Value<int> versesCount = const Value.absent(),
                Value<String> translatedName = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterCacheCompanion(
                language: language,
                chapterId: chapterId,
                nameSimple: nameSimple,
                nameArabic: nameArabic,
                revelationPlace: revelationPlace,
                versesCount: versesCount,
                translatedName: translatedName,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String language,
                required int chapterId,
                required String nameSimple,
                required String nameArabic,
                required String revelationPlace,
                required int versesCount,
                required String translatedName,
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterCacheCompanion.insert(
                language: language,
                chapterId: chapterId,
                nameSimple: nameSimple,
                nameArabic: nameArabic,
                revelationPlace: revelationPlace,
                versesCount: versesCount,
                translatedName: translatedName,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChapterCacheTable, ChapterCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChapterCacheTable,
                    ChapterCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterCacheTable,
      ChapterCacheData,
      $$ChapterCacheTableFilterComposer,
      $$ChapterCacheTableOrderingComposer,
      $$ChapterCacheTableAnnotationComposer,
      $$ChapterCacheTableCreateCompanionBuilder,
      $$ChapterCacheTableUpdateCompanionBuilder,
      (
        ChapterCacheData,
        BaseReferences<_$AppDatabase, $ChapterCacheTable, ChapterCacheData>,
      ),
      ChapterCacheData,
      PrefetchHooks Function()
    >;
typedef $$VerseCacheTableCreateCompanionBuilder = VerseCacheCompanion Function({
  required int chapterId,
  required int verseNumber,
  required int translationId,
  required String arabic,
  Value<String> translation,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});
typedef $$VerseCacheTableUpdateCompanionBuilder = VerseCacheCompanion Function({
  Value<int> chapterId,
  Value<int> verseNumber,
  Value<int> translationId,
  Value<String> arabic,
  Value<String> translation,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$VerseCacheTableFilterComposer
    extends Composer<_$AppDatabase, $VerseCacheTable> {
  $$VerseCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerseCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseCacheTable> {
  $$VerseCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerseCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseCacheTable> {
  $$VerseCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arabic =>
      $composableBuilder(column: $table.arabic, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$VerseCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseCacheTable,
          VerseCacheData,
          $$VerseCacheTableFilterComposer,
          $$VerseCacheTableOrderingComposer,
          $$VerseCacheTableAnnotationComposer,
          $$VerseCacheTableCreateCompanionBuilder,
          $$VerseCacheTableUpdateCompanionBuilder,
          (
            VerseCacheData,
            BaseReferences<_$AppDatabase, $VerseCacheTable, VerseCacheData>,
          ),
          VerseCacheData,
          PrefetchHooks Function()
        > {
  $$VerseCacheTableTableManager(_$AppDatabase db, $VerseCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chapterId = const Value.absent(),
                Value<int> verseNumber = const Value.absent(),
                Value<int> translationId = const Value.absent(),
                Value<String> arabic = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VerseCacheCompanion(
                chapterId: chapterId,
                verseNumber: verseNumber,
                translationId: translationId,
                arabic: arabic,
                translation: translation,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chapterId,
                required int verseNumber,
                required int translationId,
                required String arabic,
                Value<String> translation = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VerseCacheCompanion.insert(
                chapterId: chapterId,
                verseNumber: verseNumber,
                translationId: translationId,
                arabic: arabic,
                translation: translation,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerseCacheTable, VerseCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $VerseCacheTable,
                    VerseCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerseCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseCacheTable,
      VerseCacheData,
      $$VerseCacheTableFilterComposer,
      $$VerseCacheTableOrderingComposer,
      $$VerseCacheTableAnnotationComposer,
      $$VerseCacheTableCreateCompanionBuilder,
      $$VerseCacheTableUpdateCompanionBuilder,
      (
        VerseCacheData,
        BaseReferences<_$AppDatabase, $VerseCacheTable, VerseCacheData>,
      ),
      VerseCacheData,
      PrefetchHooks Function()
    >;
typedef $$ChapterInfoCacheTableCreateCompanionBuilder =
    ChapterInfoCacheCompanion Function({
      required int chapterId,
      required String language,
      required String shortText,
      required String textHtml,
      required String source,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });
typedef $$ChapterInfoCacheTableUpdateCompanionBuilder =
    ChapterInfoCacheCompanion Function({
      Value<int> chapterId,
      Value<String> language,
      Value<String> shortText,
      Value<String> textHtml,
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ChapterInfoCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterInfoCacheTable> {
  $$ChapterInfoCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortText => $composableBuilder(
    column: $table.shortText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textHtml => $composableBuilder(
    column: $table.textHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterInfoCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterInfoCacheTable> {
  $$ChapterInfoCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortText => $composableBuilder(
    column: $table.shortText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textHtml => $composableBuilder(
    column: $table.textHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterInfoCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterInfoCacheTable> {
  $$ChapterInfoCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get shortText =>
      $composableBuilder(column: $table.shortText, builder: (column) => column);

  GeneratedColumn<String> get textHtml =>
      $composableBuilder(column: $table.textHtml, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ChapterInfoCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterInfoCacheTable,
          ChapterInfoCacheData,
          $$ChapterInfoCacheTableFilterComposer,
          $$ChapterInfoCacheTableOrderingComposer,
          $$ChapterInfoCacheTableAnnotationComposer,
          $$ChapterInfoCacheTableCreateCompanionBuilder,
          $$ChapterInfoCacheTableUpdateCompanionBuilder,
          (
            ChapterInfoCacheData,
            BaseReferences<
              _$AppDatabase,
              $ChapterInfoCacheTable,
              ChapterInfoCacheData
            >,
          ),
          ChapterInfoCacheData,
          PrefetchHooks Function()
        > {
  $$ChapterInfoCacheTableTableManager(
    _$AppDatabase db,
    $ChapterInfoCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterInfoCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterInfoCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterInfoCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chapterId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> shortText = const Value.absent(),
                Value<String> textHtml = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterInfoCacheCompanion(
                chapterId: chapterId,
                language: language,
                shortText: shortText,
                textHtml: textHtml,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chapterId,
                required String language,
                required String shortText,
                required String textHtml,
                required String source,
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterInfoCacheCompanion.insert(
                chapterId: chapterId,
                language: language,
                shortText: shortText,
                textHtml: textHtml,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChapterInfoCacheTable, ChapterInfoCacheData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ChapterInfoCacheTable,
                    ChapterInfoCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterInfoCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterInfoCacheTable,
      ChapterInfoCacheData,
      $$ChapterInfoCacheTableFilterComposer,
      $$ChapterInfoCacheTableOrderingComposer,
      $$ChapterInfoCacheTableAnnotationComposer,
      $$ChapterInfoCacheTableCreateCompanionBuilder,
      $$ChapterInfoCacheTableUpdateCompanionBuilder,
      (
        ChapterInfoCacheData,
        BaseReferences<
          _$AppDatabase,
          $ChapterInfoCacheTable,
          ChapterInfoCacheData
        >,
      ),
      ChapterInfoCacheData,
      PrefetchHooks Function()
    >;
typedef $$AudioUrlCacheTableCreateCompanionBuilder =
    AudioUrlCacheCompanion Function({
      required int chapterId,
      required int recitationId,
      required String audioUrl,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });
typedef $$AudioUrlCacheTableUpdateCompanionBuilder =
    AudioUrlCacheCompanion Function({
      Value<int> chapterId,
      Value<int> recitationId,
      Value<String> audioUrl,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$AudioUrlCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AudioUrlCacheTable> {
  $$AudioUrlCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioUrlCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioUrlCacheTable> {
  $$AudioUrlCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioUrlCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioUrlCacheTable> {
  $$AudioUrlCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$AudioUrlCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioUrlCacheTable,
          AudioUrlCacheData,
          $$AudioUrlCacheTableFilterComposer,
          $$AudioUrlCacheTableOrderingComposer,
          $$AudioUrlCacheTableAnnotationComposer,
          $$AudioUrlCacheTableCreateCompanionBuilder,
          $$AudioUrlCacheTableUpdateCompanionBuilder,
          (
            AudioUrlCacheData,
            BaseReferences<
              _$AppDatabase,
              $AudioUrlCacheTable,
              AudioUrlCacheData
            >,
          ),
          AudioUrlCacheData,
          PrefetchHooks Function()
        > {
  $$AudioUrlCacheTableTableManager(_$AppDatabase db, $AudioUrlCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioUrlCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioUrlCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioUrlCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chapterId = const Value.absent(),
                Value<int> recitationId = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioUrlCacheCompanion(
                chapterId: chapterId,
                recitationId: recitationId,
                audioUrl: audioUrl,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chapterId,
                required int recitationId,
                required String audioUrl,
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioUrlCacheCompanion.insert(
                chapterId: chapterId,
                recitationId: recitationId,
                audioUrl: audioUrl,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioUrlCacheTable, AudioUrlCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AudioUrlCacheTable,
                    AudioUrlCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioUrlCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioUrlCacheTable,
      AudioUrlCacheData,
      $$AudioUrlCacheTableFilterComposer,
      $$AudioUrlCacheTableOrderingComposer,
      $$AudioUrlCacheTableAnnotationComposer,
      $$AudioUrlCacheTableCreateCompanionBuilder,
      $$AudioUrlCacheTableUpdateCompanionBuilder,
      (
        AudioUrlCacheData,
        BaseReferences<_$AppDatabase, $AudioUrlCacheTable, AudioUrlCacheData>,
      ),
      AudioUrlCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$ChapterCacheTableTableManager get chapterCache =>
      $$ChapterCacheTableTableManager(_db, _db.chapterCache);
  $$VerseCacheTableTableManager get verseCache =>
      $$VerseCacheTableTableManager(_db, _db.verseCache);
  $$ChapterInfoCacheTableTableManager get chapterInfoCache =>
      $$ChapterInfoCacheTableTableManager(_db, _db.chapterInfoCache);
  $$AudioUrlCacheTableTableManager get audioUrlCache =>
      $$AudioUrlCacheTableTableManager(_db, _db.audioUrlCache);
}
