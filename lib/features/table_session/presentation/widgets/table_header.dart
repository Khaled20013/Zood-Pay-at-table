import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../domain/entities/table_session.dart';

/// Branch + table hero shown on top of the menu.
class TableHeader extends StatelessWidget {
  const TableHeader({super.key, required this.session});

  final TableSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Semantics(
      header: true,
      label: session.displayTitle,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg + 4),
          boxShadow: AppColors.glow(AppColors.primaryDark),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -30,
              bottom: -30,
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 170,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/zood_mark.png',
                        width: 38,
                        height: 38,
                      ),
                      const SizedBox(width: 10),
                      const _OpenPill(),
                      const Spacer(),
                      const LanguageToggle(onDark: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcomeTo,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              session.branchName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TableBadge(tableName: session.tableName),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _GlassChip(
                        icon: Icons.restaurant_rounded,
                        label: l10n.dineIn,
                      ),
                      _GlassChip(
                        icon: Icons.receipt_long_rounded,
                        label: l10n.vatAddedAtCheckout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenPill extends StatelessWidget {
  const _OpenPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF6FF2B5),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0xAA6FF2B5), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.openNow,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TableBadge extends StatelessWidget {
  const TableBadge({super.key, required this.tableName, this.dark = false});

  final String tableName;
  final bool dark;

  /// Short codes like "T5" read big; longer names shrink and may wrap.
  static bool isLongName(String name) => name.characters.length > 6;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fg = dark ? AppColors.primary : AppColors.primaryDark;
    final long = isLongName(tableName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x40060F33),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      constraints: const BoxConstraints(maxWidth: 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.tableLabel,
            maxLines: 1,
            softWrap: false,
            style: textTheme.labelSmall?.copyWith(
              color: fg.withValues(alpha: 0.75),
              letterSpacing: Directionality.of(context) == TextDirection.rtl
                  ? 0
                  : 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            tableName,
            maxLines: long ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: (long ? textTheme.titleSmall : textTheme.titleLarge)
                ?.copyWith(
                  color: fg,
                  height: long ? 1.15 : 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
