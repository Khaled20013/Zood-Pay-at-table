import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'table_header.dart';

void _openScanner(BuildContext context) => context.push(AppRoutes.scan);

/// Opens the camera to switch to another table.
class ScanTableButton extends StatelessWidget {
  const ScanTableButton({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.scanAnotherTable,
      onPressed: () => _openScanner(context),
      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

/// The current table, tappable to scan another one.
class TableSwitchPill extends StatelessWidget {
  const TableSwitchPill({super.key, required this.tableName});

  final String tableName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final long = TableBadge.isLongName(tableName);
    return Semantics(
      button: true,
      label: '${l10n.tableNumber(tableName)}, ${l10n.scanAnotherTable}',
      excludeSemantics: true,
      child: Tooltip(
        message: l10n.scanAnotherTable,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.darkGradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33060F33),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _openScanner(context),
              borderRadius: BorderRadius.circular(40),
              child: Container(
                height: 42,
                constraints: const BoxConstraints(maxWidth: 170),
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 5, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.table_restaurant_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tableName,
                        maxLines: long ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: long ? 12 : null,
                          height: long ? 1.15 : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
