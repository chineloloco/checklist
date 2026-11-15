import 'package:drift/drift.dart';

part 'app_database.g.dart';

class LocalTemplateVersions extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  IntColumn get versionNumber => integer()();
  TextColumn get status => text()();
  IntColumn get revision => integer()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get rawJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTemplateSections extends Table {
  TextColumn get id => text()();
  TextColumn get templateVersionId => text()();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTemplateItems extends Table {
  TextColumn get id => text()();
  TextColumn get templateVersionId => text()();
  TextColumn get sectionId => text()();
  TextColumn get sourcePrintedNumber => text().nullable()();
  TextColumn get textValue => text().named('text_value')();
  IntColumn get sortOrder => integer()();
  BoolColumn get requiredOnComplete => boolean().withDefault(const Constant(true))();
  BoolColumn get requireObservationWhenNc =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get requirePhotoWhenNc =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAssets extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get code => text()();
  BoolColumn get active => boolean()();
  IntColumn get revision => integer()();
  TextColumn get siteId => text().nullable()();
  TextColumn get licensePlate => text().nullable()();
  TextColumn get makeModel => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  IntColumn get manufactureYear => integer().nullable()();
  TextColumn get predominantColor => text().nullable()();
  TextColumn get ownershipType => text().withDefault(const Constant('OWN'))();
  TextColumn get rawJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalOperationConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get timezone => text()();
  TextColumn get weekStartsOn => text()();
  TextColumn get requiredWeekdaysJson => text()();
  IntColumn get maxOccurrencesPerDate => integer()();
  TextColumn get rawJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalWeeklyChecklists extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get assetId => text()();
  TextColumn get templateId => text()();
  TextColumn get templateVersionId => text()();
  TextColumn get operationConfigId => text()();
  TextColumn get weekStartDate => text()();
  TextColumn get timezone => text()();
  IntColumn get revision => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('LOCAL_ONLY'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {assetId, templateId, weekStartDate},
      ];
}

class LocalInspections extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get weeklyChecklistId => text()();
  TextColumn get localDate => text()();
  IntColumn get occurrenceNo => integer().withDefault(const Constant(1))();
  TextColumn get lifecycleStatus => text().withDefault(const Constant('DRAFT'))();
  TextColumn get identificationJson => text()();
  TextColumn get observations => text().nullable()();
  IntColumn get revision => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('LOCAL_ONLY'))();
  TextColumn get lastError => text().nullable()();
  TextColumn get conflictId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {weeklyChecklistId, localDate, occurrenceNo},
      ];
}

class LocalInspectionResponses extends Table {
  TextColumn get inspectionId => text()();
  TextColumn get itemId => text()();
  TextColumn get result => text().nullable()();
  TextColumn get observation => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {inspectionId, itemId};
}

class SyncOutboxOperations extends Table {
  TextColumn get operationId => text()();
  TextColumn get entityType => text()();
  TextColumn get mutation => text()();
  TextColumn get entityId => text()();
  IntColumn get baseRevision => integer().nullable()();
  DateTimeColumn get clientOccurredAt => dateTime()();
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('QUEUED'))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}

class LocalSyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class LocalConflictCases extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  IntColumn get revision => integer().nullable()();
  TextColumn get rawJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get inspectionId => text()();
  TextColumn get localPath => text()();
  TextColumn get mediaType => text()();
  TextColumn get purpose => text()();
  BoolColumn get requiredForCompletion =>
      boolean().withDefault(const Constant(false))();
  TextColumn get syncState => text().withDefault(const Constant('LOCAL_ONLY'))();
  TextColumn get remoteId => text().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalTemplateVersions,
    LocalTemplateSections,
    LocalTemplateItems,
    LocalAssets,
    LocalOperationConfigs,
    LocalWeeklyChecklists,
    LocalInspections,
    LocalInspectionResponses,
    SyncOutboxOperations,
    LocalSyncMetadata,
    LocalConflictCases,
    LocalAttachments,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
