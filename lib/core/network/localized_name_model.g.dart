// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_name_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizedNameModel _$LocalizedNameModelFromJson(Map<String, dynamic> json) =>
    LocalizedNameModel(
      name: json['name'] as String? ?? '',
      nameLocalized: json['name_localized'] as String?,
    );

Map<String, dynamic> _$LocalizedNameModelToJson(LocalizedNameModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'name_localized': instance.nameLocalized,
    };
