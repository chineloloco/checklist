import 'checklist_models.dart';

abstract interface class ChecklistRepository {
  Future<void> applyBootstrap(Map<String, Object?> payload);

  Future<List<AssetSummary>> listAssets();
  Future<List<TemplateChoice>> listAllTemplateChoices();
  Future<List<TemplateChoice>> listTemplateChoices(String assetId);
  Stream<List<WeeklyChecklistCard>> watchWeeklyChecklists();
  Future<WeeklyChecklistDetail> getWeeklyChecklist(String id);
  Stream<WeeklyChecklistDetail> watchWeeklyChecklist(String id);

  Future<String> openWeeklyChecklist({
    required String assetId,
    required TemplateChoice template,
    required DateTime localDate,
  });

  Future<String> openInspection({
    required String weeklyChecklistId,
    required DateTime localDate,
    required IdentificationSnapshot identification,
    int occurrenceNo = 1,
  });

  Future<InspectionDraft> getInspection(String inspectionId);
  Stream<InspectionDraft> watchInspection(String inspectionId);

  Future<void> saveAnswer({
    required String inspectionId,
    required String itemId,
    required InspectionResult? result,
    String? observation,
  });

  Future<void> saveInspectionNotes({
    required String inspectionId,
    required String? observations,
  });

  Future<void> saveIdentification({
    required String inspectionId,
    required IdentificationSnapshot identification,
  });

  Future<void> addPhotoAttachment({
    required String inspectionId,
    required String localPath,
    required String mediaType,
  });

  Future<void> removeAttachment({
    required String inspectionId,
    required String attachmentId,
  });

  Future<void> deactivateUnsyncedInspection(String inspectionId);

  Future<void> completeInspection(String inspectionId);
}
