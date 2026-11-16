import 'package:flutter/services.dart';

final class BrazilianDateInputFormatter extends TextInputFormatter {
  const BrazilianDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var index = 0; index < limited.length; index++) {
      if (index == 2 || index == 4) buffer.write('/');
      buffer.write(limited[index]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String? brazilianDateToIso(String value) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value.trim());
  if (match == null) return null;
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime.tryParse(
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-'
    '${day.toString().padLeft(2, '0')}',
  );
  if (date == null ||
      date.year != year ||
      date.month != month ||
      date.day != day) {
    return null;
  }
  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

String? optionalBrazilianDateError(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return brazilianDateToIso(text) == null
      ? 'Informe uma data válida no formato DD/MM/AAAA.'
      : null;
}
