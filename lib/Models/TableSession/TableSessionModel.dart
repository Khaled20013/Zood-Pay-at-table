import 'package:equatable/equatable.dart';

import 'package:zood_pay_at_table/Helper/Configs/AppConfig.dart';
import 'package:zood_pay_at_table/Helper/LocalizedText.dart';
import 'package:zood_pay_at_table/Helper/path_selector_base.dart';

enum TableSessionStatus { initial, loading, loaded, failure }

/// What a table QR resolves to (`GET /public/pay-at-table/qr/{qr_id}`):
/// the business whose menu is shown, the branch and the table orders go to.
class TableSessionModel extends Equatable {
  const TableSessionModel({
    required this.qrId,
    required this.businessReference,
    required this.branchId,
    required this.branchName,
    required this.tableId,
    required this.tableName,
    this.currency = AppConfig.currency,
    this.vatRate = AppConfig.vatRate,
  });

  /// `data` of `GET /public/pay-at-table/qr/{qr_id}`, with branch and
  /// table names resolved for [languageCode].
  factory TableSessionModel.fromJson(
    Map<String, dynamic>? json, {
    required String languageCode,
  }) => TableSessionModel(
    qrId: jsonString(json?.select('id')),
    businessReference: jsonString(json?.select('business_reference')),
    branchId: jsonString(json?.select('branch_id')),
    branchName: localizedNameAt(json, 'branch', languageCode) ?? '',
    tableId: jsonString(json?.select('table_id')),
    tableName: localizedNameAt(json, 'table', languageCode) ?? '',
  );

  /// `is_active` of the QR check; missing means active.
  static bool isActiveJson(Map<String, dynamic>? json) =>
      getByType<bool>(json?.select('is_active')) ?? true;

  /// The path segment right after `/pay-at-table/` in the QR link.
  static final RegExp qrIdPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  final String qrId;

  /// Scopes the categories, products and modifiers requests.
  final String businessReference;
  final String branchId;

  /// Already localized, e.g. "Olaya" / "العليا".
  final String branchName;
  final String tableId;

  /// Already localized, e.g. "T5".
  final String tableName;

  /// ISO 4217 code, e.g. "SAR".
  final String currency;

  /// Menu prices exclude VAT; used to estimate the total before paying.
  final double vatRate;

  String get displayTitle => '$branchName · $tableName';

  @override
  List<Object?> get props => [
    qrId,
    businessReference,
    branchId,
    branchName,
    tableId,
    tableName,
    currency,
    vatRate,
  ];
}
