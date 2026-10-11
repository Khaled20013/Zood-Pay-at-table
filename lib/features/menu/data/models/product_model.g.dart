// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoriesResponse _$CategoriesResponseFromJson(Map<String, dynamic> json) =>
    CategoriesResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CategoriesResponseToJson(CategoriesResponse instance) =>
    <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: jsonString(json['id']),
      name: json['name'] as String? ?? '',
      nameLocalized: json['name_localized'] as String?,
      image: json['image'] as String?,
      index: (json['index'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_localized': instance.nameLocalized,
      'image': instance.image,
      'index': instance.index,
    };

ProductsResponse _$ProductsResponseFromJson(Map<String, dynamic> json) =>
    ProductsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductsResponseToJson(ProductsResponse instance) =>
    <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: jsonString(json['id']),
  name: json['name'] as String? ?? '',
  nameLocalized: json['name_localized'] as String?,
  description: json['description'] as String?,
  descriptionLocalized: json['description_localized'] as String?,
  image: json['image'] as String?,
  price: (json['price'] as num?)?.toDouble() ?? 0,
  categoryId: jsonStringOrNull(json['category_id']),
  modifiers:
      (json['modifiers'] as List<dynamic>?)
          ?.map((e) => ProductModifierModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_localized': instance.nameLocalized,
      'description': instance.description,
      'description_localized': instance.descriptionLocalized,
      'image': instance.image,
      'price': instance.price,
      'category_id': instance.categoryId,
      'modifiers': instance.modifiers.map((e) => e.toJson()).toList(),
    };

ProductModifierModel _$ProductModifierModelFromJson(
  Map<String, dynamic> json,
) => ProductModifierModel(
  modifierId: jsonString(json['modifier_id']),
  minimumOptions: (json['minimum_options'] as num?)?.toInt() ?? 0,
  maximumOptions: (json['maximum_options'] as num?)?.toInt() ?? 0,
  freeOptions: (json['free_options'] as num?)?.toInt() ?? 0,
  uniqueOptions: json['unique_options'] as bool? ?? true,
  defaultOptionsIds:
      (json['default_options_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  excludedOptionsIds:
      (json['excluded_options_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  index: (json['index'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProductModifierModelToJson(
  ProductModifierModel instance,
) => <String, dynamic>{
  'modifier_id': instance.modifierId,
  'minimum_options': instance.minimumOptions,
  'maximum_options': instance.maximumOptions,
  'free_options': instance.freeOptions,
  'unique_options': instance.uniqueOptions,
  'default_options_ids': instance.defaultOptionsIds,
  'excluded_options_ids': instance.excludedOptionsIds,
  'index': instance.index,
};

ModifiersResponse _$ModifiersResponseFromJson(Map<String, dynamic> json) =>
    ModifiersResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ModifierModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ModifiersResponseToJson(ModifiersResponse instance) =>
    <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};

ModifierModel _$ModifierModelFromJson(Map<String, dynamic> json) =>
    ModifierModel(
      id: jsonString(json['id']),
      name: json['name'] as String? ?? '',
      nameLocalized: json['name_localized'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => ModifierOptionModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ModifierModelToJson(ModifierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_localized': instance.nameLocalized,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

ModifierOptionModel _$ModifierOptionModelFromJson(Map<String, dynamic> json) =>
    ModifierOptionModel(
      id: jsonString(json['id']),
      name: json['name'] as String? ?? '',
      nameLocalized: json['name_localized'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ModifierOptionModelToJson(
  ModifierOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'name_localized': instance.nameLocalized,
  'price': instance.price,
};
