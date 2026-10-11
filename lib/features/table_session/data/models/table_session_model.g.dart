// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrResponse _$QrResponseFromJson(Map<String, dynamic> json) =>
    QrResponse(data: QrModel.fromJson(json['data'] as Map<String, dynamic>));

Map<String, dynamic> _$QrResponseToJson(QrResponse instance) =>
    <String, dynamic>{'data': instance.data.toJson()};

QrModel _$QrModelFromJson(Map<String, dynamic> json) => QrModel(
  id: jsonString(json['id']),
  isActive: json['is_active'] as bool? ?? true,
  businessReference: jsonString(json['business_reference']),
  branchId: jsonString(json['branch_id']),
  tableId: jsonString(json['table_id']),
  branch: LocalizedNameModel.fromJson(json['branch'] as Map<String, dynamic>),
  table: LocalizedNameModel.fromJson(json['table'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QrModelToJson(QrModel instance) => <String, dynamic>{
  'id': instance.id,
  'is_active': instance.isActive,
  'business_reference': instance.businessReference,
  'branch_id': instance.branchId,
  'table_id': instance.tableId,
  'branch': instance.branch.toJson(),
  'table': instance.table.toJson(),
};
