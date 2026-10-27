import 'package:equatable/equatable.dart';

import '../../Helper/LocalizedText.dart';
import '../../Helper/path_selector_base.dart';
import 'ProductModel.dart';

/// A modifier of the business catalog
/// (`GET /public/pay-at-table/modifiers?business_reference=…`). Products
/// reference it by id and add their own rules (see [ProductModifierModel]).
class ModifierModel extends Equatable {
  const ModifierModel({
    required this.id,
    required this.name,
    this.options = const [],
  });

  /// [name] and option names are resolved for [languageCode].
  factory ModifierModel.fromJson(
    Map<String, dynamic>? json, {
    required String languageCode,
  }) => ModifierModel(
    id: jsonString(json?.select('id')),
    name: localizedText(
      jsonString(json?.select('name')),
      jsonStringOrNull(json?.select('name_localized')),
      languageCode,
    ),
    options: [
      for (final option in jsonObjects(json, 'options'))
        ModifierOptionModel.fromJson(option, languageCode: languageCode),
    ],
  );

  static List<ModifierModel> fromList(
    List<Map<String, dynamic>> results, {
    required String languageCode,
  }) => [
    for (final json in results)
      ModifierModel.fromJson(json, languageCode: languageCode),
  ];

  final String id;
  final String name;
  final List<ModifierOptionModel> options;

  @override
  List<Object?> get props => [id, name, options];
}
