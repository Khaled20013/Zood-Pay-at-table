import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/reveal.dart';
import '../../domain/entities/order_receipt.dart';
import '../widgets/order_ticket.dart';
import '../widgets/order_tracker.dart';
import '../widgets/success_badge.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({
    super.key,
    required this.qrId,
    required this.receipt,
  });

  final String qrId;
  final OrderReceipt receipt;

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
            onPressed: () => context.go(AppRoutes.menu(widget.qrId)),
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
  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
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
  const _CtaBar({required this.onPressed});

  final VoidCallback onPressed;

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
              child: CustomButton(
                label: context.l10n.orderSomethingElse,
                icon: Icons.restaurant_menu_rounded,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
