import '../../../core/input/search_text.dart';
import '../domain/checklist_models.dart';

List<AssetSummary> filterAssets(Iterable<AssetSummary> assets, String query) {
  final terms = normalizeSearchText(query)
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);

  if (terms.isEmpty) return assets.toList(growable: false);

  return assets
      .where((asset) {
        final searchableText = normalizeSearchText(
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
