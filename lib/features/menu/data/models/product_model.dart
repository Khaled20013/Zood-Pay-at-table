import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/localized_name_model.dart';

part 'product_model.g.dart';

/// `GET /public/pay-at-table/categories?business_reference=…`
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CategoriesResponse {
  const CategoriesResponse({this.data = const []});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoriesResponseFromJson(json);

  final List<CategoryModel> data;

  Map<String, dynamic> toJson() => _$CategoriesResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.nameLocalized,
    this.image,
    this.index = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? nameLocalized;
  final String? image;
  @JsonKey(defaultValue: 0)
  final int index;

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}

/// `GET /public/pay-at-table/products?business_reference=…`
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ProductsResponse {
  const ProductsResponse({this.data = const []});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseFromJson(json);

  final List<ProductModel> data;

  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    this.nameLocalized,
    this.description,
    this.descriptionLocalized,
    this.image,
    this.price = 0,
    this.categoryId,
    this.modifiers = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? nameLocalized;
  final String? description;
  final String? descriptionLocalized;
  final String? image;
  @JsonKey(defaultValue: 0)
  final double price;
  @JsonKey(fromJson: jsonStringOrNull)
  final String? categoryId;
  final List<ProductModifierModel> modifiers;

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

/// A product's `modifiers[]` entry: rules only, names come from `/modifiers`.
@JsonSerializable(fieldRename: FieldRename.snake)
class ProductModifierModel {
  const ProductModifierModel({
    required this.modifierId,
    this.minimumOptions = 0,
    this.maximumOptions = 0,
    this.freeOptions = 0,
    this.uniqueOptions = true,
    this.defaultOptionsIds = const [],
    this.excludedOptionsIds = const [],
    this.index = 0,
  });

  factory ProductModifierModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModifierModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String modifierId;
  @JsonKey(defaultValue: 0)
  final int minimumOptions;
  @JsonKey(defaultValue: 0)
  final int maximumOptions;
  @JsonKey(defaultValue: 0)
  final int freeOptions;
  @JsonKey(defaultValue: true)
  final bool uniqueOptions;
  final List<String> defaultOptionsIds;
  final List<String> excludedOptionsIds;
  @JsonKey(defaultValue: 0)
  final int index;

  Map<String, dynamic> toJson() => _$ProductModifierModelToJson(this);
}

/// `GET /public/pay-at-table/modifiers?business_reference=…`
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ModifiersResponse {
  const ModifiersResponse({this.data = const []});

  factory ModifiersResponse.fromJson(Map<String, dynamic> json) =>
      _$ModifiersResponseFromJson(json);

  final List<ModifierModel> data;

  Map<String, dynamic> toJson() => _$ModifiersResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ModifierModel {
  const ModifierModel({
    required this.id,
    required this.name,
    this.nameLocalized,
    this.options = const [],
  });

  factory ModifierModel.fromJson(Map<String, dynamic> json) =>
      _$ModifierModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? nameLocalized;
  final List<ModifierOptionModel> options;

  Map<String, dynamic> toJson() => _$ModifierModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ModifierOptionModel {
  const ModifierOptionModel({
    required this.id,
    required this.name,
    this.nameLocalized,
    this.price = 0,
  });

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? nameLocalized;
  @JsonKey(defaultValue: 0)
  final double price;

  Map<String, dynamic> toJson() => _$ModifierOptionModelToJson(this);
}
