import '../../../core/errors/app_failure.dart';
import '../domain/checklist_models.dart';
import '../domain/checklist_repository.dart';

final class ChecklistService {
  ChecklistService(this.repository);
  final ChecklistRepository repository;

  Future<List<TemplateChoice>> availableTemplates() =>
      repository.listAllTemplateChoices();

  Future<String> openWeek({
    required AssetSummary asset,
    required TemplateChoice template,
    required DateTime localDate,
  }) => repository.openWeeklyChecklist(
    assetId: asset.id,
    template: template,
    localDate: localDate,
  );

  Future<List<TemplateChoice>> templatesFor(AssetSummary asset) async {
    final choices = await repository.listTemplateChoices(asset.id);
    if (choices.isEmpty) {
      throw const ConfigurationFailure(
        'Nenhum modelo publicado e configurado foi baixado para este ativo.',
      );
    }
    return choices;
  }

  Future<String> openInspection({
    required WeeklyChecklistDetail week,
    required DateTime localDate,
    required IdentificationSnapshot identification,
  }) {
    if (!week.contains(localDate)) {
      throw const ValidationFailure(
        'Escolha uma data dentro da semana deste checklist.',
      );
    }
    return repository.openInspection(
      weeklyChecklistId: week.id,
      localDate: localDate,
      identification: identification,
    );
  }
}
