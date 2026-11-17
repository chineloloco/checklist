import '../../../core/time/week.dart';

enum InspectionResult { compliant, nonCompliant, notApplicable }

extension InspectionResultX on InspectionResult {
  String get code => switch (this) {
    InspectionResult.compliant => 'C',
    InspectionResult.nonCompliant => 'NC',
    InspectionResult.notApplicable => 'NA',
  };

  String get label => switch (this) {
    InspectionResult.compliant => 'Conforme',
    InspectionResult.nonCompliant => 'Não conforme',
    InspectionResult.notApplicable => 'Não aplicável',
  };

  static InspectionResult? fromCode(String? value) => switch (value) {
    'C' => InspectionResult.compliant,
    'NC' => InspectionResult.nonCompliant,
    'NA' => InspectionResult.notApplicable,
    _ => null,
  };
}

enum InspectionLifecycle { draft, completed, corrected, voided }

extension InspectionLifecycleX on InspectionLifecycle {
  String get code => name.toUpperCase();

  String get label => switch (this) {
    InspectionLifecycle.draft => 'Rascunho',
    InspectionLifecycle.completed => 'Concluída',
    InspectionLifecycle.corrected => 'Corrigida',
    InspectionLifecycle.voided => 'Desativada',
  };

  static InspectionLifecycle fromCode(String value) => switch (value) {
    'COMPLETED' => InspectionLifecycle.completed,
    'CORRECTED' => InspectionLifecycle.corrected,
    'VOIDED' => InspectionLifecycle.voided,
    _ => InspectionLifecycle.draft,
  };
}

enum LocalSyncState { localOnly, queued, syncing, synced, conflict, error }

extension LocalSyncStateX on LocalSyncState {
  String get code => switch (this) {
    LocalSyncState.localOnly => 'LOCAL_ONLY',
    LocalSyncState.queued => 'QUEUED',
    LocalSyncState.syncing => 'SYNCING',
    LocalSyncState.synced => 'SYNCED',
    LocalSyncState.conflict => 'CONFLICT',
    LocalSyncState.error => 'ERROR',
  };

  String get label => switch (this) {
    LocalSyncState.localOnly => 'Somente neste aparelho',
    LocalSyncState.queued => 'Envio pendente',
    LocalSyncState.syncing => 'Enviando',
    LocalSyncState.synced => 'Sincronizada',
    LocalSyncState.conflict => 'Conflito',
    LocalSyncState.error => 'Falha no envio',
  };

  static LocalSyncState fromCode(String value) => switch (value) {
    'QUEUED' => LocalSyncState.queued,
    'SYNCING' => LocalSyncState.syncing,
    'SYNCED' => LocalSyncState.synced,
    'CONFLICT' => LocalSyncState.conflict,
    'ERROR' => LocalSyncState.error,
    _ => LocalSyncState.localOnly,
  };
}

final class AssetSummary {
  const AssetSummary({
    required this.id,
    required this.kind,
    required this.code,
    required this.active,
    this.siteId,
    this.licensePlate,
    this.makeModel,
    this.manufacturer,
    this.manufactureYear,
    this.predominantColor,
    this.ownershipType = 'OWN',
  });

  final String id;
  final String kind;
  final String code;
  final bool active;
  final String? siteId;
  final String? licensePlate;
  final String? makeModel;
  final String? manufacturer;
  final int? manufactureYear;
  final String? predominantColor;
  final String ownershipType;

  String get description =>
      licensePlate ??
      makeModel ??
      manufacturer ??
      'Sem identificação complementar';
}

final class RegistryCompany {
  const RegistryCompany({required this.id, required this.name});
  final String id;
  final String name;
}

final class RegistrySite {
  const RegistrySite({
    required this.id,
    required this.companyId,
    required this.name,
  });
  final String id;
  final String companyId;
  final String name;
}

final class RegistryPerson {
  const RegistryPerson({
    required this.id,
    required this.name,
    required this.kind,
    this.driverLicenseNumber,
    this.driverLicenseExpiryDate,
  });
  final String id;
  final String name;
  final String kind;
  final String? driverLicenseNumber;
  final String? driverLicenseExpiryDate;
}

final class TemplateChoice {
  const TemplateChoice({
    required this.templateId,
    required this.templateVersionId,
    required this.operationConfigId,
    required this.versionNumber,
    required this.timezone,
    required this.maxOccurrencesPerDate,
    required this.code,
    required this.name,
    required this.assetKind,
  });

  final String templateId;
  final String templateVersionId;
  final String operationConfigId;
  final int versionNumber;
  final String timezone;
  final int maxOccurrencesPerDate;
  final String code;
  final String name;
  final String assetKind;

  String get displayName => '$code · $name';
}

final class IdentificationSnapshot {
  const IdentificationSnapshot({
    required this.company,
    required this.site,
    required this.assetCode,
    required this.ownershipType,
    required this.responsiblePersonName,
    this.manufactureYear,
    this.predominantColor,
    this.licensePlate,
    this.vehicleMakeModel,
    this.manufacturer,
    this.responsiblePersonId,
    this.driverLicenseNumber,
    this.driverLicenseExpiryDate,
  });

  final String company;
  final String site;
  final String assetCode;
  final String ownershipType;
  final String responsiblePersonName;
  final int? manufactureYear;
  final String? predominantColor;
  final String? licensePlate;
  final String? vehicleMakeModel;
  final String? manufacturer;
  final String? responsiblePersonId;
  final String? driverLicenseNumber;
  final String? driverLicenseExpiryDate;

  Map<String, Object?> toJson() => {
    'company': company,
    'site': site,
    'manufactureYear': manufactureYear,
    'predominantColor': predominantColor,
    'assetCode': assetCode,
    'ownershipType': ownershipType,
    'licensePlate': licensePlate,
    'vehicleMakeModel': vehicleMakeModel,
    'manufacturer': manufacturer,
    'responsiblePersonId': responsiblePersonId,
    'responsiblePersonName': responsiblePersonName,
    'driverLicenseNumber': driverLicenseNumber,
    'driverLicenseExpiryDate': driverLicenseExpiryDate,
  };

  factory IdentificationSnapshot.fromJson(Map<String, Object?> json) =>
      IdentificationSnapshot(
        company: json['company'] as String? ?? '',
        site: json['site'] as String? ?? '',
        assetCode: json['assetCode'] as String? ?? '',
        ownershipType: json['ownershipType'] as String? ?? 'OWN',
        responsiblePersonName: json['responsiblePersonName'] as String? ?? '',
        manufactureYear: json['manufactureYear'] as int?,
        predominantColor: json['predominantColor'] as String?,
        licensePlate: json['licensePlate'] as String?,
        vehicleMakeModel: json['vehicleMakeModel'] as String?,
        manufacturer: json['manufacturer'] as String?,
        responsiblePersonId: json['responsiblePersonId'] as String?,
        driverLicenseNumber: json['driverLicenseNumber'] as String?,
        driverLicenseExpiryDate: json['driverLicenseExpiryDate'] as String?,
      );
}

final class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.sectionId,
    required this.sectionTitle,
    required this.text,
    required this.order,
    required this.requiredOnComplete,
    required this.requireObservationWhenNc,
    required this.requirePhotoWhenNc,
    this.sourcePrintedNumber,
    this.result,
    this.observation,
  });

  final String id;
  final String sectionId;
  final String sectionTitle;
  final String text;
  final int order;
  final bool requiredOnComplete;
  final bool requireObservationWhenNc;
  final bool requirePhotoWhenNc;
  final String? sourcePrintedNumber;
  final InspectionResult? result;
  final String? observation;

  ChecklistItem copyWith({
    InspectionResult? result,
    bool clearResult = false,
    String? observation,
  }) => ChecklistItem(
    id: id,
    sectionId: sectionId,
    sectionTitle: sectionTitle,
    text: text,
    order: order,
    requiredOnComplete: requiredOnComplete,
    requireObservationWhenNc: requireObservationWhenNc,
    requirePhotoWhenNc: requirePhotoWhenNc,
    sourcePrintedNumber: sourcePrintedNumber,
    result: clearResult ? null : result ?? this.result,
    observation: observation ?? this.observation,
  );
}

final class InspectionDraft {
  const InspectionDraft({
    required this.id,
    required this.weeklyChecklistId,
    required this.localDate,
    required this.occurrenceNo,
    required this.lifecycle,
    required this.syncState,
    required this.identification,
    required this.items,
    required this.templateVersionNumber,
    required this.templateDisplayName,
    this.attachments = const [],
    this.hasBeenSent = false,
    this.observations,
    this.revision,
    this.lastError,
    this.conflictId,
  });

  final String id;
  final String weeklyChecklistId;
  final DateTime localDate;
  final int occurrenceNo;
  final InspectionLifecycle lifecycle;
  final LocalSyncState syncState;
  final IdentificationSnapshot identification;
  final List<ChecklistItem> items;
  final int templateVersionNumber;
  final String templateDisplayName;
  final List<InspectionAttachment> attachments;
  final bool hasBeenSent;
  final String? observations;
  final int? revision;
  final String? lastError;
  final String? conflictId;

  int get answeredCount => items.where((item) => item.result != null).length;
  int get requiredCount =>
      items.where((item) => item.requiredOnComplete).length;
  int get requiredAnsweredCount => items
      .where((item) => item.requiredOnComplete && item.result != null)
      .length;
  bool get canComplete => requiredAnsweredCount == requiredCount;
  double get progress => items.isEmpty ? 0 : answeredCount / items.length;
  bool get canDeleteBeforeSync =>
      lifecycle != InspectionLifecycle.voided &&
      !hasBeenSent &&
      syncState != LocalSyncState.syncing;
}

final class InspectionAttachment {
  const InspectionAttachment({
    required this.id,
    required this.localPath,
    required this.mediaType,
    required this.syncState,
    this.lastError,
  });

  final String id;
  final String localPath;
  final String mediaType;
  final LocalSyncState syncState;
  final String? lastError;
}

final class InspectionSummary {
  const InspectionSummary({
    required this.id,
    required this.localDate,
    required this.occurrenceNo,
    required this.lifecycle,
    required this.syncState,
    required this.answeredCount,
    required this.totalCount,
    this.lastError,
    this.conflictId,
  });

  final String id;
  final DateTime localDate;
  final int occurrenceNo;
  final InspectionLifecycle lifecycle;
  final LocalSyncState syncState;
  final int answeredCount;
  final int totalCount;
  final String? lastError;
  final String? conflictId;
}

final class WeeklyChecklistCard {
  const WeeklyChecklistCard({
    required this.id,
    required this.asset,
    required this.weekStartDate,
    required this.templateId,
    required this.templateVersionNumber,
    required this.templateDisplayName,
    required this.syncState,
    required this.inspections,
  });

  final String id;
  final AssetSummary asset;
  final DateTime weekStartDate;
  final String templateId;
  final int templateVersionNumber;
  final String templateDisplayName;
  final LocalSyncState syncState;
  final List<InspectionSummary> inspections;

  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));
  int get completedCount => inspections
      .where((item) => item.lifecycle == InspectionLifecycle.completed)
      .length;
  bool get hasPendingSync =>
      inspections.any((item) => item.syncState != LocalSyncState.synced);
}

final class WeeklyChecklistDetail {
  const WeeklyChecklistDetail({
    required this.id,
    required this.asset,
    required this.weekStartDate,
    required this.timezone,
    required this.templateVersionNumber,
    required this.templateDisplayName,
    required this.inspections,
  });

  final String id;
  final AssetSummary asset;
  final DateTime weekStartDate;
  final String timezone;
  final int templateVersionNumber;
  final String templateDisplayName;
  final List<InspectionSummary> inspections;

  bool contains(DateTime date) => belongsToWeek(date, weekStartDate);
}
