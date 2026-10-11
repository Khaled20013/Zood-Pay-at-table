import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order_receipt.dart';

/// The receipt as a kitchen ticket: punched notches under the order number
/// and a torn, zig-zag bottom edge.
class OrderTicket extends StatelessWidget {
  const OrderTicket({super.key, required this.receipt});

  static const double _headerHeight = 112;

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    String money(double v) =>
        CurrencyFormatter.format(v, currency: receipt.currency);
    return PhysicalShape(
      clipper: const _TicketClipper(notchY: _headerHeight),
      color: AppColors.surface,
      elevation: 10,
      shadowColor: const Color(0x40060F33),
      child: Column(
        children: [
          SizedBox(
            height: _headerHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.orderLabel,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '#${receipt.orderNumber}',
                            textDirection: TextDirection.ltr,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TableBadge(tableName: receipt.tableName),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 2,
              width: double.infinity,
              child: CustomPaint(painter: _DashedLinePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            child: Column(
              children: [
                _TicketRow(
                  icon: Icons.receipt_rounded,
                  label: l10n.subtotal,
                  value: money(receipt.subtotal),
                ),
                _TicketRow(
                  icon: Icons.percent_rounded,
                  label: l10n.vat,
                  value: money(receipt.taxes),
                ),
                _TicketRow(
                  icon: Icons.payments_rounded,
                  label: l10n.paid,
                  value: money(receipt.total),
                  emphasize: true,
                ),
                if (receipt.cardLast4.isNotEmpty)
                  _TicketRow(
                    icon: Icons.credit_card_rounded,
                    label: l10n.method,
                    value: l10n.cardEndingIn(receipt.cardLast4),
                  ),
                if (receipt.reference.isNotEmpty)
                  _TicketRow(
                    icon: Icons.tag_rounded,
                    label: l10n.reference,
                    value: receipt.reference,
                  ),
                _TicketRow(
                  icon: Icons.schedule_rounded,
                  label: l10n.time,
                  value: DateFormat(
                    'd MMM, h:mm a',
                    locale,
                  ).format(receipt.paidAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableBadge extends StatelessWidget {
  const _TableBadge({required this.tableName});

  final String tableName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 120),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.tableLabel,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tableName,
              maxLines: 1,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkSubtle),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.titleMedium?.copyWith(
                fontSize: emphasize ? 17 : 15,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 7.0;
    const gap = 5.0;
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({required this.notchY});

  static const double _radius = 20;
  static const double _notch = 12;
  static const double _tooth = 8;
  static const double _toothWidth = 16;

  final double notchY;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const corner = Radius.circular(_radius);
    const notch = Radius.circular(_notch);
    final path = Path()
      ..moveTo(0, _radius)
      ..arcToPoint(const Offset(_radius, 0), radius: corner)
      ..lineTo(w - _radius, 0)
      ..arcToPoint(Offset(w, _radius), radius: corner)
      ..lineTo(w, notchY - _notch)
      ..arcToPoint(Offset(w, notchY + _notch), radius: notch, clockwise: false)
      ..lineTo(w, h - _tooth);
    final teeth = (w / _toothWidth).floor();
    final step = w / teeth;
    for (var i = 0; i < teeth; i++) {
      final x = w - step * i;
      path
        ..lineTo(x - step / 2, h)
        ..lineTo(x - step, h - _tooth);
    }
    return path
      ..lineTo(0, notchY + _notch)
      ..arcToPoint(Offset(0, notchY - _notch), radius: notch, clockwise: false)
      ..close();
  }

  @override
  bool shouldReclip(_TicketClipper old) => old.notchY != notchY;
}
