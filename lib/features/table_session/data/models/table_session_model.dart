import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/localized_name_model.dart';
import '../../domain/entities/table_session.dart';

part 'table_session_model.g.dart';

/// `GET /public/pay-at-table/qr/{qr_id}` → `{ "data": QrModel }`
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QrResponse {
  const QrResponse({required this.data});

  factory QrResponse.fromJson(Map<String, dynamic> json) =>
      _$QrResponseFromJson(json);

  final QrModel data;

  Map<String, dynamic> toJson() => _$QrResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class QrModel {
  const QrModel({
    required this.id,
    required this.isActive,
    required this.businessReference,
    required this.branchId,
    required this.tableId,
    required this.branch,
    required this.table,
  });

  factory QrModel.fromJson(Map<String, dynamic> json) =>
      _$QrModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(fromJson: jsonString)
  final String businessReference;
  @JsonKey(fromJson: jsonString)
  final String branchId;
  @JsonKey(fromJson: jsonString)
  final String tableId;
  final LocalizedNameModel branch;
  final LocalizedNameModel table;

  Map<String, dynamic> toJson() => _$QrModelToJson(this);

  TableSession toEntity(String languageCode) => TableSession(
    qrId: id,
    businessReference: businessReference,
    branchId: branchId,
    branchName: branch.resolve(languageCode),
    tableId: tableId,
    tableName: table.resolve(languageCode),
  );
}
