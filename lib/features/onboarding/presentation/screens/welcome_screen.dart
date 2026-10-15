import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/deep_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/reveal.dart';
import '../../../table_session/domain/entities/table_session.dart';

/// Lets a guest scan or paste a table link when they didn't arrive from a
/// table QR link.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  /// Accepts a full table link or a bare QR id.
  static String? locationForInput(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    if (TableSession.qrIdPattern.hasMatch(value)) return AppRoutes.menu(value);
    final uri = Uri.tryParse(value);
    return uri == null ? null : DeepLinkService.locationFor(uri);
  }

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _link = TextEditingController();
  String? _error;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_entrance.isDismissed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _link.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _openLink() {
    final location = WelcomeScreen.locationForInput(_link.text);
    if (location == null) {
      setState(() => _error = context.l10n.welcomeInvalidLink);
      return;
    }
    FocusScope.of(context).unfocus();
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _Atmosphere()),
            SafeArea(
              child: Stack(
                children: [
                  if (context.canPop())
                    const PositionedDirectional(
                      top: 4,
                      start: 4,
                      child: BackButton(),
                    ),
                  const PositionedDirectional(
                    top: 12,
                    end: 16,
                    child: LanguageToggle(),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Reveal(
                              animation: _entrance,
                              begin: 0,
                              end: 0.35,
                              child: _BrandMark(title: l10n.appTitle),
                            ),
                            const SizedBox(height: 28),
                            Reveal(
                              animation: _entrance,
                              begin: 0.12,
                              end: 0.5,
                              offset: const Offset(0, 0.18),
                              child: const _QrHero(),
                            ),
                            const SizedBox(height: 28),
                            Reveal(
                              animation: _entrance,
                              begin: 0.28,
                              end: 0.62,
                              child: Text(
                                l10n.welcomeTitle,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Reveal(
                              animation: _entrance,
                              begin: 0.38,
                              end: 0.72,
                              child: Text(
                                l10n.welcomeBody,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.inkMuted,
                                  height: 1.55,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Reveal(
                              animation: _entrance,
                              begin: 0.5,
                              end: 0.85,
                              child: CustomButton(
                                label: l10n.scanQrCode,
                                icon: Icons.qr_code_scanner_rounded,
                                onPressed: () => context.push(AppRoutes.scan),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Reveal(
                              animation: _entrance,
                              begin: 0.62,
                              end: 1,
                              child: _PasteLinkField(
                                controller: _link,
                                errorText: _error,
                                hintText: l10n.welcomeLinkHint,
                                openTooltip: l10n.welcomeOpenTable,
                                onChanged: (_) {
                                  if (_error != null) {
                                    setState(() => _error = null);
                                  }
                                },
                                onSubmitted: _openLink,
                                onOpen: _openLink,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Reveal(
                              animation: _entrance,
                              begin: 0.75,
                              end: 1,
                              child: Text(
                                l10n.poweredByZoodPos,
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.inkSubtle,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8EEFB),
              AppColors.background,
              Color(0xFFF7F3EC),
            ],
            stops: [0, 0.45, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _Blob(
                size: 240,
                color: AppColors.primaryBright.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              top: 180,
              left: -90,
              child: _Blob(
                size: 200,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -40,
              child: _Blob(
                size: 160,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/zood_mark.png',
          width: 52,
          height: 52,
          errorBuilder: (_, _, _) => Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.ctaGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QrHero extends StatelessWidget {
  const _QrHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(148, 148),
            painter: _ScanCornersPainter(
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
          const Icon(Icons.qr_code_2_rounded, size: 72, color: Colors.white),
        ],
      ),
    );
  }
}

class _ScanCornersPainter extends CustomPainter {
  _ScanCornersPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const inset = 22.0;
    const arm = 18.0;
    final corners = [
      (
        Offset(inset, inset),
        Offset(inset + arm, inset),
        Offset(inset, inset + arm),
      ),
      (
        Offset(size.width - inset, inset),
        Offset(size.width - inset - arm, inset),
        Offset(size.width - inset, inset + arm),
      ),
      (
        Offset(inset, size.height - inset),
        Offset(inset + arm, size.height - inset),
        Offset(inset, size.height - inset - arm),
      ),
      (
        Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - arm, size.height - inset),
        Offset(size.width - inset, size.height - inset - arm),
      ),
    ];
    for (final (corner, a, b) in corners) {
      canvas.drawLine(corner, a, paint);
      canvas.drawLine(corner, b, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanCornersPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PasteLinkField extends StatelessWidget {
  const _PasteLinkField({
    required this.controller,
    required this.errorText,
    required this.hintText,
    required this.openTooltip,
    required this.onChanged,
    required this.onSubmitted,
    required this.onOpen,
  });

  final TextEditingController controller;
  final String? errorText;
  final String hintText;
  final String openTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.link_rounded,
                size: 16,
                color: AppColors.inkSubtle.withValues(alpha: 0.9),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.link_rounded),
              errorText: errorText,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                tooltip: openTooltip,
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: onOpen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
