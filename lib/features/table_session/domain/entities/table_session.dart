import 'package:equatable/equatable.dart';

import '../../../../core/config/app_config.dart';

/// What a table QR resolves to (`GET /public/pay-at-table/qr/{qr_id}`):
/// the business whose menu is shown, the branch and the table orders go to.
class TableSession extends Equatable {
  const TableSession({
    required this.qrId,
    required this.businessReference,
    required this.branchId,
    required this.branchName,
    required this.tableId,
    required this.tableName,
    this.currency = AppConfig.currency,
    this.vatRate = AppConfig.vatRate,
  });

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
