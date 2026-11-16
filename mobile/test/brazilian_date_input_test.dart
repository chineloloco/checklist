import 'package:checklist_mobile/core/input/brazilian_date_input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('insere barras enquanto a data é digitada', () {
    const formatter = BrazilianDateInputFormatter();
    var value = TextEditingValue.empty;
    for (final text in ['2', '20', '200', '2005', '20052', '20052028']) {
      value = formatter.formatEditUpdate(value, TextEditingValue(text: text));
    }
    expect(value.text, '20/05/2028');
  });

  test('converte DD/MM/AAAA para o formato da API', () {
    expect(brazilianDateToIso('20/05/2028'), '2028-05-20');
    expect(brazilianDateToIso('31/02/2028'), isNull);
    expect(optionalBrazilianDateError(''), isNull);
    expect(optionalBrazilianDateError('20/05/2028'), isNull);
  });
}
