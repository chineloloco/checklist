import '../domain/checklist_models.dart';

final class WeeklyFormGroup {
  const WeeklyFormGroup({
    required this.templateId,
    required this.templateDisplayName,
    required this.templateVersionNumber,
    required this.weekStartDate,
    required this.weeks,
  });

  final String templateId;
  final String templateDisplayName;
  final int templateVersionNumber;
  final DateTime weekStartDate;
  final List<WeeklyChecklistCard> weeks;

  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));
  int get vehicleCount => weeks.length;
  int get inspectionCount =>
      weeks.fold(0, (total, week) => total + week.inspections.length);
  int get completedCount =>
      weeks.fold(0, (total, week) => total + week.completedCount);
  bool get hasPendingSync => weeks.any((week) => week.hasPendingSync);

  bool matches(WeeklyChecklistCard week) =>
      week.templateId == templateId &&
      week.templateVersionNumber == templateVersionNumber &&
      _sameDate(week.weekStartDate, weekStartDate);
}

List<WeeklyFormGroup> groupWeeklyForms(
  Iterable<WeeklyChecklistCard> weeklyChecklists,
) {
  final grouped = <String, List<WeeklyChecklistCard>>{};
  for (final week in weeklyChecklists) {
    final date = week.weekStartDate;
    final key =
        '${week.templateId}|${week.templateVersionNumber}|'
        '${date.year}-${date.month}-${date.day}';
    grouped.putIfAbsent(key, () => []).add(week);
  }

  final result = grouped.values.map((weeks) {
    weeks.sort((left, right) => left.asset.code.compareTo(right.asset.code));
    final first = weeks.first;
    return WeeklyFormGroup(
      templateId: first.templateId,
      templateDisplayName: first.templateDisplayName,
      templateVersionNumber: first.templateVersionNumber,
      weekStartDate: first.weekStartDate,
      weeks: List.unmodifiable(weeks),
    );
  }).toList();

  result.sort((left, right) {
    final byDate = right.weekStartDate.compareTo(left.weekStartDate);
    if (byDate != 0) return byDate;
    return left.templateDisplayName.compareTo(right.templateDisplayName);
  });
  return result;
}

bool _sameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
