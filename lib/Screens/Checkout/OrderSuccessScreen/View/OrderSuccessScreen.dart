import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Widgets/CustomButton.dart';
import 'package:zood_pay_at_table/Widgets/Reveal.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrderReceiptModel.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/OrderTicket.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/OrderTracker.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/SuccessBadge.dart';

import '../Controller/OrderSuccessController.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({
    super.key,
    required this.qrId,
    required this.receipt,
  });
  static const String routeName = "/OrderSuccessScreen";
  static const String path = "success";

  final String qrId;
  final OrderReceiptModel receipt;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  /// Where the check mark lands in the entrance timeline.
  static const double _checkLanded = 0.34;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..addListener(_maybeBuzz);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _buzzed = false;
  late OrderSuccessController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderSuccessController(refresh, qrId: widget.qrId);
    _controller.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_entrance.isDismissed) {
      if (reduceMotion) {
        _buzzed = true;
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
    }
    if (reduceMotion) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  void _maybeBuzz() {
    if (_buzzed || _entrance.value < _checkLanded) return;
    _buzzed = true;
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: Reveal(
          animation: _entrance,
          begin: 0.75,
          end: 1,
          offset: const Offset(0, 1),
          child: _CtaBar(
            receipt: widget.receipt,
            onPressed: _controller.orderMore,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _Hero(animation: _entrance, receipt: widget.receipt),
              Transform.translate(
                offset: const Offset(0, -56),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Reveal(
                            animation: _entrance,
                            begin: 0.5,
                            end: 0.78,
                            offset: const Offset(0, 0.15),
                            child: OrderTicket(receipt: widget.receipt),
                          ),
                          const SizedBox(height: 16),
                          OrderTracker(
                            receipt: widget.receipt,
                            entrance: _entrance,
                            pulse: _pulse,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.animation, required this.receipt});

  final Animation<double> animation;
  final OrderReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -50,
            top: -10,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 220,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          PositionedDirectional(
            start: -40,
            bottom: 20,
            child: Icon(
              Icons.restaurant_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 84),
                  child: Column(
                    children: [
                      Semantics(
                        liveRegion: true,
                        label: l10n.orderSuccessLabel(receipt.orderNumber),
                        child: ExcludeSemantics(
                          child: SuccessBadge(animation: animation),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Reveal(
                        animation: animation,
                        begin: 0.38,
                        end: 0.6,
                        child: Text(
                          l10n.orderSentTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Reveal(
                        animation: animation,
                        begin: 0.44,
                        end: 0.66,
                        child: Text(
                          l10n.orderSentMessage,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({required this.receipt, required this.onPressed});

  final OrderReceiptModel receipt;
  final VoidCallback onPressed;

  /// The web share sheet is missing on most desktop browsers (share_plus
  /// falls back to `mailto:`), so the web copies the text instead.
  Future<void> _share(BuildContext context) async {
    final l10n = S.of(context);
    final text = l10n.receiptShareText(
      receipt.branchName,
      receipt.tableName,
      receipt.orderNumber,
      CurrencyFormatter.format(receipt.total, currency: receipt.currency),
    );
    if (kIsWeb) {
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: text));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.receiptCopied)));
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: S.of(context).orderSomethingElse,
                      icon: Icons.restaurant_menu_rounded,
                      onPressed: onPressed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Builder(
                    builder: (context) => _ShareButton(
                      tooltip: kIsWeb
                          ? S.of(context).copyReceipt
                          : S.of(context).shareReceipt,
                      icon: kIsWeb
                          ? Icons.copy_rounded
                          : Icons.ios_share_rounded,
                      onPressed: () => _share(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusMd);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primarySoft,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 54,
            child: Icon(icon, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
