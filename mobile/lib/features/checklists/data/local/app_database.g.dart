// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTemplateVersionsTable extends LocalTemplateVersions
    with TableInfo<$LocalTemplateVersionsTable, LocalTemplateVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTemplateVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    versionNumber,
    status,
    revision,
    checksum,
    publishedAt,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_template_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTemplateVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTemplateVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTemplateVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $LocalTemplateVersionsTable createAlias(String alias) {
    return $LocalTemplateVersionsTable(attachedDatabase, alias);
  }
}

class LocalTemplateVersion extends DataClass
    implements Insertable<LocalTemplateVersion> {
  final String id;
  final String templateId;
  final int versionNumber;
  final String status;
  final int revision;
  final String? checksum;
  final DateTime? publishedAt;
  final String rawJson;
  const LocalTemplateVersion({
    required this.id,
    required this.templateId,
    required this.versionNumber,
    required this.status,
    required this.revision,
    this.checksum,
    this.publishedAt,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['version_number'] = Variable<int>(versionNumber);
    map['status'] = Variable<String>(status);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  LocalTemplateVersionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTemplateVersionsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      versionNumber: Value(versionNumber),
      status: Value(status),
      revision: Value(revision),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      rawJson: Value(rawJson),
    );
  }

  factory LocalTemplateVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTemplateVersion(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      status: serializer.fromJson<String>(json['status']),
      revision: serializer.fromJson<int>(json['revision']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'status': serializer.toJson<String>(status),
      'revision': serializer.toJson<int>(revision),
      'checksum': serializer.toJson<String?>(checksum),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  LocalTemplateVersion copyWith({
    String? id,
    String? templateId,
    int? versionNumber,
    String? status,
    int? revision,
    Value<String?> checksum = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    String? rawJson,
  }) => LocalTemplateVersion(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    versionNumber: versionNumber ?? this.versionNumber,
    status: status ?? this.status,
    revision: revision ?? this.revision,
    checksum: checksum.present ? checksum.value : this.checksum,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    rawJson: rawJson ?? this.rawJson,
  );
  LocalTemplateVersion copyWithCompanion(LocalTemplateVersionsCompanion data) {
    return LocalTemplateVersion(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      status: data.status.present ? data.status.value : this.status,
      revision: data.revision.present ? data.revision.value : this.revision,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateVersion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('checksum: $checksum, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    versionNumber,
    status,
    revision,
    checksum,
    publishedAt,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTemplateVersion &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.versionNumber == this.versionNumber &&
          other.status == this.status &&
          other.revision == this.revision &&
          other.checksum == this.checksum &&
          other.publishedAt == this.publishedAt &&
          other.rawJson == this.rawJson);
}

class LocalTemplateVersionsCompanion
    extends UpdateCompanion<LocalTemplateVersion> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<int> versionNumber;
  final Value<String> status;
  final Value<int> revision;
  final Value<String?> checksum;
  final Value<DateTime?> publishedAt;
  final Value<String> rawJson;
  final Value<int> rowid;
  const LocalTemplateVersionsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.revision = const Value.absent(),
    this.checksum = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTemplateVersionsCompanion.insert({
    required String id,
    required String templateId,
    required int versionNumber,
    required String status,
    required int revision,
    this.checksum = const Value.absent(),
    this.publishedAt = const Value.absent(),
    required String rawJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       versionNumber = Value(versionNumber),
       status = Value(status),
       revision = Value(revision),
       rawJson = Value(rawJson);
  static Insertable<LocalTemplateVersion> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<int>? versionNumber,
    Expression<String>? status,
    Expression<int>? revision,
    Expression<String>? checksum,
    Expression<DateTime>? publishedAt,
    Expression<String>? rawJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (status != null) 'status': status,
      if (revision != null) 'revision': revision,
      if (checksum != null) 'checksum': checksum,
      if (publishedAt != null) 'published_at': publishedAt,
      if (rawJson != null) 'raw_json': rawJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTemplateVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<int>? versionNumber,
    Value<String>? status,
    Value<int>? revision,
    Value<String?>? checksum,
    Value<DateTime?>? publishedAt,
    Value<String>? rawJson,
    Value<int>? rowid,
  }) {
    return LocalTemplateVersionsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      checksum: checksum ?? this.checksum,
      publishedAt: publishedAt ?? this.publishedAt,
      rawJson: rawJson ?? this.rawJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateVersionsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('checksum: $checksum, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTemplateSectionsTable extends LocalTemplateSections
    with TableInfo<$LocalTemplateSectionsTable, LocalTemplateSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTemplateSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateVersionIdMeta = const VerificationMeta(
    'templateVersionId',
  );
  @override
  late final GeneratedColumn<String> templateVersionId =
      GeneratedColumn<String>(
        'template_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateVersionId,
    title,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_template_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTemplateSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_version_id')) {
      context.handle(
        _templateVersionIdMeta,
        templateVersionId.isAcceptableOrUnknown(
          data['template_version_id']!,
          _templateVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateVersionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTemplateSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTemplateSection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_version_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LocalTemplateSectionsTable createAlias(String alias) {
    return $LocalTemplateSectionsTable(attachedDatabase, alias);
  }
}

class LocalTemplateSection extends DataClass
    implements Insertable<LocalTemplateSection> {
  final String id;
  final String templateVersionId;
  final String title;
  final int sortOrder;
  const LocalTemplateSection({
    required this.id,
    required this.templateVersionId,
    required this.title,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_version_id'] = Variable<String>(templateVersionId);
    map['title'] = Variable<String>(title);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalTemplateSectionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTemplateSectionsCompanion(
      id: Value(id),
      templateVersionId: Value(templateVersionId),
      title: Value(title),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalTemplateSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTemplateSection(
      id: serializer.fromJson<String>(json['id']),
      templateVersionId: serializer.fromJson<String>(json['templateVersionId']),
      title: serializer.fromJson<String>(json['title']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateVersionId': serializer.toJson<String>(templateVersionId),
      'title': serializer.toJson<String>(title),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalTemplateSection copyWith({
    String? id,
    String? templateVersionId,
    String? title,
    int? sortOrder,
  }) => LocalTemplateSection(
    id: id ?? this.id,
    templateVersionId: templateVersionId ?? this.templateVersionId,
    title: title ?? this.title,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalTemplateSection copyWithCompanion(LocalTemplateSectionsCompanion data) {
    return LocalTemplateSection(
      id: data.id.present ? data.id.value : this.id,
      templateVersionId: data.templateVersionId.present
          ? data.templateVersionId.value
          : this.templateVersionId,
      title: data.title.present ? data.title.value : this.title,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateSection(')
          ..write('id: $id, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateVersionId, title, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTemplateSection &&
          other.id == this.id &&
          other.templateVersionId == this.templateVersionId &&
          other.title == this.title &&
          other.sortOrder == this.sortOrder);
}

class LocalTemplateSectionsCompanion
    extends UpdateCompanion<LocalTemplateSection> {
  final Value<String> id;
  final Value<String> templateVersionId;
  final Value<String> title;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalTemplateSectionsCompanion({
    this.id = const Value.absent(),
    this.templateVersionId = const Value.absent(),
    this.title = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTemplateSectionsCompanion.insert({
    required String id,
    required String templateVersionId,
    required String title,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateVersionId = Value(templateVersionId),
       title = Value(title),
       sortOrder = Value(sortOrder);
  static Insertable<LocalTemplateSection> custom({
    Expression<String>? id,
    Expression<String>? templateVersionId,
    Expression<String>? title,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateVersionId != null) 'template_version_id': templateVersionId,
      if (title != null) 'title': title,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTemplateSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateVersionId,
    Value<String>? title,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalTemplateSectionsCompanion(
      id: id ?? this.id,
      templateVersionId: templateVersionId ?? this.templateVersionId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateVersionId.present) {
      map['template_version_id'] = Variable<String>(templateVersionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateSectionsCompanion(')
          ..write('id: $id, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTemplateItemsTable extends LocalTemplateItems
    with TableInfo<$LocalTemplateItemsTable, LocalTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateVersionIdMeta = const VerificationMeta(
    'templateVersionId',
  );
  @override
  late final GeneratedColumn<String> templateVersionId =
      GeneratedColumn<String>(
        'template_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePrintedNumberMeta =
      const VerificationMeta('sourcePrintedNumber');
  @override
  late final GeneratedColumn<String> sourcePrintedNumber =
      GeneratedColumn<String>(
        'source_printed_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredOnCompleteMeta =
      const VerificationMeta('requiredOnComplete');
  @override
  late final GeneratedColumn<bool> requiredOnComplete = GeneratedColumn<bool>(
    'required_on_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("required_on_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _requireObservationWhenNcMeta =
      const VerificationMeta('requireObservationWhenNc');
  @override
  late final GeneratedColumn<bool> requireObservationWhenNc =
      GeneratedColumn<bool>(
        'require_observation_when_nc',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("require_observation_when_nc" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _requirePhotoWhenNcMeta =
      const VerificationMeta('requirePhotoWhenNc');
  @override
  late final GeneratedColumn<bool> requirePhotoWhenNc = GeneratedColumn<bool>(
    'require_photo_when_nc',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_photo_when_nc" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateVersionId,
    sectionId,
    sourcePrintedNumber,
    textValue,
    sortOrder,
    requiredOnComplete,
    requireObservationWhenNc,
    requirePhotoWhenNc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_template_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTemplateItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_version_id')) {
      context.handle(
        _templateVersionIdMeta,
        templateVersionId.isAcceptableOrUnknown(
          data['template_version_id']!,
          _templateVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateVersionIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('source_printed_number')) {
      context.handle(
        _sourcePrintedNumberMeta,
        sourcePrintedNumber.isAcceptableOrUnknown(
          data['source_printed_number']!,
          _sourcePrintedNumberMeta,
        ),
      );
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('required_on_complete')) {
      context.handle(
        _requiredOnCompleteMeta,
        requiredOnComplete.isAcceptableOrUnknown(
          data['required_on_complete']!,
          _requiredOnCompleteMeta,
        ),
      );
    }
    if (data.containsKey('require_observation_when_nc')) {
      context.handle(
        _requireObservationWhenNcMeta,
        requireObservationWhenNc.isAcceptableOrUnknown(
          data['require_observation_when_nc']!,
          _requireObservationWhenNcMeta,
        ),
      );
    }
    if (data.containsKey('require_photo_when_nc')) {
      context.handle(
        _requirePhotoWhenNcMeta,
        requirePhotoWhenNc.isAcceptableOrUnknown(
          data['require_photo_when_nc']!,
          _requirePhotoWhenNcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTemplateItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_version_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      sourcePrintedNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_printed_number'],
      ),
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      requiredOnComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required_on_complete'],
      )!,
      requireObservationWhenNc: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_observation_when_nc'],
      )!,
      requirePhotoWhenNc: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_photo_when_nc'],
      )!,
    );
  }

  @override
  $LocalTemplateItemsTable createAlias(String alias) {
    return $LocalTemplateItemsTable(attachedDatabase, alias);
  }
}

class LocalTemplateItem extends DataClass
    implements Insertable<LocalTemplateItem> {
  final String id;
  final String templateVersionId;
  final String sectionId;
  final String? sourcePrintedNumber;
  final String textValue;
  final int sortOrder;
  final bool requiredOnComplete;
  final bool requireObservationWhenNc;
  final bool requirePhotoWhenNc;
  const LocalTemplateItem({
    required this.id,
    required this.templateVersionId,
    required this.sectionId,
    this.sourcePrintedNumber,
    required this.textValue,
    required this.sortOrder,
    required this.requiredOnComplete,
    required this.requireObservationWhenNc,
    required this.requirePhotoWhenNc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_version_id'] = Variable<String>(templateVersionId);
    map['section_id'] = Variable<String>(sectionId);
    if (!nullToAbsent || sourcePrintedNumber != null) {
      map['source_printed_number'] = Variable<String>(sourcePrintedNumber);
    }
    map['text_value'] = Variable<String>(textValue);
    map['sort_order'] = Variable<int>(sortOrder);
    map['required_on_complete'] = Variable<bool>(requiredOnComplete);
    map['require_observation_when_nc'] = Variable<bool>(
      requireObservationWhenNc,
    );
    map['require_photo_when_nc'] = Variable<bool>(requirePhotoWhenNc);
    return map;
  }

  LocalTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalTemplateItemsCompanion(
      id: Value(id),
      templateVersionId: Value(templateVersionId),
      sectionId: Value(sectionId),
      sourcePrintedNumber: sourcePrintedNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePrintedNumber),
      textValue: Value(textValue),
      sortOrder: Value(sortOrder),
      requiredOnComplete: Value(requiredOnComplete),
      requireObservationWhenNc: Value(requireObservationWhenNc),
      requirePhotoWhenNc: Value(requirePhotoWhenNc),
    );
  }

  factory LocalTemplateItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTemplateItem(
      id: serializer.fromJson<String>(json['id']),
      templateVersionId: serializer.fromJson<String>(json['templateVersionId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      sourcePrintedNumber: serializer.fromJson<String?>(
        json['sourcePrintedNumber'],
      ),
      textValue: serializer.fromJson<String>(json['textValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      requiredOnComplete: serializer.fromJson<bool>(json['requiredOnComplete']),
      requireObservationWhenNc: serializer.fromJson<bool>(
        json['requireObservationWhenNc'],
      ),
      requirePhotoWhenNc: serializer.fromJson<bool>(json['requirePhotoWhenNc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateVersionId': serializer.toJson<String>(templateVersionId),
      'sectionId': serializer.toJson<String>(sectionId),
      'sourcePrintedNumber': serializer.toJson<String?>(sourcePrintedNumber),
      'textValue': serializer.toJson<String>(textValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'requiredOnComplete': serializer.toJson<bool>(requiredOnComplete),
      'requireObservationWhenNc': serializer.toJson<bool>(
        requireObservationWhenNc,
      ),
      'requirePhotoWhenNc': serializer.toJson<bool>(requirePhotoWhenNc),
    };
  }

  LocalTemplateItem copyWith({
    String? id,
    String? templateVersionId,
    String? sectionId,
    Value<String?> sourcePrintedNumber = const Value.absent(),
    String? textValue,
    int? sortOrder,
    bool? requiredOnComplete,
    bool? requireObservationWhenNc,
    bool? requirePhotoWhenNc,
  }) => LocalTemplateItem(
    id: id ?? this.id,
    templateVersionId: templateVersionId ?? this.templateVersionId,
    sectionId: sectionId ?? this.sectionId,
    sourcePrintedNumber: sourcePrintedNumber.present
        ? sourcePrintedNumber.value
        : this.sourcePrintedNumber,
    textValue: textValue ?? this.textValue,
    sortOrder: sortOrder ?? this.sortOrder,
    requiredOnComplete: requiredOnComplete ?? this.requiredOnComplete,
    requireObservationWhenNc:
        requireObservationWhenNc ?? this.requireObservationWhenNc,
    requirePhotoWhenNc: requirePhotoWhenNc ?? this.requirePhotoWhenNc,
  );
  LocalTemplateItem copyWithCompanion(LocalTemplateItemsCompanion data) {
    return LocalTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      templateVersionId: data.templateVersionId.present
          ? data.templateVersionId.value
          : this.templateVersionId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      sourcePrintedNumber: data.sourcePrintedNumber.present
          ? data.sourcePrintedNumber.value
          : this.sourcePrintedNumber,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      requiredOnComplete: data.requiredOnComplete.present
          ? data.requiredOnComplete.value
          : this.requiredOnComplete,
      requireObservationWhenNc: data.requireObservationWhenNc.present
          ? data.requireObservationWhenNc.value
          : this.requireObservationWhenNc,
      requirePhotoWhenNc: data.requirePhotoWhenNc.present
          ? data.requirePhotoWhenNc.value
          : this.requirePhotoWhenNc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateItem(')
          ..write('id: $id, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('sourcePrintedNumber: $sourcePrintedNumber, ')
          ..write('textValue: $textValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('requiredOnComplete: $requiredOnComplete, ')
          ..write('requireObservationWhenNc: $requireObservationWhenNc, ')
          ..write('requirePhotoWhenNc: $requirePhotoWhenNc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateVersionId,
    sectionId,
    sourcePrintedNumber,
    textValue,
    sortOrder,
    requiredOnComplete,
    requireObservationWhenNc,
    requirePhotoWhenNc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTemplateItem &&
          other.id == this.id &&
          other.templateVersionId == this.templateVersionId &&
          other.sectionId == this.sectionId &&
          other.sourcePrintedNumber == this.sourcePrintedNumber &&
          other.textValue == this.textValue &&
          other.sortOrder == this.sortOrder &&
          other.requiredOnComplete == this.requiredOnComplete &&
          other.requireObservationWhenNc == this.requireObservationWhenNc &&
          other.requirePhotoWhenNc == this.requirePhotoWhenNc);
}

class LocalTemplateItemsCompanion extends UpdateCompanion<LocalTemplateItem> {
  final Value<String> id;
  final Value<String> templateVersionId;
  final Value<String> sectionId;
  final Value<String?> sourcePrintedNumber;
  final Value<String> textValue;
  final Value<int> sortOrder;
  final Value<bool> requiredOnComplete;
  final Value<bool> requireObservationWhenNc;
  final Value<bool> requirePhotoWhenNc;
  final Value<int> rowid;
  const LocalTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.templateVersionId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.sourcePrintedNumber = const Value.absent(),
    this.textValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.requiredOnComplete = const Value.absent(),
    this.requireObservationWhenNc = const Value.absent(),
    this.requirePhotoWhenNc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTemplateItemsCompanion.insert({
    required String id,
    required String templateVersionId,
    required String sectionId,
    this.sourcePrintedNumber = const Value.absent(),
    required String textValue,
    required int sortOrder,
    this.requiredOnComplete = const Value.absent(),
    this.requireObservationWhenNc = const Value.absent(),
    this.requirePhotoWhenNc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateVersionId = Value(templateVersionId),
       sectionId = Value(sectionId),
       textValue = Value(textValue),
       sortOrder = Value(sortOrder);
  static Insertable<LocalTemplateItem> custom({
    Expression<String>? id,
    Expression<String>? templateVersionId,
    Expression<String>? sectionId,
    Expression<String>? sourcePrintedNumber,
    Expression<String>? textValue,
    Expression<int>? sortOrder,
    Expression<bool>? requiredOnComplete,
    Expression<bool>? requireObservationWhenNc,
    Expression<bool>? requirePhotoWhenNc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateVersionId != null) 'template_version_id': templateVersionId,
      if (sectionId != null) 'section_id': sectionId,
      if (sourcePrintedNumber != null)
        'source_printed_number': sourcePrintedNumber,
      if (textValue != null) 'text_value': textValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (requiredOnComplete != null)
        'required_on_complete': requiredOnComplete,
      if (requireObservationWhenNc != null)
        'require_observation_when_nc': requireObservationWhenNc,
      if (requirePhotoWhenNc != null)
        'require_photo_when_nc': requirePhotoWhenNc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTemplateItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateVersionId,
    Value<String>? sectionId,
    Value<String?>? sourcePrintedNumber,
    Value<String>? textValue,
    Value<int>? sortOrder,
    Value<bool>? requiredOnComplete,
    Value<bool>? requireObservationWhenNc,
    Value<bool>? requirePhotoWhenNc,
    Value<int>? rowid,
  }) {
    return LocalTemplateItemsCompanion(
      id: id ?? this.id,
      templateVersionId: templateVersionId ?? this.templateVersionId,
      sectionId: sectionId ?? this.sectionId,
      sourcePrintedNumber: sourcePrintedNumber ?? this.sourcePrintedNumber,
      textValue: textValue ?? this.textValue,
      sortOrder: sortOrder ?? this.sortOrder,
      requiredOnComplete: requiredOnComplete ?? this.requiredOnComplete,
      requireObservationWhenNc:
          requireObservationWhenNc ?? this.requireObservationWhenNc,
      requirePhotoWhenNc: requirePhotoWhenNc ?? this.requirePhotoWhenNc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateVersionId.present) {
      map['template_version_id'] = Variable<String>(templateVersionId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (sourcePrintedNumber.present) {
      map['source_printed_number'] = Variable<String>(
        sourcePrintedNumber.value,
      );
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (requiredOnComplete.present) {
      map['required_on_complete'] = Variable<bool>(requiredOnComplete.value);
    }
    if (requireObservationWhenNc.present) {
      map['require_observation_when_nc'] = Variable<bool>(
        requireObservationWhenNc.value,
      );
    }
    if (requirePhotoWhenNc.present) {
      map['require_photo_when_nc'] = Variable<bool>(requirePhotoWhenNc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('sourcePrintedNumber: $sourcePrintedNumber, ')
          ..write('textValue: $textValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('requiredOnComplete: $requiredOnComplete, ')
          ..write('requireObservationWhenNc: $requireObservationWhenNc, ')
          ..write('requirePhotoWhenNc: $requirePhotoWhenNc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetsTable extends LocalAssets
    with TableInfo<$LocalAssetsTable, LocalAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _makeModelMeta = const VerificationMeta(
    'makeModel',
  );
  @override
  late final GeneratedColumn<String> makeModel = GeneratedColumn<String>(
    'make_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufactureYearMeta = const VerificationMeta(
    'manufactureYear',
  );
  @override
  late final GeneratedColumn<int> manufactureYear = GeneratedColumn<int>(
    'manufacture_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _predominantColorMeta = const VerificationMeta(
    'predominantColor',
  );
  @override
  late final GeneratedColumn<String> predominantColor = GeneratedColumn<String>(
    'predominant_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownershipTypeMeta = const VerificationMeta(
    'ownershipType',
  );
  @override
  late final GeneratedColumn<String> ownershipType = GeneratedColumn<String>(
    'ownership_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OWN'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    code,
    active,
    revision,
    siteId,
    licensePlate,
    makeModel,
    manufacturer,
    manufactureYear,
    predominantColor,
    ownershipType,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    } else if (isInserting) {
      context.missing(_activeMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    }
    if (data.containsKey('make_model')) {
      context.handle(
        _makeModelMeta,
        makeModel.isAcceptableOrUnknown(data['make_model']!, _makeModelMeta),
      );
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('manufacture_year')) {
      context.handle(
        _manufactureYearMeta,
        manufactureYear.isAcceptableOrUnknown(
          data['manufacture_year']!,
          _manufactureYearMeta,
        ),
      );
    }
    if (data.containsKey('predominant_color')) {
      context.handle(
        _predominantColorMeta,
        predominantColor.isAcceptableOrUnknown(
          data['predominant_color']!,
          _predominantColorMeta,
        ),
      );
    }
    if (data.containsKey('ownership_type')) {
      context.handle(
        _ownershipTypeMeta,
        ownershipType.isAcceptableOrUnknown(
          data['ownership_type']!,
          _ownershipTypeMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      ),
      makeModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make_model'],
      ),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      manufactureYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manufacture_year'],
      ),
      predominantColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predominant_color'],
      ),
      ownershipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_type'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $LocalAssetsTable createAlias(String alias) {
    return $LocalAssetsTable(attachedDatabase, alias);
  }
}

class LocalAsset extends DataClass implements Insertable<LocalAsset> {
  final String id;
  final String kind;
  final String code;
  final bool active;
  final int revision;
  final String? siteId;
  final String? licensePlate;
  final String? makeModel;
  final String? manufacturer;
  final int? manufactureYear;
  final String? predominantColor;
  final String ownershipType;
  final String rawJson;
  const LocalAsset({
    required this.id,
    required this.kind,
    required this.code,
    required this.active,
    required this.revision,
    this.siteId,
    this.licensePlate,
    this.makeModel,
    this.manufacturer,
    this.manufactureYear,
    this.predominantColor,
    required this.ownershipType,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['code'] = Variable<String>(code);
    map['active'] = Variable<bool>(active);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    if (!nullToAbsent || licensePlate != null) {
      map['license_plate'] = Variable<String>(licensePlate);
    }
    if (!nullToAbsent || makeModel != null) {
      map['make_model'] = Variable<String>(makeModel);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || manufactureYear != null) {
      map['manufacture_year'] = Variable<int>(manufactureYear);
    }
    if (!nullToAbsent || predominantColor != null) {
      map['predominant_color'] = Variable<String>(predominantColor);
    }
    map['ownership_type'] = Variable<String>(ownershipType);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  LocalAssetsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetsCompanion(
      id: Value(id),
      kind: Value(kind),
      code: Value(code),
      active: Value(active),
      revision: Value(revision),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      licensePlate: licensePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(licensePlate),
      makeModel: makeModel == null && nullToAbsent
          ? const Value.absent()
          : Value(makeModel),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      manufactureYear: manufactureYear == null && nullToAbsent
          ? const Value.absent()
          : Value(manufactureYear),
      predominantColor: predominantColor == null && nullToAbsent
          ? const Value.absent()
          : Value(predominantColor),
      ownershipType: Value(ownershipType),
      rawJson: Value(rawJson),
    );
  }

  factory LocalAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAsset(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      code: serializer.fromJson<String>(json['code']),
      active: serializer.fromJson<bool>(json['active']),
      revision: serializer.fromJson<int>(json['revision']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      licensePlate: serializer.fromJson<String?>(json['licensePlate']),
      makeModel: serializer.fromJson<String?>(json['makeModel']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      manufactureYear: serializer.fromJson<int?>(json['manufactureYear']),
      predominantColor: serializer.fromJson<String?>(json['predominantColor']),
      ownershipType: serializer.fromJson<String>(json['ownershipType']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'code': serializer.toJson<String>(code),
      'active': serializer.toJson<bool>(active),
      'revision': serializer.toJson<int>(revision),
      'siteId': serializer.toJson<String?>(siteId),
      'licensePlate': serializer.toJson<String?>(licensePlate),
      'makeModel': serializer.toJson<String?>(makeModel),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'manufactureYear': serializer.toJson<int?>(manufactureYear),
      'predominantColor': serializer.toJson<String?>(predominantColor),
      'ownershipType': serializer.toJson<String>(ownershipType),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  LocalAsset copyWith({
    String? id,
    String? kind,
    String? code,
    bool? active,
    int? revision,
    Value<String?> siteId = const Value.absent(),
    Value<String?> licensePlate = const Value.absent(),
    Value<String?> makeModel = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    Value<int?> manufactureYear = const Value.absent(),
    Value<String?> predominantColor = const Value.absent(),
    String? ownershipType,
    String? rawJson,
  }) => LocalAsset(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    code: code ?? this.code,
    active: active ?? this.active,
    revision: revision ?? this.revision,
    siteId: siteId.present ? siteId.value : this.siteId,
    licensePlate: licensePlate.present ? licensePlate.value : this.licensePlate,
    makeModel: makeModel.present ? makeModel.value : this.makeModel,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    manufactureYear: manufactureYear.present
        ? manufactureYear.value
        : this.manufactureYear,
    predominantColor: predominantColor.present
        ? predominantColor.value
        : this.predominantColor,
    ownershipType: ownershipType ?? this.ownershipType,
    rawJson: rawJson ?? this.rawJson,
  );
  LocalAsset copyWithCompanion(LocalAssetsCompanion data) {
    return LocalAsset(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      code: data.code.present ? data.code.value : this.code,
      active: data.active.present ? data.active.value : this.active,
      revision: data.revision.present ? data.revision.value : this.revision,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      makeModel: data.makeModel.present ? data.makeModel.value : this.makeModel,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      manufactureYear: data.manufactureYear.present
          ? data.manufactureYear.value
          : this.manufactureYear,
      predominantColor: data.predominantColor.present
          ? data.predominantColor.value
          : this.predominantColor,
      ownershipType: data.ownershipType.present
          ? data.ownershipType.value
          : this.ownershipType,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAsset(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('active: $active, ')
          ..write('revision: $revision, ')
          ..write('siteId: $siteId, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('makeModel: $makeModel, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('manufactureYear: $manufactureYear, ')
          ..write('predominantColor: $predominantColor, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    code,
    active,
    revision,
    siteId,
    licensePlate,
    makeModel,
    manufacturer,
    manufactureYear,
    predominantColor,
    ownershipType,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAsset &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.code == this.code &&
          other.active == this.active &&
          other.revision == this.revision &&
          other.siteId == this.siteId &&
          other.licensePlate == this.licensePlate &&
          other.makeModel == this.makeModel &&
          other.manufacturer == this.manufacturer &&
          other.manufactureYear == this.manufactureYear &&
          other.predominantColor == this.predominantColor &&
          other.ownershipType == this.ownershipType &&
          other.rawJson == this.rawJson);
}

class LocalAssetsCompanion extends UpdateCompanion<LocalAsset> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> code;
  final Value<bool> active;
  final Value<int> revision;
  final Value<String?> siteId;
  final Value<String?> licensePlate;
  final Value<String?> makeModel;
  final Value<String?> manufacturer;
  final Value<int?> manufactureYear;
  final Value<String?> predominantColor;
  final Value<String> ownershipType;
  final Value<String> rawJson;
  final Value<int> rowid;
  const LocalAssetsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.code = const Value.absent(),
    this.active = const Value.absent(),
    this.revision = const Value.absent(),
    this.siteId = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.makeModel = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.manufactureYear = const Value.absent(),
    this.predominantColor = const Value.absent(),
    this.ownershipType = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetsCompanion.insert({
    required String id,
    required String kind,
    required String code,
    required bool active,
    required int revision,
    this.siteId = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.makeModel = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.manufactureYear = const Value.absent(),
    this.predominantColor = const Value.absent(),
    this.ownershipType = const Value.absent(),
    required String rawJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       code = Value(code),
       active = Value(active),
       revision = Value(revision),
       rawJson = Value(rawJson);
  static Insertable<LocalAsset> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? code,
    Expression<bool>? active,
    Expression<int>? revision,
    Expression<String>? siteId,
    Expression<String>? licensePlate,
    Expression<String>? makeModel,
    Expression<String>? manufacturer,
    Expression<int>? manufactureYear,
    Expression<String>? predominantColor,
    Expression<String>? ownershipType,
    Expression<String>? rawJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (code != null) 'code': code,
      if (active != null) 'active': active,
      if (revision != null) 'revision': revision,
      if (siteId != null) 'site_id': siteId,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (makeModel != null) 'make_model': makeModel,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (manufactureYear != null) 'manufacture_year': manufactureYear,
      if (predominantColor != null) 'predominant_color': predominantColor,
      if (ownershipType != null) 'ownership_type': ownershipType,
      if (rawJson != null) 'raw_json': rawJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? code,
    Value<bool>? active,
    Value<int>? revision,
    Value<String?>? siteId,
    Value<String?>? licensePlate,
    Value<String?>? makeModel,
    Value<String?>? manufacturer,
    Value<int?>? manufactureYear,
    Value<String?>? predominantColor,
    Value<String>? ownershipType,
    Value<String>? rawJson,
    Value<int>? rowid,
  }) {
    return LocalAssetsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      code: code ?? this.code,
      active: active ?? this.active,
      revision: revision ?? this.revision,
      siteId: siteId ?? this.siteId,
      licensePlate: licensePlate ?? this.licensePlate,
      makeModel: makeModel ?? this.makeModel,
      manufacturer: manufacturer ?? this.manufacturer,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      predominantColor: predominantColor ?? this.predominantColor,
      ownershipType: ownershipType ?? this.ownershipType,
      rawJson: rawJson ?? this.rawJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (makeModel.present) {
      map['make_model'] = Variable<String>(makeModel.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (manufactureYear.present) {
      map['manufacture_year'] = Variable<int>(manufactureYear.value);
    }
    if (predominantColor.present) {
      map['predominant_color'] = Variable<String>(predominantColor.value);
    }
    if (ownershipType.present) {
      map['ownership_type'] = Variable<String>(ownershipType.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('code: $code, ')
          ..write('active: $active, ')
          ..write('revision: $revision, ')
          ..write('siteId: $siteId, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('makeModel: $makeModel, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('manufactureYear: $manufactureYear, ')
          ..write('predominantColor: $predominantColor, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('rawJson: $rawJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOperationConfigsTable extends LocalOperationConfigs
    with TableInfo<$LocalOperationConfigsTable, LocalOperationConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOperationConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartsOnMeta = const VerificationMeta(
    'weekStartsOn',
  );
  @override
  late final GeneratedColumn<String> weekStartsOn = GeneratedColumn<String>(
    'week_starts_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredWeekdaysJsonMeta =
      const VerificationMeta('requiredWeekdaysJson');
  @override
  late final GeneratedColumn<String> requiredWeekdaysJson =
      GeneratedColumn<String>(
        'required_weekdays_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _maxOccurrencesPerDateMeta =
      const VerificationMeta('maxOccurrencesPerDate');
  @override
  late final GeneratedColumn<int> maxOccurrencesPerDate = GeneratedColumn<int>(
    'max_occurrences_per_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    timezone,
    weekStartsOn,
    requiredWeekdaysJson,
    maxOccurrencesPerDate,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_operation_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOperationConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('week_starts_on')) {
      context.handle(
        _weekStartsOnMeta,
        weekStartsOn.isAcceptableOrUnknown(
          data['week_starts_on']!,
          _weekStartsOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartsOnMeta);
    }
    if (data.containsKey('required_weekdays_json')) {
      context.handle(
        _requiredWeekdaysJsonMeta,
        requiredWeekdaysJson.isAcceptableOrUnknown(
          data['required_weekdays_json']!,
          _requiredWeekdaysJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requiredWeekdaysJsonMeta);
    }
    if (data.containsKey('max_occurrences_per_date')) {
      context.handle(
        _maxOccurrencesPerDateMeta,
        maxOccurrencesPerDate.isAcceptableOrUnknown(
          data['max_occurrences_per_date']!,
          _maxOccurrencesPerDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxOccurrencesPerDateMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOperationConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOperationConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      weekStartsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_starts_on'],
      )!,
      requiredWeekdaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}required_weekdays_json'],
      )!,
      maxOccurrencesPerDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_occurrences_per_date'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $LocalOperationConfigsTable createAlias(String alias) {
    return $LocalOperationConfigsTable(attachedDatabase, alias);
  }
}

class LocalOperationConfig extends DataClass
    implements Insertable<LocalOperationConfig> {
  final String id;
  final String templateId;
  final String timezone;
  final String weekStartsOn;
  final String requiredWeekdaysJson;
  final int maxOccurrencesPerDate;
  final String rawJson;
  const LocalOperationConfig({
    required this.id,
    required this.templateId,
    required this.timezone,
    required this.weekStartsOn,
    required this.requiredWeekdaysJson,
    required this.maxOccurrencesPerDate,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['timezone'] = Variable<String>(timezone);
    map['week_starts_on'] = Variable<String>(weekStartsOn);
    map['required_weekdays_json'] = Variable<String>(requiredWeekdaysJson);
    map['max_occurrences_per_date'] = Variable<int>(maxOccurrencesPerDate);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  LocalOperationConfigsCompanion toCompanion(bool nullToAbsent) {
    return LocalOperationConfigsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      timezone: Value(timezone),
      weekStartsOn: Value(weekStartsOn),
      requiredWeekdaysJson: Value(requiredWeekdaysJson),
      maxOccurrencesPerDate: Value(maxOccurrencesPerDate),
      rawJson: Value(rawJson),
    );
  }

  factory LocalOperationConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOperationConfig(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      timezone: serializer.fromJson<String>(json['timezone']),
      weekStartsOn: serializer.fromJson<String>(json['weekStartsOn']),
      requiredWeekdaysJson: serializer.fromJson<String>(
        json['requiredWeekdaysJson'],
      ),
      maxOccurrencesPerDate: serializer.fromJson<int>(
        json['maxOccurrencesPerDate'],
      ),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'timezone': serializer.toJson<String>(timezone),
      'weekStartsOn': serializer.toJson<String>(weekStartsOn),
      'requiredWeekdaysJson': serializer.toJson<String>(requiredWeekdaysJson),
      'maxOccurrencesPerDate': serializer.toJson<int>(maxOccurrencesPerDate),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  LocalOperationConfig copyWith({
    String? id,
    String? templateId,
    String? timezone,
    String? weekStartsOn,
    String? requiredWeekdaysJson,
    int? maxOccurrencesPerDate,
    String? rawJson,
  }) => LocalOperationConfig(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    timezone: timezone ?? this.timezone,
    weekStartsOn: weekStartsOn ?? this.weekStartsOn,
    requiredWeekdaysJson: requiredWeekdaysJson ?? this.requiredWeekdaysJson,
    maxOccurrencesPerDate: maxOccurrencesPerDate ?? this.maxOccurrencesPerDate,
    rawJson: rawJson ?? this.rawJson,
  );
  LocalOperationConfig copyWithCompanion(LocalOperationConfigsCompanion data) {
    return LocalOperationConfig(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      weekStartsOn: data.weekStartsOn.present
          ? data.weekStartsOn.value
          : this.weekStartsOn,
      requiredWeekdaysJson: data.requiredWeekdaysJson.present
          ? data.requiredWeekdaysJson.value
          : this.requiredWeekdaysJson,
      maxOccurrencesPerDate: data.maxOccurrencesPerDate.present
          ? data.maxOccurrencesPerDate.value
          : this.maxOccurrencesPerDate,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOperationConfig(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('timezone: $timezone, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('requiredWeekdaysJson: $requiredWeekdaysJson, ')
          ..write('maxOccurrencesPerDate: $maxOccurrencesPerDate, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    timezone,
    weekStartsOn,
    requiredWeekdaysJson,
    maxOccurrencesPerDate,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOperationConfig &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.timezone == this.timezone &&
          other.weekStartsOn == this.weekStartsOn &&
          other.requiredWeekdaysJson == this.requiredWeekdaysJson &&
          other.maxOccurrencesPerDate == this.maxOccurrencesPerDate &&
          other.rawJson == this.rawJson);
}

class LocalOperationConfigsCompanion
    extends UpdateCompanion<LocalOperationConfig> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> timezone;
  final Value<String> weekStartsOn;
  final Value<String> requiredWeekdaysJson;
  final Value<int> maxOccurrencesPerDate;
  final Value<String> rawJson;
  final Value<int> rowid;
  const LocalOperationConfigsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.timezone = const Value.absent(),
    this.weekStartsOn = const Value.absent(),
    this.requiredWeekdaysJson = const Value.absent(),
    this.maxOccurrencesPerDate = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOperationConfigsCompanion.insert({
    required String id,
    required String templateId,
    required String timezone,
    required String weekStartsOn,
    required String requiredWeekdaysJson,
    required int maxOccurrencesPerDate,
    required String rawJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       timezone = Value(timezone),
       weekStartsOn = Value(weekStartsOn),
       requiredWeekdaysJson = Value(requiredWeekdaysJson),
       maxOccurrencesPerDate = Value(maxOccurrencesPerDate),
       rawJson = Value(rawJson);
  static Insertable<LocalOperationConfig> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? timezone,
    Expression<String>? weekStartsOn,
    Expression<String>? requiredWeekdaysJson,
    Expression<int>? maxOccurrencesPerDate,
    Expression<String>? rawJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (timezone != null) 'timezone': timezone,
      if (weekStartsOn != null) 'week_starts_on': weekStartsOn,
      if (requiredWeekdaysJson != null)
        'required_weekdays_json': requiredWeekdaysJson,
      if (maxOccurrencesPerDate != null)
        'max_occurrences_per_date': maxOccurrencesPerDate,
      if (rawJson != null) 'raw_json': rawJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOperationConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? timezone,
    Value<String>? weekStartsOn,
    Value<String>? requiredWeekdaysJson,
    Value<int>? maxOccurrencesPerDate,
    Value<String>? rawJson,
    Value<int>? rowid,
  }) {
    return LocalOperationConfigsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      timezone: timezone ?? this.timezone,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      requiredWeekdaysJson: requiredWeekdaysJson ?? this.requiredWeekdaysJson,
      maxOccurrencesPerDate:
          maxOccurrencesPerDate ?? this.maxOccurrencesPerDate,
      rawJson: rawJson ?? this.rawJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (weekStartsOn.present) {
      map['week_starts_on'] = Variable<String>(weekStartsOn.value);
    }
    if (requiredWeekdaysJson.present) {
      map['required_weekdays_json'] = Variable<String>(
        requiredWeekdaysJson.value,
      );
    }
    if (maxOccurrencesPerDate.present) {
      map['max_occurrences_per_date'] = Variable<int>(
        maxOccurrencesPerDate.value,
      );
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOperationConfigsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('timezone: $timezone, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('requiredWeekdaysJson: $requiredWeekdaysJson, ')
          ..write('maxOccurrencesPerDate: $maxOccurrencesPerDate, ')
          ..write('rawJson: $rawJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWeeklyChecklistsTable extends LocalWeeklyChecklists
    with TableInfo<$LocalWeeklyChecklistsTable, LocalWeeklyChecklist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWeeklyChecklistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateVersionIdMeta = const VerificationMeta(
    'templateVersionId',
  );
  @override
  late final GeneratedColumn<String> templateVersionId =
      GeneratedColumn<String>(
        'template_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _operationConfigIdMeta = const VerificationMeta(
    'operationConfigId',
  );
  @override
  late final GeneratedColumn<String> operationConfigId =
      GeneratedColumn<String>(
        'operation_config_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<String> weekStartDate = GeneratedColumn<String>(
    'week_start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LOCAL_ONLY'),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    assetId,
    templateId,
    templateVersionId,
    operationConfigId,
    weekStartDate,
    timezone,
    revision,
    syncState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_weekly_checklists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWeeklyChecklist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('template_version_id')) {
      context.handle(
        _templateVersionIdMeta,
        templateVersionId.isAcceptableOrUnknown(
          data['template_version_id']!,
          _templateVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateVersionIdMeta);
    }
    if (data.containsKey('operation_config_id')) {
      context.handle(
        _operationConfigIdMeta,
        operationConfigId.isAcceptableOrUnknown(
          data['operation_config_id']!,
          _operationConfigIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationConfigIdMeta);
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {assetId, templateId, weekStartDate},
  ];
  @override
  LocalWeeklyChecklist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWeeklyChecklist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      templateVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_version_id'],
      )!,
      operationConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_config_id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start_date'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalWeeklyChecklistsTable createAlias(String alias) {
    return $LocalWeeklyChecklistsTable(attachedDatabase, alias);
  }
}

class LocalWeeklyChecklist extends DataClass
    implements Insertable<LocalWeeklyChecklist> {
  final String id;
  final String? serverId;
  final String assetId;
  final String templateId;
  final String templateVersionId;
  final String operationConfigId;
  final String weekStartDate;
  final String timezone;
  final int? revision;
  final String syncState;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalWeeklyChecklist({
    required this.id,
    this.serverId,
    required this.assetId,
    required this.templateId,
    required this.templateVersionId,
    required this.operationConfigId,
    required this.weekStartDate,
    required this.timezone,
    this.revision,
    required this.syncState,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['asset_id'] = Variable<String>(assetId);
    map['template_id'] = Variable<String>(templateId);
    map['template_version_id'] = Variable<String>(templateVersionId);
    map['operation_config_id'] = Variable<String>(operationConfigId);
    map['week_start_date'] = Variable<String>(weekStartDate);
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalWeeklyChecklistsCompanion toCompanion(bool nullToAbsent) {
    return LocalWeeklyChecklistsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      assetId: Value(assetId),
      templateId: Value(templateId),
      templateVersionId: Value(templateVersionId),
      operationConfigId: Value(operationConfigId),
      weekStartDate: Value(weekStartDate),
      timezone: Value(timezone),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      syncState: Value(syncState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalWeeklyChecklist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWeeklyChecklist(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      templateId: serializer.fromJson<String>(json['templateId']),
      templateVersionId: serializer.fromJson<String>(json['templateVersionId']),
      operationConfigId: serializer.fromJson<String>(json['operationConfigId']),
      weekStartDate: serializer.fromJson<String>(json['weekStartDate']),
      timezone: serializer.fromJson<String>(json['timezone']),
      revision: serializer.fromJson<int?>(json['revision']),
      syncState: serializer.fromJson<String>(json['syncState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'assetId': serializer.toJson<String>(assetId),
      'templateId': serializer.toJson<String>(templateId),
      'templateVersionId': serializer.toJson<String>(templateVersionId),
      'operationConfigId': serializer.toJson<String>(operationConfigId),
      'weekStartDate': serializer.toJson<String>(weekStartDate),
      'timezone': serializer.toJson<String>(timezone),
      'revision': serializer.toJson<int?>(revision),
      'syncState': serializer.toJson<String>(syncState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalWeeklyChecklist copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? assetId,
    String? templateId,
    String? templateVersionId,
    String? operationConfigId,
    String? weekStartDate,
    String? timezone,
    Value<int?> revision = const Value.absent(),
    String? syncState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalWeeklyChecklist(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    assetId: assetId ?? this.assetId,
    templateId: templateId ?? this.templateId,
    templateVersionId: templateVersionId ?? this.templateVersionId,
    operationConfigId: operationConfigId ?? this.operationConfigId,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    timezone: timezone ?? this.timezone,
    revision: revision.present ? revision.value : this.revision,
    syncState: syncState ?? this.syncState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalWeeklyChecklist copyWithCompanion(LocalWeeklyChecklistsCompanion data) {
    return LocalWeeklyChecklist(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      templateVersionId: data.templateVersionId.present
          ? data.templateVersionId.value
          : this.templateVersionId,
      operationConfigId: data.operationConfigId.present
          ? data.operationConfigId.value
          : this.operationConfigId,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWeeklyChecklist(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('assetId: $assetId, ')
          ..write('templateId: $templateId, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('operationConfigId: $operationConfigId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('timezone: $timezone, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    assetId,
    templateId,
    templateVersionId,
    operationConfigId,
    weekStartDate,
    timezone,
    revision,
    syncState,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWeeklyChecklist &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.assetId == this.assetId &&
          other.templateId == this.templateId &&
          other.templateVersionId == this.templateVersionId &&
          other.operationConfigId == this.operationConfigId &&
          other.weekStartDate == this.weekStartDate &&
          other.timezone == this.timezone &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalWeeklyChecklistsCompanion
    extends UpdateCompanion<LocalWeeklyChecklist> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> assetId;
  final Value<String> templateId;
  final Value<String> templateVersionId;
  final Value<String> operationConfigId;
  final Value<String> weekStartDate;
  final Value<String> timezone;
  final Value<int?> revision;
  final Value<String> syncState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalWeeklyChecklistsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.templateVersionId = const Value.absent(),
    this.operationConfigId = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWeeklyChecklistsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String assetId,
    required String templateId,
    required String templateVersionId,
    required String operationConfigId,
    required String weekStartDate,
    required String timezone,
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assetId = Value(assetId),
       templateId = Value(templateId),
       templateVersionId = Value(templateVersionId),
       operationConfigId = Value(operationConfigId),
       weekStartDate = Value(weekStartDate),
       timezone = Value(timezone),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalWeeklyChecklist> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? assetId,
    Expression<String>? templateId,
    Expression<String>? templateVersionId,
    Expression<String>? operationConfigId,
    Expression<String>? weekStartDate,
    Expression<String>? timezone,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (assetId != null) 'asset_id': assetId,
      if (templateId != null) 'template_id': templateId,
      if (templateVersionId != null) 'template_version_id': templateVersionId,
      if (operationConfigId != null) 'operation_config_id': operationConfigId,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (timezone != null) 'timezone': timezone,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWeeklyChecklistsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? assetId,
    Value<String>? templateId,
    Value<String>? templateVersionId,
    Value<String>? operationConfigId,
    Value<String>? weekStartDate,
    Value<String>? timezone,
    Value<int?>? revision,
    Value<String>? syncState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalWeeklyChecklistsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      assetId: assetId ?? this.assetId,
      templateId: templateId ?? this.templateId,
      templateVersionId: templateVersionId ?? this.templateVersionId,
      operationConfigId: operationConfigId ?? this.operationConfigId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      timezone: timezone ?? this.timezone,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (templateVersionId.present) {
      map['template_version_id'] = Variable<String>(templateVersionId.value);
    }
    if (operationConfigId.present) {
      map['operation_config_id'] = Variable<String>(operationConfigId.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<String>(weekStartDate.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWeeklyChecklistsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('assetId: $assetId, ')
          ..write('templateId: $templateId, ')
          ..write('templateVersionId: $templateVersionId, ')
          ..write('operationConfigId: $operationConfigId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('timezone: $timezone, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInspectionsTable extends LocalInspections
    with TableInfo<$LocalInspectionsTable, LocalInspection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInspectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyChecklistIdMeta = const VerificationMeta(
    'weeklyChecklistId',
  );
  @override
  late final GeneratedColumn<String> weeklyChecklistId =
      GeneratedColumn<String>(
        'weekly_checklist_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceNoMeta = const VerificationMeta(
    'occurrenceNo',
  );
  @override
  late final GeneratedColumn<int> occurrenceNo = GeneratedColumn<int>(
    'occurrence_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lifecycleStatusMeta = const VerificationMeta(
    'lifecycleStatus',
  );
  @override
  late final GeneratedColumn<String> lifecycleStatus = GeneratedColumn<String>(
    'lifecycle_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DRAFT'),
  );
  static const VerificationMeta _identificationJsonMeta =
      const VerificationMeta('identificationJson');
  @override
  late final GeneratedColumn<String> identificationJson =
      GeneratedColumn<String>(
        'identification_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LOCAL_ONLY'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictIdMeta = const VerificationMeta(
    'conflictId',
  );
  @override
  late final GeneratedColumn<String> conflictId = GeneratedColumn<String>(
    'conflict_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    weeklyChecklistId,
    localDate,
    occurrenceNo,
    lifecycleStatus,
    identificationJson,
    observations,
    revision,
    syncState,
    lastError,
    conflictId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inspections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInspection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('weekly_checklist_id')) {
      context.handle(
        _weeklyChecklistIdMeta,
        weeklyChecklistId.isAcceptableOrUnknown(
          data['weekly_checklist_id']!,
          _weeklyChecklistIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyChecklistIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('occurrence_no')) {
      context.handle(
        _occurrenceNoMeta,
        occurrenceNo.isAcceptableOrUnknown(
          data['occurrence_no']!,
          _occurrenceNoMeta,
        ),
      );
    }
    if (data.containsKey('lifecycle_status')) {
      context.handle(
        _lifecycleStatusMeta,
        lifecycleStatus.isAcceptableOrUnknown(
          data['lifecycle_status']!,
          _lifecycleStatusMeta,
        ),
      );
    }
    if (data.containsKey('identification_json')) {
      context.handle(
        _identificationJsonMeta,
        identificationJson.isAcceptableOrUnknown(
          data['identification_json']!,
          _identificationJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identificationJsonMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('conflict_id')) {
      context.handle(
        _conflictIdMeta,
        conflictId.isAcceptableOrUnknown(data['conflict_id']!, _conflictIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {weeklyChecklistId, localDate, occurrenceNo},
  ];
  @override
  LocalInspection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInspection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      weeklyChecklistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekly_checklist_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      occurrenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_no'],
      )!,
      lifecycleStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle_status'],
      )!,
      identificationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identification_json'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      conflictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalInspectionsTable createAlias(String alias) {
    return $LocalInspectionsTable(attachedDatabase, alias);
  }
}

class LocalInspection extends DataClass implements Insertable<LocalInspection> {
  final String id;
  final String? serverId;
  final String weeklyChecklistId;
  final String localDate;
  final int occurrenceNo;
  final String lifecycleStatus;
  final String identificationJson;
  final String? observations;
  final int? revision;
  final String syncState;
  final String? lastError;
  final String? conflictId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalInspection({
    required this.id,
    this.serverId,
    required this.weeklyChecklistId,
    required this.localDate,
    required this.occurrenceNo,
    required this.lifecycleStatus,
    required this.identificationJson,
    this.observations,
    this.revision,
    required this.syncState,
    this.lastError,
    this.conflictId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['weekly_checklist_id'] = Variable<String>(weeklyChecklistId);
    map['local_date'] = Variable<String>(localDate);
    map['occurrence_no'] = Variable<int>(occurrenceNo);
    map['lifecycle_status'] = Variable<String>(lifecycleStatus);
    map['identification_json'] = Variable<String>(identificationJson);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || conflictId != null) {
      map['conflict_id'] = Variable<String>(conflictId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalInspectionsCompanion toCompanion(bool nullToAbsent) {
    return LocalInspectionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      weeklyChecklistId: Value(weeklyChecklistId),
      localDate: Value(localDate),
      occurrenceNo: Value(occurrenceNo),
      lifecycleStatus: Value(lifecycleStatus),
      identificationJson: Value(identificationJson),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      syncState: Value(syncState),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      conflictId: conflictId == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalInspection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInspection(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      weeklyChecklistId: serializer.fromJson<String>(json['weeklyChecklistId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      occurrenceNo: serializer.fromJson<int>(json['occurrenceNo']),
      lifecycleStatus: serializer.fromJson<String>(json['lifecycleStatus']),
      identificationJson: serializer.fromJson<String>(
        json['identificationJson'],
      ),
      observations: serializer.fromJson<String?>(json['observations']),
      revision: serializer.fromJson<int?>(json['revision']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      conflictId: serializer.fromJson<String?>(json['conflictId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'weeklyChecklistId': serializer.toJson<String>(weeklyChecklistId),
      'localDate': serializer.toJson<String>(localDate),
      'occurrenceNo': serializer.toJson<int>(occurrenceNo),
      'lifecycleStatus': serializer.toJson<String>(lifecycleStatus),
      'identificationJson': serializer.toJson<String>(identificationJson),
      'observations': serializer.toJson<String?>(observations),
      'revision': serializer.toJson<int?>(revision),
      'syncState': serializer.toJson<String>(syncState),
      'lastError': serializer.toJson<String?>(lastError),
      'conflictId': serializer.toJson<String?>(conflictId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalInspection copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? weeklyChecklistId,
    String? localDate,
    int? occurrenceNo,
    String? lifecycleStatus,
    String? identificationJson,
    Value<String?> observations = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    String? syncState,
    Value<String?> lastError = const Value.absent(),
    Value<String?> conflictId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalInspection(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    weeklyChecklistId: weeklyChecklistId ?? this.weeklyChecklistId,
    localDate: localDate ?? this.localDate,
    occurrenceNo: occurrenceNo ?? this.occurrenceNo,
    lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
    identificationJson: identificationJson ?? this.identificationJson,
    observations: observations.present ? observations.value : this.observations,
    revision: revision.present ? revision.value : this.revision,
    syncState: syncState ?? this.syncState,
    lastError: lastError.present ? lastError.value : this.lastError,
    conflictId: conflictId.present ? conflictId.value : this.conflictId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalInspection copyWithCompanion(LocalInspectionsCompanion data) {
    return LocalInspection(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      weeklyChecklistId: data.weeklyChecklistId.present
          ? data.weeklyChecklistId.value
          : this.weeklyChecklistId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      occurrenceNo: data.occurrenceNo.present
          ? data.occurrenceNo.value
          : this.occurrenceNo,
      lifecycleStatus: data.lifecycleStatus.present
          ? data.lifecycleStatus.value
          : this.lifecycleStatus,
      identificationJson: data.identificationJson.present
          ? data.identificationJson.value
          : this.identificationJson,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      conflictId: data.conflictId.present
          ? data.conflictId.value
          : this.conflictId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInspection(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('weeklyChecklistId: $weeklyChecklistId, ')
          ..write('localDate: $localDate, ')
          ..write('occurrenceNo: $occurrenceNo, ')
          ..write('lifecycleStatus: $lifecycleStatus, ')
          ..write('identificationJson: $identificationJson, ')
          ..write('observations: $observations, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('lastError: $lastError, ')
          ..write('conflictId: $conflictId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    weeklyChecklistId,
    localDate,
    occurrenceNo,
    lifecycleStatus,
    identificationJson,
    observations,
    revision,
    syncState,
    lastError,
    conflictId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInspection &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.weeklyChecklistId == this.weeklyChecklistId &&
          other.localDate == this.localDate &&
          other.occurrenceNo == this.occurrenceNo &&
          other.lifecycleStatus == this.lifecycleStatus &&
          other.identificationJson == this.identificationJson &&
          other.observations == this.observations &&
          other.revision == this.revision &&
          other.syncState == this.syncState &&
          other.lastError == this.lastError &&
          other.conflictId == this.conflictId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalInspectionsCompanion extends UpdateCompanion<LocalInspection> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> weeklyChecklistId;
  final Value<String> localDate;
  final Value<int> occurrenceNo;
  final Value<String> lifecycleStatus;
  final Value<String> identificationJson;
  final Value<String?> observations;
  final Value<int?> revision;
  final Value<String> syncState;
  final Value<String?> lastError;
  final Value<String?> conflictId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalInspectionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.weeklyChecklistId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.occurrenceNo = const Value.absent(),
    this.lifecycleStatus = const Value.absent(),
    this.identificationJson = const Value.absent(),
    this.observations = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastError = const Value.absent(),
    this.conflictId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInspectionsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String weeklyChecklistId,
    required String localDate,
    this.occurrenceNo = const Value.absent(),
    this.lifecycleStatus = const Value.absent(),
    required String identificationJson,
    this.observations = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastError = const Value.absent(),
    this.conflictId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weeklyChecklistId = Value(weeklyChecklistId),
       localDate = Value(localDate),
       identificationJson = Value(identificationJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalInspection> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? weeklyChecklistId,
    Expression<String>? localDate,
    Expression<int>? occurrenceNo,
    Expression<String>? lifecycleStatus,
    Expression<String>? identificationJson,
    Expression<String>? observations,
    Expression<int>? revision,
    Expression<String>? syncState,
    Expression<String>? lastError,
    Expression<String>? conflictId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (weeklyChecklistId != null) 'weekly_checklist_id': weeklyChecklistId,
      if (localDate != null) 'local_date': localDate,
      if (occurrenceNo != null) 'occurrence_no': occurrenceNo,
      if (lifecycleStatus != null) 'lifecycle_status': lifecycleStatus,
      if (identificationJson != null) 'identification_json': identificationJson,
      if (observations != null) 'observations': observations,
      if (revision != null) 'revision': revision,
      if (syncState != null) 'sync_state': syncState,
      if (lastError != null) 'last_error': lastError,
      if (conflictId != null) 'conflict_id': conflictId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInspectionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? weeklyChecklistId,
    Value<String>? localDate,
    Value<int>? occurrenceNo,
    Value<String>? lifecycleStatus,
    Value<String>? identificationJson,
    Value<String?>? observations,
    Value<int?>? revision,
    Value<String>? syncState,
    Value<String?>? lastError,
    Value<String?>? conflictId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalInspectionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      weeklyChecklistId: weeklyChecklistId ?? this.weeklyChecklistId,
      localDate: localDate ?? this.localDate,
      occurrenceNo: occurrenceNo ?? this.occurrenceNo,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      identificationJson: identificationJson ?? this.identificationJson,
      observations: observations ?? this.observations,
      revision: revision ?? this.revision,
      syncState: syncState ?? this.syncState,
      lastError: lastError ?? this.lastError,
      conflictId: conflictId ?? this.conflictId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (weeklyChecklistId.present) {
      map['weekly_checklist_id'] = Variable<String>(weeklyChecklistId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (occurrenceNo.present) {
      map['occurrence_no'] = Variable<int>(occurrenceNo.value);
    }
    if (lifecycleStatus.present) {
      map['lifecycle_status'] = Variable<String>(lifecycleStatus.value);
    }
    if (identificationJson.present) {
      map['identification_json'] = Variable<String>(identificationJson.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (conflictId.present) {
      map['conflict_id'] = Variable<String>(conflictId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInspectionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('weeklyChecklistId: $weeklyChecklistId, ')
          ..write('localDate: $localDate, ')
          ..write('occurrenceNo: $occurrenceNo, ')
          ..write('lifecycleStatus: $lifecycleStatus, ')
          ..write('identificationJson: $identificationJson, ')
          ..write('observations: $observations, ')
          ..write('revision: $revision, ')
          ..write('syncState: $syncState, ')
          ..write('lastError: $lastError, ')
          ..write('conflictId: $conflictId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInspectionResponsesTable extends LocalInspectionResponses
    with TableInfo<$LocalInspectionResponsesTable, LocalInspectionResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInspectionResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _inspectionIdMeta = const VerificationMeta(
    'inspectionId',
  );
  @override
  late final GeneratedColumn<String> inspectionId = GeneratedColumn<String>(
    'inspection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    inspectionId,
    itemId,
    result,
    observation,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inspection_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInspectionResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('inspection_id')) {
      context.handle(
        _inspectionIdMeta,
        inspectionId.isAcceptableOrUnknown(
          data['inspection_id']!,
          _inspectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {inspectionId, itemId};
  @override
  LocalInspectionResponse map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInspectionResponse(
      inspectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inspection_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalInspectionResponsesTable createAlias(String alias) {
    return $LocalInspectionResponsesTable(attachedDatabase, alias);
  }
}

class LocalInspectionResponse extends DataClass
    implements Insertable<LocalInspectionResponse> {
  final String inspectionId;
  final String itemId;
  final String? result;
  final String? observation;
  final DateTime updatedAt;
  const LocalInspectionResponse({
    required this.inspectionId,
    required this.itemId,
    this.result,
    this.observation,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['inspection_id'] = Variable<String>(inspectionId);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalInspectionResponsesCompanion toCompanion(bool nullToAbsent) {
    return LocalInspectionResponsesCompanion(
      inspectionId: Value(inspectionId),
      itemId: Value(itemId),
      result: result == null && nullToAbsent
          ? const Value.absent()
          : Value(result),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalInspectionResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInspectionResponse(
      inspectionId: serializer.fromJson<String>(json['inspectionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      result: serializer.fromJson<String?>(json['result']),
      observation: serializer.fromJson<String?>(json['observation']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'inspectionId': serializer.toJson<String>(inspectionId),
      'itemId': serializer.toJson<String>(itemId),
      'result': serializer.toJson<String?>(result),
      'observation': serializer.toJson<String?>(observation),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalInspectionResponse copyWith({
    String? inspectionId,
    String? itemId,
    Value<String?> result = const Value.absent(),
    Value<String?> observation = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalInspectionResponse(
    inspectionId: inspectionId ?? this.inspectionId,
    itemId: itemId ?? this.itemId,
    result: result.present ? result.value : this.result,
    observation: observation.present ? observation.value : this.observation,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalInspectionResponse copyWithCompanion(
    LocalInspectionResponsesCompanion data,
  ) {
    return LocalInspectionResponse(
      inspectionId: data.inspectionId.present
          ? data.inspectionId.value
          : this.inspectionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      result: data.result.present ? data.result.value : this.result,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInspectionResponse(')
          ..write('inspectionId: $inspectionId, ')
          ..write('itemId: $itemId, ')
          ..write('result: $result, ')
          ..write('observation: $observation, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(inspectionId, itemId, result, observation, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInspectionResponse &&
          other.inspectionId == this.inspectionId &&
          other.itemId == this.itemId &&
          other.result == this.result &&
          other.observation == this.observation &&
          other.updatedAt == this.updatedAt);
}

class LocalInspectionResponsesCompanion
    extends UpdateCompanion<LocalInspectionResponse> {
  final Value<String> inspectionId;
  final Value<String> itemId;
  final Value<String?> result;
  final Value<String?> observation;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalInspectionResponsesCompanion({
    this.inspectionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.result = const Value.absent(),
    this.observation = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInspectionResponsesCompanion.insert({
    required String inspectionId,
    required String itemId,
    this.result = const Value.absent(),
    this.observation = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : inspectionId = Value(inspectionId),
       itemId = Value(itemId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalInspectionResponse> custom({
    Expression<String>? inspectionId,
    Expression<String>? itemId,
    Expression<String>? result,
    Expression<String>? observation,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (inspectionId != null) 'inspection_id': inspectionId,
      if (itemId != null) 'item_id': itemId,
      if (result != null) 'result': result,
      if (observation != null) 'observation': observation,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInspectionResponsesCompanion copyWith({
    Value<String>? inspectionId,
    Value<String>? itemId,
    Value<String?>? result,
    Value<String?>? observation,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalInspectionResponsesCompanion(
      inspectionId: inspectionId ?? this.inspectionId,
      itemId: itemId ?? this.itemId,
      result: result ?? this.result,
      observation: observation ?? this.observation,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (inspectionId.present) {
      map['inspection_id'] = Variable<String>(inspectionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInspectionResponsesCompanion(')
          ..write('inspectionId: $inspectionId, ')
          ..write('itemId: $itemId, ')
          ..write('result: $result, ')
          ..write('observation: $observation, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxOperationsTable extends SyncOutboxOperations
    with TableInfo<$SyncOutboxOperationsTable, SyncOutboxOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationMeta = const VerificationMeta(
    'mutation',
  );
  @override
  late final GeneratedColumn<String> mutation = GeneratedColumn<String>(
    'mutation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientOccurredAtMeta = const VerificationMeta(
    'clientOccurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientOccurredAt =
      GeneratedColumn<DateTime>(
        'client_occurred_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('QUEUED'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    entityType,
    mutation,
    entityId,
    baseRevision,
    clientOccurredAt,
    payloadJson,
    attemptCount,
    state,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('mutation')) {
      context.handle(
        _mutationMeta,
        mutation.isAcceptableOrUnknown(data['mutation']!, _mutationMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('client_occurred_at')) {
      context.handle(
        _clientOccurredAtMeta,
        clientOccurredAt.isAcceptableOrUnknown(
          data['client_occurred_at']!,
          _clientOccurredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientOccurredAtMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOutboxOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxOperation(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      mutation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      clientOccurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_occurred_at'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxOperationsTable createAlias(String alias) {
    return $SyncOutboxOperationsTable(attachedDatabase, alias);
  }
}

class SyncOutboxOperation extends DataClass
    implements Insertable<SyncOutboxOperation> {
  final String operationId;
  final String entityType;
  final String mutation;
  final String entityId;
  final int? baseRevision;
  final DateTime clientOccurredAt;
  final String payloadJson;
  final int attemptCount;
  final String state;
  final String? lastError;
  const SyncOutboxOperation({
    required this.operationId,
    required this.entityType,
    required this.mutation,
    required this.entityId,
    this.baseRevision,
    required this.clientOccurredAt,
    required this.payloadJson,
    required this.attemptCount,
    required this.state,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['entity_type'] = Variable<String>(entityType);
    map['mutation'] = Variable<String>(mutation);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    map['client_occurred_at'] = Variable<DateTime>(clientOccurredAt);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxOperationsCompanion(
      operationId: Value(operationId),
      entityType: Value(entityType),
      mutation: Value(mutation),
      entityId: Value(entityId),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      clientOccurredAt: Value(clientOccurredAt),
      payloadJson: Value(payloadJson),
      attemptCount: Value(attemptCount),
      state: Value(state),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxOperation(
      operationId: serializer.fromJson<String>(json['operationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      mutation: serializer.fromJson<String>(json['mutation']),
      entityId: serializer.fromJson<String>(json['entityId']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      clientOccurredAt: serializer.fromJson<DateTime>(json['clientOccurredAt']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      state: serializer.fromJson<String>(json['state']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'entityType': serializer.toJson<String>(entityType),
      'mutation': serializer.toJson<String>(mutation),
      'entityId': serializer.toJson<String>(entityId),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'clientOccurredAt': serializer.toJson<DateTime>(clientOccurredAt),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'state': serializer.toJson<String>(state),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxOperation copyWith({
    String? operationId,
    String? entityType,
    String? mutation,
    String? entityId,
    Value<int?> baseRevision = const Value.absent(),
    DateTime? clientOccurredAt,
    String? payloadJson,
    int? attemptCount,
    String? state,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxOperation(
    operationId: operationId ?? this.operationId,
    entityType: entityType ?? this.entityType,
    mutation: mutation ?? this.mutation,
    entityId: entityId ?? this.entityId,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    clientOccurredAt: clientOccurredAt ?? this.clientOccurredAt,
    payloadJson: payloadJson ?? this.payloadJson,
    attemptCount: attemptCount ?? this.attemptCount,
    state: state ?? this.state,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxOperation copyWithCompanion(SyncOutboxOperationsCompanion data) {
    return SyncOutboxOperation(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      mutation: data.mutation.present ? data.mutation.value : this.mutation,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      clientOccurredAt: data.clientOccurredAt.present
          ? data.clientOccurredAt.value
          : this.clientOccurredAt,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      state: data.state.present ? data.state.value : this.state,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxOperation(')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('mutation: $mutation, ')
          ..write('entityId: $entityId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('clientOccurredAt: $clientOccurredAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('state: $state, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    entityType,
    mutation,
    entityId,
    baseRevision,
    clientOccurredAt,
    payloadJson,
    attemptCount,
    state,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxOperation &&
          other.operationId == this.operationId &&
          other.entityType == this.entityType &&
          other.mutation == this.mutation &&
          other.entityId == this.entityId &&
          other.baseRevision == this.baseRevision &&
          other.clientOccurredAt == this.clientOccurredAt &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.state == this.state &&
          other.lastError == this.lastError);
}

class SyncOutboxOperationsCompanion
    extends UpdateCompanion<SyncOutboxOperation> {
  final Value<String> operationId;
  final Value<String> entityType;
  final Value<String> mutation;
  final Value<String> entityId;
  final Value<int?> baseRevision;
  final Value<DateTime> clientOccurredAt;
  final Value<String> payloadJson;
  final Value<int> attemptCount;
  final Value<String> state;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxOperationsCompanion({
    this.operationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.mutation = const Value.absent(),
    this.entityId = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.clientOccurredAt = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.state = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxOperationsCompanion.insert({
    required String operationId,
    required String entityType,
    required String mutation,
    required String entityId,
    this.baseRevision = const Value.absent(),
    required DateTime clientOccurredAt,
    required String payloadJson,
    this.attemptCount = const Value.absent(),
    this.state = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       entityType = Value(entityType),
       mutation = Value(mutation),
       entityId = Value(entityId),
       clientOccurredAt = Value(clientOccurredAt),
       payloadJson = Value(payloadJson);
  static Insertable<SyncOutboxOperation> custom({
    Expression<String>? operationId,
    Expression<String>? entityType,
    Expression<String>? mutation,
    Expression<String>? entityId,
    Expression<int>? baseRevision,
    Expression<DateTime>? clientOccurredAt,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<String>? state,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (entityType != null) 'entity_type': entityType,
      if (mutation != null) 'mutation': mutation,
      if (entityId != null) 'entity_id': entityId,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (clientOccurredAt != null) 'client_occurred_at': clientOccurredAt,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (state != null) 'state': state,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? entityType,
    Value<String>? mutation,
    Value<String>? entityId,
    Value<int?>? baseRevision,
    Value<DateTime>? clientOccurredAt,
    Value<String>? payloadJson,
    Value<int>? attemptCount,
    Value<String>? state,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxOperationsCompanion(
      operationId: operationId ?? this.operationId,
      entityType: entityType ?? this.entityType,
      mutation: mutation ?? this.mutation,
      entityId: entityId ?? this.entityId,
      baseRevision: baseRevision ?? this.baseRevision,
      clientOccurredAt: clientOccurredAt ?? this.clientOccurredAt,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      state: state ?? this.state,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (mutation.present) {
      map['mutation'] = Variable<String>(mutation.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (clientOccurredAt.present) {
      map['client_occurred_at'] = Variable<DateTime>(clientOccurredAt.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('mutation: $mutation, ')
          ..write('entityId: $entityId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('clientOccurredAt: $clientOccurredAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('state: $state, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncMetadataTable extends LocalSyncMetadata
    with TableInfo<$LocalSyncMetadataTable, LocalSyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSyncMetadataTable createAlias(String alias) {
    return $LocalSyncMetadataTable(attachedDatabase, alias);
  }
}

class LocalSyncMetadataData extends DataClass
    implements Insertable<LocalSyncMetadataData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const LocalSyncMetadataData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncMetadataCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSyncMetadataData copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => LocalSyncMetadataData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSyncMetadataData copyWithCompanion(LocalSyncMetadataCompanion data) {
    return LocalSyncMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncMetadataData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalSyncMetadataCompanion
    extends UpdateCompanion<LocalSyncMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncMetadataCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSyncMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSyncMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalConflictCasesTable extends LocalConflictCases
    with TableInfo<$LocalConflictCasesTable, LocalConflictCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConflictCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    status,
    revision,
    rawJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conflict_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConflictCase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConflictCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConflictCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalConflictCasesTable createAlias(String alias) {
    return $LocalConflictCasesTable(attachedDatabase, alias);
  }
}

class LocalConflictCase extends DataClass
    implements Insertable<LocalConflictCase> {
  final String id;
  final String type;
  final String status;
  final int? revision;
  final String rawJson;
  final DateTime updatedAt;
  const LocalConflictCase({
    required this.id,
    required this.type,
    required this.status,
    this.revision,
    required this.rawJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalConflictCasesCompanion toCompanion(bool nullToAbsent) {
    return LocalConflictCasesCompanion(
      id: Value(id),
      type: Value(type),
      status: Value(status),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalConflictCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConflictCase(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      revision: serializer.fromJson<int?>(json['revision']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'revision': serializer.toJson<int?>(revision),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalConflictCase copyWith({
    String? id,
    String? type,
    String? status,
    Value<int?> revision = const Value.absent(),
    String? rawJson,
    DateTime? updatedAt,
  }) => LocalConflictCase(
    id: id ?? this.id,
    type: type ?? this.type,
    status: status ?? this.status,
    revision: revision.present ? revision.value : this.revision,
    rawJson: rawJson ?? this.rawJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalConflictCase copyWithCompanion(LocalConflictCasesCompanion data) {
    return LocalConflictCase(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      revision: data.revision.present ? data.revision.value : this.revision,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflictCase(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, status, revision, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConflictCase &&
          other.id == this.id &&
          other.type == this.type &&
          other.status == this.status &&
          other.revision == this.revision &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class LocalConflictCasesCompanion extends UpdateCompanion<LocalConflictCase> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> status;
  final Value<int?> revision;
  final Value<String> rawJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalConflictCasesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.revision = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConflictCasesCompanion.insert({
    required String id,
    required String type,
    required String status,
    this.revision = const Value.absent(),
    required String rawJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       status = Value(status),
       rawJson = Value(rawJson),
       updatedAt = Value(updatedAt);
  static Insertable<LocalConflictCase> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? revision,
    Expression<String>? rawJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (revision != null) 'revision': revision,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConflictCasesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? status,
    Value<int?>? revision,
    Value<String>? rawJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalConflictCasesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflictCasesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAttachmentsTable extends LocalAttachments
    with TableInfo<$LocalAttachmentsTable, LocalAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inspectionIdMeta = const VerificationMeta(
    'inspectionId',
  );
  @override
  late final GeneratedColumn<String> inspectionId = GeneratedColumn<String>(
    'inspection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredForCompletionMeta =
      const VerificationMeta('requiredForCompletion');
  @override
  late final GeneratedColumn<bool> requiredForCompletion =
      GeneratedColumn<bool>(
        'required_for_completion',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("required_for_completion" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LOCAL_ONLY'),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inspectionId,
    localPath,
    mediaType,
    purpose,
    requiredForCompletion,
    syncState,
    remoteId,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('inspection_id')) {
      context.handle(
        _inspectionIdMeta,
        inspectionId.isAcceptableOrUnknown(
          data['inspection_id']!,
          _inspectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectionIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('required_for_completion')) {
      context.handle(
        _requiredForCompletionMeta,
        requiredForCompletion.isAcceptableOrUnknown(
          data['required_for_completion']!,
          _requiredForCompletionMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      inspectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inspection_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      requiredForCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required_for_completion'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $LocalAttachmentsTable createAlias(String alias) {
    return $LocalAttachmentsTable(attachedDatabase, alias);
  }
}

class LocalAttachment extends DataClass implements Insertable<LocalAttachment> {
  final String id;
  final String inspectionId;
  final String localPath;
  final String mediaType;
  final String purpose;
  final bool requiredForCompletion;
  final String syncState;
  final String? remoteId;
  final String? lastError;
  const LocalAttachment({
    required this.id,
    required this.inspectionId,
    required this.localPath,
    required this.mediaType,
    required this.purpose,
    required this.requiredForCompletion,
    required this.syncState,
    this.remoteId,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['inspection_id'] = Variable<String>(inspectionId);
    map['local_path'] = Variable<String>(localPath);
    map['media_type'] = Variable<String>(mediaType);
    map['purpose'] = Variable<String>(purpose);
    map['required_for_completion'] = Variable<bool>(requiredForCompletion);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  LocalAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalAttachmentsCompanion(
      id: Value(id),
      inspectionId: Value(inspectionId),
      localPath: Value(localPath),
      mediaType: Value(mediaType),
      purpose: Value(purpose),
      requiredForCompletion: Value(requiredForCompletion),
      syncState: Value(syncState),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory LocalAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttachment(
      id: serializer.fromJson<String>(json['id']),
      inspectionId: serializer.fromJson<String>(json['inspectionId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      purpose: serializer.fromJson<String>(json['purpose']),
      requiredForCompletion: serializer.fromJson<bool>(
        json['requiredForCompletion'],
      ),
      syncState: serializer.fromJson<String>(json['syncState']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'inspectionId': serializer.toJson<String>(inspectionId),
      'localPath': serializer.toJson<String>(localPath),
      'mediaType': serializer.toJson<String>(mediaType),
      'purpose': serializer.toJson<String>(purpose),
      'requiredForCompletion': serializer.toJson<bool>(requiredForCompletion),
      'syncState': serializer.toJson<String>(syncState),
      'remoteId': serializer.toJson<String?>(remoteId),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  LocalAttachment copyWith({
    String? id,
    String? inspectionId,
    String? localPath,
    String? mediaType,
    String? purpose,
    bool? requiredForCompletion,
    String? syncState,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => LocalAttachment(
    id: id ?? this.id,
    inspectionId: inspectionId ?? this.inspectionId,
    localPath: localPath ?? this.localPath,
    mediaType: mediaType ?? this.mediaType,
    purpose: purpose ?? this.purpose,
    requiredForCompletion: requiredForCompletion ?? this.requiredForCompletion,
    syncState: syncState ?? this.syncState,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  LocalAttachment copyWithCompanion(LocalAttachmentsCompanion data) {
    return LocalAttachment(
      id: data.id.present ? data.id.value : this.id,
      inspectionId: data.inspectionId.present
          ? data.inspectionId.value
          : this.inspectionId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      requiredForCompletion: data.requiredForCompletion.present
          ? data.requiredForCompletion.value
          : this.requiredForCompletion,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttachment(')
          ..write('id: $id, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('purpose: $purpose, ')
          ..write('requiredForCompletion: $requiredForCompletion, ')
          ..write('syncState: $syncState, ')
          ..write('remoteId: $remoteId, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inspectionId,
    localPath,
    mediaType,
    purpose,
    requiredForCompletion,
    syncState,
    remoteId,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttachment &&
          other.id == this.id &&
          other.inspectionId == this.inspectionId &&
          other.localPath == this.localPath &&
          other.mediaType == this.mediaType &&
          other.purpose == this.purpose &&
          other.requiredForCompletion == this.requiredForCompletion &&
          other.syncState == this.syncState &&
          other.remoteId == this.remoteId &&
          other.lastError == this.lastError);
}

class LocalAttachmentsCompanion extends UpdateCompanion<LocalAttachment> {
  final Value<String> id;
  final Value<String> inspectionId;
  final Value<String> localPath;
  final Value<String> mediaType;
  final Value<String> purpose;
  final Value<bool> requiredForCompletion;
  final Value<String> syncState;
  final Value<String?> remoteId;
  final Value<String?> lastError;
  final Value<int> rowid;
  const LocalAttachmentsCompanion({
    this.id = const Value.absent(),
    this.inspectionId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.purpose = const Value.absent(),
    this.requiredForCompletion = const Value.absent(),
    this.syncState = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttachmentsCompanion.insert({
    required String id,
    required String inspectionId,
    required String localPath,
    required String mediaType,
    required String purpose,
    this.requiredForCompletion = const Value.absent(),
    this.syncState = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       inspectionId = Value(inspectionId),
       localPath = Value(localPath),
       mediaType = Value(mediaType),
       purpose = Value(purpose);
  static Insertable<LocalAttachment> custom({
    Expression<String>? id,
    Expression<String>? inspectionId,
    Expression<String>? localPath,
    Expression<String>? mediaType,
    Expression<String>? purpose,
    Expression<bool>? requiredForCompletion,
    Expression<String>? syncState,
    Expression<String>? remoteId,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inspectionId != null) 'inspection_id': inspectionId,
      if (localPath != null) 'local_path': localPath,
      if (mediaType != null) 'media_type': mediaType,
      if (purpose != null) 'purpose': purpose,
      if (requiredForCompletion != null)
        'required_for_completion': requiredForCompletion,
      if (syncState != null) 'sync_state': syncState,
      if (remoteId != null) 'remote_id': remoteId,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? inspectionId,
    Value<String>? localPath,
    Value<String>? mediaType,
    Value<String>? purpose,
    Value<bool>? requiredForCompletion,
    Value<String>? syncState,
    Value<String?>? remoteId,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return LocalAttachmentsCompanion(
      id: id ?? this.id,
      inspectionId: inspectionId ?? this.inspectionId,
      localPath: localPath ?? this.localPath,
      mediaType: mediaType ?? this.mediaType,
      purpose: purpose ?? this.purpose,
      requiredForCompletion:
          requiredForCompletion ?? this.requiredForCompletion,
      syncState: syncState ?? this.syncState,
      remoteId: remoteId ?? this.remoteId,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (inspectionId.present) {
      map['inspection_id'] = Variable<String>(inspectionId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (requiredForCompletion.present) {
      map['required_for_completion'] = Variable<bool>(
        requiredForCompletion.value,
      );
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('localPath: $localPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('purpose: $purpose, ')
          ..write('requiredForCompletion: $requiredForCompletion, ')
          ..write('syncState: $syncState, ')
          ..write('remoteId: $remoteId, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTemplateVersionsTable localTemplateVersions =
      $LocalTemplateVersionsTable(this);
  late final $LocalTemplateSectionsTable localTemplateSections =
      $LocalTemplateSectionsTable(this);
  late final $LocalTemplateItemsTable localTemplateItems =
      $LocalTemplateItemsTable(this);
  late final $LocalAssetsTable localAssets = $LocalAssetsTable(this);
  late final $LocalOperationConfigsTable localOperationConfigs =
      $LocalOperationConfigsTable(this);
  late final $LocalWeeklyChecklistsTable localWeeklyChecklists =
      $LocalWeeklyChecklistsTable(this);
  late final $LocalInspectionsTable localInspections = $LocalInspectionsTable(
    this,
  );
  late final $LocalInspectionResponsesTable localInspectionResponses =
      $LocalInspectionResponsesTable(this);
  late final $SyncOutboxOperationsTable syncOutboxOperations =
      $SyncOutboxOperationsTable(this);
  late final $LocalSyncMetadataTable localSyncMetadata =
      $LocalSyncMetadataTable(this);
  late final $LocalConflictCasesTable localConflictCases =
      $LocalConflictCasesTable(this);
  late final $LocalAttachmentsTable localAttachments = $LocalAttachmentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localTemplateVersions,
    localTemplateSections,
    localTemplateItems,
    localAssets,
    localOperationConfigs,
    localWeeklyChecklists,
    localInspections,
    localInspectionResponses,
    syncOutboxOperations,
    localSyncMetadata,
    localConflictCases,
    localAttachments,
  ];
}

typedef $$LocalTemplateVersionsTableCreateCompanionBuilder =
    LocalTemplateVersionsCompanion Function({
      required String id,
      required String templateId,
      required int versionNumber,
      required String status,
      required int revision,
      Value<String?> checksum,
      Value<DateTime?> publishedAt,
      required String rawJson,
      Value<int> rowid,
    });
typedef $$LocalTemplateVersionsTableUpdateCompanionBuilder =
    LocalTemplateVersionsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<int> versionNumber,
      Value<String> status,
      Value<int> revision,
      Value<String?> checksum,
      Value<DateTime?> publishedAt,
      Value<String> rawJson,
      Value<int> rowid,
    });

class $$LocalTemplateVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTemplateVersionsTable> {
  $$LocalTemplateVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTemplateVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTemplateVersionsTable> {
  $$LocalTemplateVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTemplateVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTemplateVersionsTable> {
  $$LocalTemplateVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$LocalTemplateVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTemplateVersionsTable,
          LocalTemplateVersion,
          $$LocalTemplateVersionsTableFilterComposer,
          $$LocalTemplateVersionsTableOrderingComposer,
          $$LocalTemplateVersionsTableAnnotationComposer,
          $$LocalTemplateVersionsTableCreateCompanionBuilder,
          $$LocalTemplateVersionsTableUpdateCompanionBuilder,
          (
            LocalTemplateVersion,
            BaseReferences<
              _$AppDatabase,
              $LocalTemplateVersionsTable,
              LocalTemplateVersion
            >,
          ),
          LocalTemplateVersion,
          PrefetchHooks Function()
        > {
  $$LocalTemplateVersionsTableTableManager(
    _$AppDatabase db,
    $LocalTemplateVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTemplateVersionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalTemplateVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTemplateVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateVersionsCompanion(
                id: id,
                templateId: templateId,
                versionNumber: versionNumber,
                status: status,
                revision: revision,
                checksum: checksum,
                publishedAt: publishedAt,
                rawJson: rawJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required int versionNumber,
                required String status,
                required int revision,
                Value<String?> checksum = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                required String rawJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateVersionsCompanion.insert(
                id: id,
                templateId: templateId,
                versionNumber: versionNumber,
                status: status,
                revision: revision,
                checksum: checksum,
                publishedAt: publishedAt,
                rawJson: rawJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalTemplateVersionsTable,
                    LocalTemplateVersion
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalTemplateVersionsTable,
                    LocalTemplateVersion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTemplateVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTemplateVersionsTable,
      LocalTemplateVersion,
      $$LocalTemplateVersionsTableFilterComposer,
      $$LocalTemplateVersionsTableOrderingComposer,
      $$LocalTemplateVersionsTableAnnotationComposer,
      $$LocalTemplateVersionsTableCreateCompanionBuilder,
      $$LocalTemplateVersionsTableUpdateCompanionBuilder,
      (
        LocalTemplateVersion,
        BaseReferences<
          _$AppDatabase,
          $LocalTemplateVersionsTable,
          LocalTemplateVersion
        >,
      ),
      LocalTemplateVersion,
      PrefetchHooks Function()
    >;
typedef $$LocalTemplateSectionsTableCreateCompanionBuilder =
    LocalTemplateSectionsCompanion Function({
      required String id,
      required String templateVersionId,
      required String title,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalTemplateSectionsTableUpdateCompanionBuilder =
    LocalTemplateSectionsCompanion Function({
      Value<String> id,
      Value<String> templateVersionId,
      Value<String> title,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalTemplateSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTemplateSectionsTable> {
  $$LocalTemplateSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTemplateSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTemplateSectionsTable> {
  $$LocalTemplateSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTemplateSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTemplateSectionsTable> {
  $$LocalTemplateSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalTemplateSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTemplateSectionsTable,
          LocalTemplateSection,
          $$LocalTemplateSectionsTableFilterComposer,
          $$LocalTemplateSectionsTableOrderingComposer,
          $$LocalTemplateSectionsTableAnnotationComposer,
          $$LocalTemplateSectionsTableCreateCompanionBuilder,
          $$LocalTemplateSectionsTableUpdateCompanionBuilder,
          (
            LocalTemplateSection,
            BaseReferences<
              _$AppDatabase,
              $LocalTemplateSectionsTable,
              LocalTemplateSection
            >,
          ),
          LocalTemplateSection,
          PrefetchHooks Function()
        > {
  $$LocalTemplateSectionsTableTableManager(
    _$AppDatabase db,
    $LocalTemplateSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTemplateSectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalTemplateSectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTemplateSectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateVersionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateSectionsCompanion(
                id: id,
                templateVersionId: templateVersionId,
                title: title,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateVersionId,
                required String title,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateSectionsCompanion.insert(
                id: id,
                templateVersionId: templateVersionId,
                title: title,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalTemplateSectionsTable,
                    LocalTemplateSection
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalTemplateSectionsTable,
                    LocalTemplateSection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTemplateSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTemplateSectionsTable,
      LocalTemplateSection,
      $$LocalTemplateSectionsTableFilterComposer,
      $$LocalTemplateSectionsTableOrderingComposer,
      $$LocalTemplateSectionsTableAnnotationComposer,
      $$LocalTemplateSectionsTableCreateCompanionBuilder,
      $$LocalTemplateSectionsTableUpdateCompanionBuilder,
      (
        LocalTemplateSection,
        BaseReferences<
          _$AppDatabase,
          $LocalTemplateSectionsTable,
          LocalTemplateSection
        >,
      ),
      LocalTemplateSection,
      PrefetchHooks Function()
    >;
typedef $$LocalTemplateItemsTableCreateCompanionBuilder =
    LocalTemplateItemsCompanion Function({
      required String id,
      required String templateVersionId,
      required String sectionId,
      Value<String?> sourcePrintedNumber,
      required String textValue,
      required int sortOrder,
      Value<bool> requiredOnComplete,
      Value<bool> requireObservationWhenNc,
      Value<bool> requirePhotoWhenNc,
      Value<int> rowid,
    });
typedef $$LocalTemplateItemsTableUpdateCompanionBuilder =
    LocalTemplateItemsCompanion Function({
      Value<String> id,
      Value<String> templateVersionId,
      Value<String> sectionId,
      Value<String?> sourcePrintedNumber,
      Value<String> textValue,
      Value<int> sortOrder,
      Value<bool> requiredOnComplete,
      Value<bool> requireObservationWhenNc,
      Value<bool> requirePhotoWhenNc,
      Value<int> rowid,
    });

class $$LocalTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTemplateItemsTable> {
  $$LocalTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePrintedNumber => $composableBuilder(
    column: $table.sourcePrintedNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiredOnComplete => $composableBuilder(
    column: $table.requiredOnComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireObservationWhenNc => $composableBuilder(
    column: $table.requireObservationWhenNc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requirePhotoWhenNc => $composableBuilder(
    column: $table.requirePhotoWhenNc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTemplateItemsTable> {
  $$LocalTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePrintedNumber => $composableBuilder(
    column: $table.sourcePrintedNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiredOnComplete => $composableBuilder(
    column: $table.requiredOnComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireObservationWhenNc => $composableBuilder(
    column: $table.requireObservationWhenNc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requirePhotoWhenNc => $composableBuilder(
    column: $table.requirePhotoWhenNc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTemplateItemsTable> {
  $$LocalTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get sourcePrintedNumber => $composableBuilder(
    column: $table.sourcePrintedNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get requiredOnComplete => $composableBuilder(
    column: $table.requiredOnComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireObservationWhenNc => $composableBuilder(
    column: $table.requireObservationWhenNc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requirePhotoWhenNc => $composableBuilder(
    column: $table.requirePhotoWhenNc,
    builder: (column) => column,
  );
}

class $$LocalTemplateItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTemplateItemsTable,
          LocalTemplateItem,
          $$LocalTemplateItemsTableFilterComposer,
          $$LocalTemplateItemsTableOrderingComposer,
          $$LocalTemplateItemsTableAnnotationComposer,
          $$LocalTemplateItemsTableCreateCompanionBuilder,
          $$LocalTemplateItemsTableUpdateCompanionBuilder,
          (
            LocalTemplateItem,
            BaseReferences<
              _$AppDatabase,
              $LocalTemplateItemsTable,
              LocalTemplateItem
            >,
          ),
          LocalTemplateItem,
          PrefetchHooks Function()
        > {
  $$LocalTemplateItemsTableTableManager(
    _$AppDatabase db,
    $LocalTemplateItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTemplateItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTemplateItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTemplateItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateVersionId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String?> sourcePrintedNumber = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> requiredOnComplete = const Value.absent(),
                Value<bool> requireObservationWhenNc = const Value.absent(),
                Value<bool> requirePhotoWhenNc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateItemsCompanion(
                id: id,
                templateVersionId: templateVersionId,
                sectionId: sectionId,
                sourcePrintedNumber: sourcePrintedNumber,
                textValue: textValue,
                sortOrder: sortOrder,
                requiredOnComplete: requiredOnComplete,
                requireObservationWhenNc: requireObservationWhenNc,
                requirePhotoWhenNc: requirePhotoWhenNc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateVersionId,
                required String sectionId,
                Value<String?> sourcePrintedNumber = const Value.absent(),
                required String textValue,
                required int sortOrder,
                Value<bool> requiredOnComplete = const Value.absent(),
                Value<bool> requireObservationWhenNc = const Value.absent(),
                Value<bool> requirePhotoWhenNc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTemplateItemsCompanion.insert(
                id: id,
                templateVersionId: templateVersionId,
                sectionId: sectionId,
                sourcePrintedNumber: sourcePrintedNumber,
                textValue: textValue,
                sortOrder: sortOrder,
                requiredOnComplete: requiredOnComplete,
                requireObservationWhenNc: requireObservationWhenNc,
                requirePhotoWhenNc: requirePhotoWhenNc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTemplateItemsTable, LocalTemplateItem>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalTemplateItemsTable,
                    LocalTemplateItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTemplateItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTemplateItemsTable,
      LocalTemplateItem,
      $$LocalTemplateItemsTableFilterComposer,
      $$LocalTemplateItemsTableOrderingComposer,
      $$LocalTemplateItemsTableAnnotationComposer,
      $$LocalTemplateItemsTableCreateCompanionBuilder,
      $$LocalTemplateItemsTableUpdateCompanionBuilder,
      (
        LocalTemplateItem,
        BaseReferences<
          _$AppDatabase,
          $LocalTemplateItemsTable,
          LocalTemplateItem
        >,
      ),
      LocalTemplateItem,
      PrefetchHooks Function()
    >;
typedef $$LocalAssetsTableCreateCompanionBuilder =
    LocalAssetsCompanion Function({
      required String id,
      required String kind,
      required String code,
      required bool active,
      required int revision,
      Value<String?> siteId,
      Value<String?> licensePlate,
      Value<String?> makeModel,
      Value<String?> manufacturer,
      Value<int?> manufactureYear,
      Value<String?> predominantColor,
      Value<String> ownershipType,
      required String rawJson,
      Value<int> rowid,
    });
typedef $$LocalAssetsTableUpdateCompanionBuilder =
    LocalAssetsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> code,
      Value<bool> active,
      Value<int> revision,
      Value<String?> siteId,
      Value<String?> licensePlate,
      Value<String?> makeModel,
      Value<String?> manufacturer,
      Value<int?> manufactureYear,
      Value<String?> predominantColor,
      Value<String> ownershipType,
      Value<String> rawJson,
      Value<int> rowid,
    });

class $$LocalAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get makeModel => $composableBuilder(
    column: $table.makeModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predominantColor => $composableBuilder(
    column: $table.predominantColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get makeModel => $composableBuilder(
    column: $table.makeModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predominantColor => $composableBuilder(
    column: $table.predominantColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssetsTable> {
  $$LocalAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get makeModel =>
      $composableBuilder(column: $table.makeModel, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manufactureYear => $composableBuilder(
    column: $table.manufactureYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get predominantColor => $composableBuilder(
    column: $table.predominantColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$LocalAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssetsTable,
          LocalAsset,
          $$LocalAssetsTableFilterComposer,
          $$LocalAssetsTableOrderingComposer,
          $$LocalAssetsTableAnnotationComposer,
          $$LocalAssetsTableCreateCompanionBuilder,
          $$LocalAssetsTableUpdateCompanionBuilder,
          (
            LocalAsset,
            BaseReferences<_$AppDatabase, $LocalAssetsTable, LocalAsset>,
          ),
          LocalAsset,
          PrefetchHooks Function()
        > {
  $$LocalAssetsTableTableManager(_$AppDatabase db, $LocalAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String?> licensePlate = const Value.absent(),
                Value<String?> makeModel = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<int?> manufactureYear = const Value.absent(),
                Value<String?> predominantColor = const Value.absent(),
                Value<String> ownershipType = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsCompanion(
                id: id,
                kind: kind,
                code: code,
                active: active,
                revision: revision,
                siteId: siteId,
                licensePlate: licensePlate,
                makeModel: makeModel,
                manufacturer: manufacturer,
                manufactureYear: manufactureYear,
                predominantColor: predominantColor,
                ownershipType: ownershipType,
                rawJson: rawJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String code,
                required bool active,
                required int revision,
                Value<String?> siteId = const Value.absent(),
                Value<String?> licensePlate = const Value.absent(),
                Value<String?> makeModel = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<int?> manufactureYear = const Value.absent(),
                Value<String?> predominantColor = const Value.absent(),
                Value<String> ownershipType = const Value.absent(),
                required String rawJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsCompanion.insert(
                id: id,
                kind: kind,
                code: code,
                active: active,
                revision: revision,
                siteId: siteId,
                licensePlate: licensePlate,
                makeModel: makeModel,
                manufacturer: manufacturer,
                manufactureYear: manufactureYear,
                predominantColor: predominantColor,
                ownershipType: ownershipType,
                rawJson: rawJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAssetsTable, LocalAsset>(table),
                  BaseReferences<_$AppDatabase, $LocalAssetsTable, LocalAsset>(
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

typedef $$LocalAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssetsTable,
      LocalAsset,
      $$LocalAssetsTableFilterComposer,
      $$LocalAssetsTableOrderingComposer,
      $$LocalAssetsTableAnnotationComposer,
      $$LocalAssetsTableCreateCompanionBuilder,
      $$LocalAssetsTableUpdateCompanionBuilder,
      (
        LocalAsset,
        BaseReferences<_$AppDatabase, $LocalAssetsTable, LocalAsset>,
      ),
      LocalAsset,
      PrefetchHooks Function()
    >;
typedef $$LocalOperationConfigsTableCreateCompanionBuilder =
    LocalOperationConfigsCompanion Function({
      required String id,
      required String templateId,
      required String timezone,
      required String weekStartsOn,
      required String requiredWeekdaysJson,
      required int maxOccurrencesPerDate,
      required String rawJson,
      Value<int> rowid,
    });
typedef $$LocalOperationConfigsTableUpdateCompanionBuilder =
    LocalOperationConfigsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> timezone,
      Value<String> weekStartsOn,
      Value<String> requiredWeekdaysJson,
      Value<int> maxOccurrencesPerDate,
      Value<String> rawJson,
      Value<int> rowid,
    });

class $$LocalOperationConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOperationConfigsTable> {
  $$LocalOperationConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requiredWeekdaysJson => $composableBuilder(
    column: $table.requiredWeekdaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxOccurrencesPerDate => $composableBuilder(
    column: $table.maxOccurrencesPerDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalOperationConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOperationConfigsTable> {
  $$LocalOperationConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requiredWeekdaysJson => $composableBuilder(
    column: $table.requiredWeekdaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxOccurrencesPerDate => $composableBuilder(
    column: $table.maxOccurrencesPerDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalOperationConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOperationConfigsTable> {
  $$LocalOperationConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get weekStartsOn => $composableBuilder(
    column: $table.weekStartsOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requiredWeekdaysJson => $composableBuilder(
    column: $table.requiredWeekdaysJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxOccurrencesPerDate => $composableBuilder(
    column: $table.maxOccurrencesPerDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$LocalOperationConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOperationConfigsTable,
          LocalOperationConfig,
          $$LocalOperationConfigsTableFilterComposer,
          $$LocalOperationConfigsTableOrderingComposer,
          $$LocalOperationConfigsTableAnnotationComposer,
          $$LocalOperationConfigsTableCreateCompanionBuilder,
          $$LocalOperationConfigsTableUpdateCompanionBuilder,
          (
            LocalOperationConfig,
            BaseReferences<
              _$AppDatabase,
              $LocalOperationConfigsTable,
              LocalOperationConfig
            >,
          ),
          LocalOperationConfig,
          PrefetchHooks Function()
        > {
  $$LocalOperationConfigsTableTableManager(
    _$AppDatabase db,
    $LocalOperationConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOperationConfigsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalOperationConfigsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalOperationConfigsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> weekStartsOn = const Value.absent(),
                Value<String> requiredWeekdaysJson = const Value.absent(),
                Value<int> maxOccurrencesPerDate = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOperationConfigsCompanion(
                id: id,
                templateId: templateId,
                timezone: timezone,
                weekStartsOn: weekStartsOn,
                requiredWeekdaysJson: requiredWeekdaysJson,
                maxOccurrencesPerDate: maxOccurrencesPerDate,
                rawJson: rawJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String timezone,
                required String weekStartsOn,
                required String requiredWeekdaysJson,
                required int maxOccurrencesPerDate,
                required String rawJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalOperationConfigsCompanion.insert(
                id: id,
                templateId: templateId,
                timezone: timezone,
                weekStartsOn: weekStartsOn,
                requiredWeekdaysJson: requiredWeekdaysJson,
                maxOccurrencesPerDate: maxOccurrencesPerDate,
                rawJson: rawJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalOperationConfigsTable,
                    LocalOperationConfig
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalOperationConfigsTable,
                    LocalOperationConfig
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOperationConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOperationConfigsTable,
      LocalOperationConfig,
      $$LocalOperationConfigsTableFilterComposer,
      $$LocalOperationConfigsTableOrderingComposer,
      $$LocalOperationConfigsTableAnnotationComposer,
      $$LocalOperationConfigsTableCreateCompanionBuilder,
      $$LocalOperationConfigsTableUpdateCompanionBuilder,
      (
        LocalOperationConfig,
        BaseReferences<
          _$AppDatabase,
          $LocalOperationConfigsTable,
          LocalOperationConfig
        >,
      ),
      LocalOperationConfig,
      PrefetchHooks Function()
    >;
typedef $$LocalWeeklyChecklistsTableCreateCompanionBuilder =
    LocalWeeklyChecklistsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String assetId,
      required String templateId,
      required String templateVersionId,
      required String operationConfigId,
      required String weekStartDate,
      required String timezone,
      Value<int?> revision,
      Value<String> syncState,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalWeeklyChecklistsTableUpdateCompanionBuilder =
    LocalWeeklyChecklistsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> assetId,
      Value<String> templateId,
      Value<String> templateVersionId,
      Value<String> operationConfigId,
      Value<String> weekStartDate,
      Value<String> timezone,
      Value<int?> revision,
      Value<String> syncState,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalWeeklyChecklistsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWeeklyChecklistsTable> {
  $$LocalWeeklyChecklistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationConfigId => $composableBuilder(
    column: $table.operationConfigId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWeeklyChecklistsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWeeklyChecklistsTable> {
  $$LocalWeeklyChecklistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationConfigId => $composableBuilder(
    column: $table.operationConfigId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWeeklyChecklistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWeeklyChecklistsTable> {
  $$LocalWeeklyChecklistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateVersionId => $composableBuilder(
    column: $table.templateVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationConfigId => $composableBuilder(
    column: $table.operationConfigId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalWeeklyChecklistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWeeklyChecklistsTable,
          LocalWeeklyChecklist,
          $$LocalWeeklyChecklistsTableFilterComposer,
          $$LocalWeeklyChecklistsTableOrderingComposer,
          $$LocalWeeklyChecklistsTableAnnotationComposer,
          $$LocalWeeklyChecklistsTableCreateCompanionBuilder,
          $$LocalWeeklyChecklistsTableUpdateCompanionBuilder,
          (
            LocalWeeklyChecklist,
            BaseReferences<
              _$AppDatabase,
              $LocalWeeklyChecklistsTable,
              LocalWeeklyChecklist
            >,
          ),
          LocalWeeklyChecklist,
          PrefetchHooks Function()
        > {
  $$LocalWeeklyChecklistsTableTableManager(
    _$AppDatabase db,
    $LocalWeeklyChecklistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWeeklyChecklistsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalWeeklyChecklistsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWeeklyChecklistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> templateVersionId = const Value.absent(),
                Value<String> operationConfigId = const Value.absent(),
                Value<String> weekStartDate = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWeeklyChecklistsCompanion(
                id: id,
                serverId: serverId,
                assetId: assetId,
                templateId: templateId,
                templateVersionId: templateVersionId,
                operationConfigId: operationConfigId,
                weekStartDate: weekStartDate,
                timezone: timezone,
                revision: revision,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String assetId,
                required String templateId,
                required String templateVersionId,
                required String operationConfigId,
                required String weekStartDate,
                required String timezone,
                Value<int?> revision = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalWeeklyChecklistsCompanion.insert(
                id: id,
                serverId: serverId,
                assetId: assetId,
                templateId: templateId,
                templateVersionId: templateVersionId,
                operationConfigId: operationConfigId,
                weekStartDate: weekStartDate,
                timezone: timezone,
                revision: revision,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalWeeklyChecklistsTable,
                    LocalWeeklyChecklist
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalWeeklyChecklistsTable,
                    LocalWeeklyChecklist
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWeeklyChecklistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWeeklyChecklistsTable,
      LocalWeeklyChecklist,
      $$LocalWeeklyChecklistsTableFilterComposer,
      $$LocalWeeklyChecklistsTableOrderingComposer,
      $$LocalWeeklyChecklistsTableAnnotationComposer,
      $$LocalWeeklyChecklistsTableCreateCompanionBuilder,
      $$LocalWeeklyChecklistsTableUpdateCompanionBuilder,
      (
        LocalWeeklyChecklist,
        BaseReferences<
          _$AppDatabase,
          $LocalWeeklyChecklistsTable,
          LocalWeeklyChecklist
        >,
      ),
      LocalWeeklyChecklist,
      PrefetchHooks Function()
    >;
typedef $$LocalInspectionsTableCreateCompanionBuilder =
    LocalInspectionsCompanion Function({
      required String id,
      Value<String?> serverId,
      required String weeklyChecklistId,
      required String localDate,
      Value<int> occurrenceNo,
      Value<String> lifecycleStatus,
      required String identificationJson,
      Value<String?> observations,
      Value<int?> revision,
      Value<String> syncState,
      Value<String?> lastError,
      Value<String?> conflictId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalInspectionsTableUpdateCompanionBuilder =
    LocalInspectionsCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> weeklyChecklistId,
      Value<String> localDate,
      Value<int> occurrenceNo,
      Value<String> lifecycleStatus,
      Value<String> identificationJson,
      Value<String?> observations,
      Value<int?> revision,
      Value<String> syncState,
      Value<String?> lastError,
      Value<String?> conflictId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalInspectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInspectionsTable> {
  $$LocalInspectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weeklyChecklistId => $composableBuilder(
    column: $table.weeklyChecklistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceNo => $composableBuilder(
    column: $table.occurrenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identificationJson => $composableBuilder(
    column: $table.identificationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInspectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInspectionsTable> {
  $$LocalInspectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weeklyChecklistId => $composableBuilder(
    column: $table.weeklyChecklistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceNo => $composableBuilder(
    column: $table.occurrenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identificationJson => $composableBuilder(
    column: $table.identificationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInspectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInspectionsTable> {
  $$LocalInspectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get weeklyChecklistId => $composableBuilder(
    column: $table.weeklyChecklistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get occurrenceNo => $composableBuilder(
    column: $table.occurrenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycleStatus => $composableBuilder(
    column: $table.lifecycleStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get identificationJson => $composableBuilder(
    column: $table.identificationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalInspectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInspectionsTable,
          LocalInspection,
          $$LocalInspectionsTableFilterComposer,
          $$LocalInspectionsTableOrderingComposer,
          $$LocalInspectionsTableAnnotationComposer,
          $$LocalInspectionsTableCreateCompanionBuilder,
          $$LocalInspectionsTableUpdateCompanionBuilder,
          (
            LocalInspection,
            BaseReferences<
              _$AppDatabase,
              $LocalInspectionsTable,
              LocalInspection
            >,
          ),
          LocalInspection,
          PrefetchHooks Function()
        > {
  $$LocalInspectionsTableTableManager(
    _$AppDatabase db,
    $LocalInspectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInspectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInspectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInspectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> weeklyChecklistId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> occurrenceNo = const Value.absent(),
                Value<String> lifecycleStatus = const Value.absent(),
                Value<String> identificationJson = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> conflictId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInspectionsCompanion(
                id: id,
                serverId: serverId,
                weeklyChecklistId: weeklyChecklistId,
                localDate: localDate,
                occurrenceNo: occurrenceNo,
                lifecycleStatus: lifecycleStatus,
                identificationJson: identificationJson,
                observations: observations,
                revision: revision,
                syncState: syncState,
                lastError: lastError,
                conflictId: conflictId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String weeklyChecklistId,
                required String localDate,
                Value<int> occurrenceNo = const Value.absent(),
                Value<String> lifecycleStatus = const Value.absent(),
                required String identificationJson,
                Value<String?> observations = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> conflictId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInspectionsCompanion.insert(
                id: id,
                serverId: serverId,
                weeklyChecklistId: weeklyChecklistId,
                localDate: localDate,
                occurrenceNo: occurrenceNo,
                lifecycleStatus: lifecycleStatus,
                identificationJson: identificationJson,
                observations: observations,
                revision: revision,
                syncState: syncState,
                lastError: lastError,
                conflictId: conflictId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalInspectionsTable, LocalInspection>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalInspectionsTable,
                    LocalInspection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInspectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInspectionsTable,
      LocalInspection,
      $$LocalInspectionsTableFilterComposer,
      $$LocalInspectionsTableOrderingComposer,
      $$LocalInspectionsTableAnnotationComposer,
      $$LocalInspectionsTableCreateCompanionBuilder,
      $$LocalInspectionsTableUpdateCompanionBuilder,
      (
        LocalInspection,
        BaseReferences<_$AppDatabase, $LocalInspectionsTable, LocalInspection>,
      ),
      LocalInspection,
      PrefetchHooks Function()
    >;
typedef $$LocalInspectionResponsesTableCreateCompanionBuilder =
    LocalInspectionResponsesCompanion Function({
      required String inspectionId,
      required String itemId,
      Value<String?> result,
      Value<String?> observation,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalInspectionResponsesTableUpdateCompanionBuilder =
    LocalInspectionResponsesCompanion Function({
      Value<String> inspectionId,
      Value<String> itemId,
      Value<String?> result,
      Value<String?> observation,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalInspectionResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInspectionResponsesTable> {
  $$LocalInspectionResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInspectionResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInspectionResponsesTable> {
  $$LocalInspectionResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInspectionResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInspectionResponsesTable> {
  $$LocalInspectionResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalInspectionResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInspectionResponsesTable,
          LocalInspectionResponse,
          $$LocalInspectionResponsesTableFilterComposer,
          $$LocalInspectionResponsesTableOrderingComposer,
          $$LocalInspectionResponsesTableAnnotationComposer,
          $$LocalInspectionResponsesTableCreateCompanionBuilder,
          $$LocalInspectionResponsesTableUpdateCompanionBuilder,
          (
            LocalInspectionResponse,
            BaseReferences<
              _$AppDatabase,
              $LocalInspectionResponsesTable,
              LocalInspectionResponse
            >,
          ),
          LocalInspectionResponse,
          PrefetchHooks Function()
        > {
  $$LocalInspectionResponsesTableTableManager(
    _$AppDatabase db,
    $LocalInspectionResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInspectionResponsesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInspectionResponsesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInspectionResponsesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> inspectionId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInspectionResponsesCompanion(
                inspectionId: inspectionId,
                itemId: itemId,
                result: result,
                observation: observation,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String inspectionId,
                required String itemId,
                Value<String?> result = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalInspectionResponsesCompanion.insert(
                inspectionId: inspectionId,
                itemId: itemId,
                result: result,
                observation: observation,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalInspectionResponsesTable,
                    LocalInspectionResponse
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalInspectionResponsesTable,
                    LocalInspectionResponse
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInspectionResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInspectionResponsesTable,
      LocalInspectionResponse,
      $$LocalInspectionResponsesTableFilterComposer,
      $$LocalInspectionResponsesTableOrderingComposer,
      $$LocalInspectionResponsesTableAnnotationComposer,
      $$LocalInspectionResponsesTableCreateCompanionBuilder,
      $$LocalInspectionResponsesTableUpdateCompanionBuilder,
      (
        LocalInspectionResponse,
        BaseReferences<
          _$AppDatabase,
          $LocalInspectionResponsesTable,
          LocalInspectionResponse
        >,
      ),
      LocalInspectionResponse,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxOperationsTableCreateCompanionBuilder =
    SyncOutboxOperationsCompanion Function({
      required String operationId,
      required String entityType,
      required String mutation,
      required String entityId,
      Value<int?> baseRevision,
      required DateTime clientOccurredAt,
      required String payloadJson,
      Value<int> attemptCount,
      Value<String> state,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxOperationsTableUpdateCompanionBuilder =
    SyncOutboxOperationsCompanion Function({
      Value<String> operationId,
      Value<String> entityType,
      Value<String> mutation,
      Value<String> entityId,
      Value<int?> baseRevision,
      Value<DateTime> clientOccurredAt,
      Value<String> payloadJson,
      Value<int> attemptCount,
      Value<String> state,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxOperationsTable> {
  $$SyncOutboxOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutation => $composableBuilder(
    column: $table.mutation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientOccurredAt => $composableBuilder(
    column: $table.clientOccurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxOperationsTable> {
  $$SyncOutboxOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutation => $composableBuilder(
    column: $table.mutation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientOccurredAt => $composableBuilder(
    column: $table.clientOccurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxOperationsTable> {
  $$SyncOutboxOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutation =>
      $composableBuilder(column: $table.mutation, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientOccurredAt => $composableBuilder(
    column: $table.clientOccurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxOperationsTable,
          SyncOutboxOperation,
          $$SyncOutboxOperationsTableFilterComposer,
          $$SyncOutboxOperationsTableOrderingComposer,
          $$SyncOutboxOperationsTableAnnotationComposer,
          $$SyncOutboxOperationsTableCreateCompanionBuilder,
          $$SyncOutboxOperationsTableUpdateCompanionBuilder,
          (
            SyncOutboxOperation,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxOperationsTable,
              SyncOutboxOperation
            >,
          ),
          SyncOutboxOperation,
          PrefetchHooks Function()
        > {
  $$SyncOutboxOperationsTableTableManager(
    _$AppDatabase db,
    $SyncOutboxOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncOutboxOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> mutation = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<DateTime> clientOccurredAt = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxOperationsCompanion(
                operationId: operationId,
                entityType: entityType,
                mutation: mutation,
                entityId: entityId,
                baseRevision: baseRevision,
                clientOccurredAt: clientOccurredAt,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                state: state,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String entityType,
                required String mutation,
                required String entityId,
                Value<int?> baseRevision = const Value.absent(),
                required DateTime clientOccurredAt,
                required String payloadJson,
                Value<int> attemptCount = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxOperationsCompanion.insert(
                operationId: operationId,
                entityType: entityType,
                mutation: mutation,
                entityId: entityId,
                baseRevision: baseRevision,
                clientOccurredAt: clientOccurredAt,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                state: state,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxOperationsTable, SyncOutboxOperation>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxOperationsTable,
                    SyncOutboxOperation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxOperationsTable,
      SyncOutboxOperation,
      $$SyncOutboxOperationsTableFilterComposer,
      $$SyncOutboxOperationsTableOrderingComposer,
      $$SyncOutboxOperationsTableAnnotationComposer,
      $$SyncOutboxOperationsTableCreateCompanionBuilder,
      $$SyncOutboxOperationsTableUpdateCompanionBuilder,
      (
        SyncOutboxOperation,
        BaseReferences<
          _$AppDatabase,
          $SyncOutboxOperationsTable,
          SyncOutboxOperation
        >,
      ),
      SyncOutboxOperation,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncMetadataTableCreateCompanionBuilder =
    LocalSyncMetadataCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSyncMetadataTableUpdateCompanionBuilder =
    LocalSyncMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncMetadataTable> {
  $$LocalSyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncMetadataTable> {
  $$LocalSyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncMetadataTable> {
  $$LocalSyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncMetadataTable,
          LocalSyncMetadataData,
          $$LocalSyncMetadataTableFilterComposer,
          $$LocalSyncMetadataTableOrderingComposer,
          $$LocalSyncMetadataTableAnnotationComposer,
          $$LocalSyncMetadataTableCreateCompanionBuilder,
          $$LocalSyncMetadataTableUpdateCompanionBuilder,
          (
            LocalSyncMetadataData,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncMetadataTable,
              LocalSyncMetadataData
            >,
          ),
          LocalSyncMetadataData,
          PrefetchHooks Function()
        > {
  $$LocalSyncMetadataTableTableManager(
    _$AppDatabase db,
    $LocalSyncMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncMetadataCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncMetadataCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSyncMetadataTable, LocalSyncMetadataData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSyncMetadataTable,
                    LocalSyncMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncMetadataTable,
      LocalSyncMetadataData,
      $$LocalSyncMetadataTableFilterComposer,
      $$LocalSyncMetadataTableOrderingComposer,
      $$LocalSyncMetadataTableAnnotationComposer,
      $$LocalSyncMetadataTableCreateCompanionBuilder,
      $$LocalSyncMetadataTableUpdateCompanionBuilder,
      (
        LocalSyncMetadataData,
        BaseReferences<
          _$AppDatabase,
          $LocalSyncMetadataTable,
          LocalSyncMetadataData
        >,
      ),
      LocalSyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$LocalConflictCasesTableCreateCompanionBuilder =
    LocalConflictCasesCompanion Function({
      required String id,
      required String type,
      required String status,
      Value<int?> revision,
      required String rawJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalConflictCasesTableUpdateCompanionBuilder =
    LocalConflictCasesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> status,
      Value<int?> revision,
      Value<String> rawJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalConflictCasesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConflictCasesTable> {
  $$LocalConflictCasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConflictCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConflictCasesTable> {
  $$LocalConflictCasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConflictCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConflictCasesTable> {
  $$LocalConflictCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalConflictCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalConflictCasesTable,
          LocalConflictCase,
          $$LocalConflictCasesTableFilterComposer,
          $$LocalConflictCasesTableOrderingComposer,
          $$LocalConflictCasesTableAnnotationComposer,
          $$LocalConflictCasesTableCreateCompanionBuilder,
          $$LocalConflictCasesTableUpdateCompanionBuilder,
          (
            LocalConflictCase,
            BaseReferences<
              _$AppDatabase,
              $LocalConflictCasesTable,
              LocalConflictCase
            >,
          ),
          LocalConflictCase,
          PrefetchHooks Function()
        > {
  $$LocalConflictCasesTableTableManager(
    _$AppDatabase db,
    $LocalConflictCasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConflictCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConflictCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConflictCasesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictCasesCompanion(
                id: id,
                type: type,
                status: status,
                revision: revision,
                rawJson: rawJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String status,
                Value<int?> revision = const Value.absent(),
                required String rawJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictCasesCompanion.insert(
                id: id,
                type: type,
                status: status,
                revision: revision,
                rawJson: rawJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalConflictCasesTable, LocalConflictCase>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalConflictCasesTable,
                    LocalConflictCase
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConflictCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalConflictCasesTable,
      LocalConflictCase,
      $$LocalConflictCasesTableFilterComposer,
      $$LocalConflictCasesTableOrderingComposer,
      $$LocalConflictCasesTableAnnotationComposer,
      $$LocalConflictCasesTableCreateCompanionBuilder,
      $$LocalConflictCasesTableUpdateCompanionBuilder,
      (
        LocalConflictCase,
        BaseReferences<
          _$AppDatabase,
          $LocalConflictCasesTable,
          LocalConflictCase
        >,
      ),
      LocalConflictCase,
      PrefetchHooks Function()
    >;
typedef $$LocalAttachmentsTableCreateCompanionBuilder =
    LocalAttachmentsCompanion Function({
      required String id,
      required String inspectionId,
      required String localPath,
      required String mediaType,
      required String purpose,
      Value<bool> requiredForCompletion,
      Value<String> syncState,
      Value<String?> remoteId,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$LocalAttachmentsTableUpdateCompanionBuilder =
    LocalAttachmentsCompanion Function({
      Value<String> id,
      Value<String> inspectionId,
      Value<String> localPath,
      Value<String> mediaType,
      Value<String> purpose,
      Value<bool> requiredForCompletion,
      Value<String> syncState,
      Value<String?> remoteId,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$LocalAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiredForCompletion => $composableBuilder(
    column: $table.requiredForCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiredForCompletion => $composableBuilder(
    column: $table.requiredForCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttachmentsTable> {
  $$LocalAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<bool> get requiredForCompletion => $composableBuilder(
    column: $table.requiredForCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$LocalAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttachmentsTable,
          LocalAttachment,
          $$LocalAttachmentsTableFilterComposer,
          $$LocalAttachmentsTableOrderingComposer,
          $$LocalAttachmentsTableAnnotationComposer,
          $$LocalAttachmentsTableCreateCompanionBuilder,
          $$LocalAttachmentsTableUpdateCompanionBuilder,
          (
            LocalAttachment,
            BaseReferences<
              _$AppDatabase,
              $LocalAttachmentsTable,
              LocalAttachment
            >,
          ),
          LocalAttachment,
          PrefetchHooks Function()
        > {
  $$LocalAttachmentsTableTableManager(
    _$AppDatabase db,
    $LocalAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> inspectionId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<bool> requiredForCompletion = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttachmentsCompanion(
                id: id,
                inspectionId: inspectionId,
                localPath: localPath,
                mediaType: mediaType,
                purpose: purpose,
                requiredForCompletion: requiredForCompletion,
                syncState: syncState,
                remoteId: remoteId,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String inspectionId,
                required String localPath,
                required String mediaType,
                required String purpose,
                Value<bool> requiredForCompletion = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttachmentsCompanion.insert(
                id: id,
                inspectionId: inspectionId,
                localPath: localPath,
                mediaType: mediaType,
                purpose: purpose,
                requiredForCompletion: requiredForCompletion,
                syncState: syncState,
                remoteId: remoteId,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAttachmentsTable, LocalAttachment>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAttachmentsTable,
                    LocalAttachment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttachmentsTable,
      LocalAttachment,
      $$LocalAttachmentsTableFilterComposer,
      $$LocalAttachmentsTableOrderingComposer,
      $$LocalAttachmentsTableAnnotationComposer,
      $$LocalAttachmentsTableCreateCompanionBuilder,
      $$LocalAttachmentsTableUpdateCompanionBuilder,
      (
        LocalAttachment,
        BaseReferences<_$AppDatabase, $LocalAttachmentsTable, LocalAttachment>,
      ),
      LocalAttachment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTemplateVersionsTableTableManager get localTemplateVersions =>
      $$LocalTemplateVersionsTableTableManager(_db, _db.localTemplateVersions);
  $$LocalTemplateSectionsTableTableManager get localTemplateSections =>
      $$LocalTemplateSectionsTableTableManager(_db, _db.localTemplateSections);
  $$LocalTemplateItemsTableTableManager get localTemplateItems =>
      $$LocalTemplateItemsTableTableManager(_db, _db.localTemplateItems);
  $$LocalAssetsTableTableManager get localAssets =>
      $$LocalAssetsTableTableManager(_db, _db.localAssets);
  $$LocalOperationConfigsTableTableManager get localOperationConfigs =>
      $$LocalOperationConfigsTableTableManager(_db, _db.localOperationConfigs);
  $$LocalWeeklyChecklistsTableTableManager get localWeeklyChecklists =>
      $$LocalWeeklyChecklistsTableTableManager(_db, _db.localWeeklyChecklists);
  $$LocalInspectionsTableTableManager get localInspections =>
      $$LocalInspectionsTableTableManager(_db, _db.localInspections);
  $$LocalInspectionResponsesTableTableManager get localInspectionResponses =>
      $$LocalInspectionResponsesTableTableManager(
        _db,
        _db.localInspectionResponses,
      );
  $$SyncOutboxOperationsTableTableManager get syncOutboxOperations =>
      $$SyncOutboxOperationsTableTableManager(_db, _db.syncOutboxOperations);
  $$LocalSyncMetadataTableTableManager get localSyncMetadata =>
      $$LocalSyncMetadataTableTableManager(_db, _db.localSyncMetadata);
  $$LocalConflictCasesTableTableManager get localConflictCases =>
      $$LocalConflictCasesTableTableManager(_db, _db.localConflictCases);
  $$LocalAttachmentsTableTableManager get localAttachments =>
      $$LocalAttachmentsTableTableManager(_db, _db.localAttachments);
}
