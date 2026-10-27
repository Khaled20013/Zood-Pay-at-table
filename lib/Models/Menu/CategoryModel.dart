import 'package:equatable/equatable.dart';

import '../../Helper/LocalizedText.dart';
import '../../Helper/path_selector_base.dart';

/// An entry of `GET /public/pay-at-table/categories?business_reference=…`.
class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.index = 0,
  });

  /// [name] is resolved for [languageCode].
  factory CategoryModel.fromJson(
    Map<String, dynamic>? json, {
    required String languageCode,
  }) => CategoryModel(
    id: jsonString(json?.select('id')),
    name: localizedText(
      jsonString(json?.select('name')),
      jsonStringOrNull(json?.select('name_localized')),
      languageCode,
    ),
    image: jsonStringOrNull(json?.select('image')),
    index: jsonInt(json?.select('index')),
  );

  static List<CategoryModel> fromList(
    List<Map<String, dynamic>> results, {
    required String languageCode,
  }) => [
    for (final json in results)
      CategoryModel.fromJson(json, languageCode: languageCode),
  ];

  final String id;
  final String name;
  final String? image;
  final int index;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'index': index,
  };

  @override
  List<Object?> get props => [id, name, image, index];
}
