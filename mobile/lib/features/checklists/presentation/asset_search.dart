import '../domain/checklist_models.dart';

List<AssetSummary> filterAssets(Iterable<AssetSummary> assets, String query) {
  final terms = _normalize(query)
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);

  if (terms.isEmpty) return assets.toList(growable: false);

  return assets
      .where((asset) {
        final searchableText = _normalize(
          [
            asset.code,
            asset.licensePlate,
            asset.makeModel,
            asset.manufacturer,
            asset.manufactureYear,
            asset.predominantColor,
          ].whereType<Object>().join(' '),
        );

        return terms.every(searchableText.contains);
      })
      .toList(growable: false);
}

String _normalize(String value) {
  const accented = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const plain = 'aaaaaeeeeiiiiooooouuuuc';
  var normalized = value.toLowerCase().trim();

  for (var index = 0; index < accented.length; index++) {
    normalized = normalized.replaceAll(accented[index], plain[index]);
  }

  return normalized;
}
