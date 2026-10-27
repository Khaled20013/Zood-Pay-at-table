import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/Widgets/CustomButton.dart';
import 'package:zood_pay_at_table/Widgets/LanguageToggle.dart';
import 'package:zood_pay_at_table/Screens/Onboarding/Widgets/LandingIllustration.dart';
import 'package:zood_pay_at_table/Widgets/Reveal.dart';

import '../Controller/LandingController.dart';

/// Shown after the splash when the app is opened directly rather than from a
/// table QR link: explains the scan → order → pay flow and leads to the
/// table-link entry screen.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  static const String routeName = "/LandingScreen";
  static const String path = "/";

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late LandingController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = LandingController(refresh);
    _screenController.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_entrance.isDismissed) {
      if (reduceMotion) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
    }
    if (reduceMotion) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: _CtaBar(
          animation: _entrance,
          onStart: _screenController.openWelcome,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final maxWidth = wide ? AppTheme.maxContentWidth : 560.0;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _Hero(
                    entrance: _entrance,
                    loop: _loop,
                    wide: wide,
                    maxWidth: maxWidth,
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Reveal(
                              animation: _entrance,
                              begin: 0.4,
                              end: 0.7,
                              child: Text(
                                S.of(context).landingHowItWorks,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Steps(animation: _entrance, wide: wide),
                            const SizedBox(height: 22),
                            Reveal(
                              animation: _entrance,
                              begin: 0.7,
                              end: 1,
                              child: const _PaymentMethods(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.entrance,
    required this.loop,
    required this.wide,
    required this.maxWidth,
  });

  final Animation<double> entrance;
  final Animation<double> loop;
  final bool wide;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          animation: entrance,
          begin: 0.1,
          end: 0.5,
          child: Text(
            l10n.landingHeadline,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: wide ? 46 : 30,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          animation: entrance,
          begin: 0.2,
          end: 0.6,
          child: Text(
            l10n.landingSubtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );

    final reveal = entrance.drive(
      CurveTween(curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic)),
    );
    final illustration = FadeTransition(
      opacity: reveal,
      child: ScaleTransition(
        scale: reveal.drive(Tween(begin: 0.88, end: 1)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: LandingIllustration(loop: loop),
        ),
      ),
    );

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
            end: -60,
            top: -20,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 260,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    children: [
                      Reveal(
                        animation: entrance,
                        begin: 0,
                        end: 0.35,
                        offset: const Offset(0, -0.4),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/zood_mark.png',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.appTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const LanguageToggle(onDark: true),
                          ],
                        ),
                      ),
                      SizedBox(height: wide ? 40 : 26),
                      if (wide)
                        Row(
                          children: [
                            Expanded(child: copy),
                            const SizedBox(width: 40),
                            illustration,
                          ],
                        )
                      else ...[
                        copy,
                        const SizedBox(height: 16),
                        illustration,
                      ],
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

class _Steps extends StatelessWidget {
  const _Steps({required this.animation, required this.wide});

  final Animation<double> animation;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final steps = [
      (
        Icons.qr_code_scanner_rounded,
        l10n.stepScanTitle,
        l10n.stepScanSubtitle,
      ),
      (Icons.menu_book_rounded, l10n.stepBrowseTitle, l10n.stepBrowseSubtitle),
      (
        Icons.soup_kitchen_rounded,
        l10n.stepKitchenTitle,
        l10n.stepKitchenSubtitle,
      ),
      (Icons.credit_card_rounded, l10n.stepPayTitle, l10n.stepPaySubtitle),
    ];
    final cards = [
      for (var i = 0; i < steps.length; i++)
        Reveal(
          animation: animation,
          begin: 0.45 + i * 0.08,
          end: 0.75 + i * 0.08,
          child: _StepCard(
            number: i + 1,
            icon: steps[i].$1,
            title: steps[i].$2,
            subtitle: steps[i].$3,
            vertical: wide,
          ),
        ),
    ];

    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          cards[i],
        ],
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.vertical,
  });

  final int number;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badge = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        PositionedDirectional(
          top: -6,
          end: -6,
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.warmGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [badge, const SizedBox(height: 14), text],
            )
          : Row(
              children: [
                badge,
                const SizedBox(width: 14),
                Expanded(child: text),
              ],
            ),
    );
  }
}

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final methods = [
      (Icons.credit_score_rounded, l10n.paymentMethodMada),
      (Icons.credit_card_rounded, l10n.paymentMethodCard),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            Text(
              l10n.securePayment,
              style: textTheme.labelLarge?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (icon, label) in methods)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: AppColors.ink),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({required this.animation, required this.onStart});

  final Animation<double> animation;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Reveal(
      animation: animation,
      begin: 0.55,
      end: 1,
      offset: const Offset(0, 1),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: CustomButton(
                  label: l10n.landingStart,
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: onStart,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
