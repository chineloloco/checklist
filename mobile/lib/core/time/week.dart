DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime startOfMondayWeek(DateTime value) {
  final date = dateOnly(value);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

bool belongsToWeek(DateTime date, DateTime weekStart) {
  final normalized = dateOnly(date);
  final start = dateOnly(weekStart);
  final end = start.add(const Duration(days: 6));
  return !normalized.isBefore(start) && !normalized.isAfter(end);
}

String isoDate(DateTime value) {
  final date = dateOnly(value);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

DateTime parseIsoDate(String value) {
  final parts = value.split('-').map(int.parse).toList(growable: false);
  return DateTime(parts[0], parts[1], parts[2]);
}
