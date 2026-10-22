import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../domain/entities/card_brand.dart';
import '../../domain/entities/card_details.dart';
import 'card_form.dart';

/// Live card mirroring the checkout form: fills in as the guest types,
/// recolours for the detected network and flips to its back while the CVC
/// field is focused.
class CreditCardPreview extends StatelessWidget {
  const CreditCardPreview({super.key, required this.controllers});

  final CardFormControllers controllers;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      // Cards read left-to-right in Arabic too.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AspectRatio(
              aspectRatio: 1.586,
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  controllers.number,
                  controllers.holderName,
                  controllers.expiry,
                  controllers.cvc,
                  controllers.cvcFocus,
                ]),
                builder: (context, _) {
                  final digits = CardDetails.digitsOnly(
                    controllers.number.text,
                  );
                  final brand = CardBrand.of(digits);
                  return TweenAnimationBuilder<double>(
                    tween: Tween(
                      end: controllers.cvcFocus.hasFocus ? math.pi : 0,
                    ),
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 650),
                    curve: Curves.easeInOutCubic,
                    builder: (context, angle, _) {
                      final showBack = angle > math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(angle),
                        child: showBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: _CardBack(
                                  brand: brand,
                                  cvcLength: controllers.cvc.text.length,
                                ),
                              )
                            : _CardFront(
                                brand: brand,
                                digits: digits,
                                holderName: controllers.holderName.text,
                                expiry: controllers.expiry.text,
                                reduceMotion: reduceMotion,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Color> _gradientFor(CardBrand brand) => switch (brand) {
  CardBrand.visa => const [
    Color(0xFF0C1B4A),
    Color(0xFF004FEE),
    Color(0xFF4C7AF5),
  ],
  CardBrand.mastercard => const [
    Color(0xFF16161A),
    Color(0xFF34343C),
    Color(0xFF5A3A22),
  ],
  CardBrand.mada => const [
    Color(0xFF0B3550),
    Color(0xFF14607A),
    Color(0xFF1E9C7E),
  ],
  CardBrand.amex => const [
    Color(0xFF0A4F73),
    Color(0xFF117FB0),
    Color(0xFF3BB4E0),
  ],
  CardBrand.unknown => const [
    Color(0xFF0C1B4A),
    Color(0xFF0039C7),
    Color(0xFF4C7AF5),
  ],
};

/// Rounded gradient body shared by both faces; the colours animate when the
/// detected brand changes.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.brand, required this.child});

  final CardBrand brand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = _gradientFor(brand);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[1].withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -60,
            top: -80,
            child: _Glow(size: 220, opacity: 0.10),
          ),
          Positioned(
            left: -70,
            bottom: -110,
            child: _Glow(size: 260, opacity: 0.07),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.brand,
    required this.digits,
    required this.holderName,
    required this.expiry,
    required this.reduceMotion,
  });

  final CardBrand brand;
  final String digits;
  final String holderName;
  final String expiry;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      brand: brand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final labelStyle = TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: w * 0.03,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          );
          final valueStyle = TextStyle(
            color: Colors.white,
            fontSize: w * 0.044,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          );
          final name = holderName.trim().toUpperCase();
          return Stack(
            children: [
              // A sheen sweeps across the card whenever the brand changes.
              Positioned.fill(
                child: _Sheen(key: ValueKey(brand), enabled: !reduceMotion),
              ),
              Padding(
                padding: EdgeInsets.all(w * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Chip(width: w * 0.13),
                        SizedBox(width: w * 0.03),
                        Icon(
                          Icons.contactless_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: w * 0.075,
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                          child: CardBrandMark(
                            key: ValueKey(brand),
                            brand: brand,
                            height: w * 0.085,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _CardNumber(digits: digits, fontSize: w * 0.066),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CARD HOLDER', style: labelStyle),
                              const SizedBox(height: 3),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: Text(
                                  name.isEmpty ? 'FULL NAME' : name,
                                  key: ValueKey(name.isEmpty),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: valueStyle.copyWith(
                                    color: name.isEmpty
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: w * 0.04),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EXPIRES', style: labelStyle),
                            const SizedBox(height: 3),
                            Text(
                              _expiryText(expiry),
                              style: valueStyle.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Typed digits over an `MM/YY` template.
  static String _expiryText(String raw) {
    final digits = CardDetails.digitsOnly(raw);
    const template = 'MMYY';
    final filled = digits + template.substring(digits.length.clamp(0, 4));
    return '${filled.substring(0, 2)}/${filled.substring(2, 4)}';
  }
}

/// 16 slots (more for longer numbers) in groups of 4; each typed digit
/// slides into its slot.
class _CardNumber extends StatelessWidget {
  const _CardNumber({required this.digits, required this.fontSize});

  final String digits;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final slots = math.max(16, digits.length);
    final style = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      shadows: const [
        Shadow(color: Color(0x40000000), offset: Offset(0, 1), blurRadius: 2),
      ],
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (var i = 0; i < slots; i++) ...[
            if (i > 0 && i % 4 == 0) SizedBox(width: fontSize * 0.7),
            SizedBox(
              width: fontSize * 0.68,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: i < digits.length
                    ? Text(
                        digits[i],
                        key: ValueKey('$i${digits[i]}'),
                        textAlign: TextAlign.center,
                        style: style,
                      )
                    : SizedBox(
                        key: ValueKey('$i'),
                        height: fontSize * 1.5,
                        child: Center(
                          child: _Dot(
                            size: fontSize * 0.22,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.brand, required this.cvcLength});

  final CardBrand brand;
  final int cvcLength;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      brand: brand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: w * 0.08),
              Container(height: w * 0.13, color: const Color(0xE6111111)),
              SizedBox(height: w * 0.06),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.065),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: w * 0.11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF2F2F2), Color(0xFFDADADA)],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: w * 0.2,
                      height: w * 0.11,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFFFB020),
                          width: 2,
                        ),
                      ),
                      child: cvcLength == 0
                          ? Text(
                              'CVC',
                              style: TextStyle(
                                color: const Color(0xFF9AA0AE),
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            )
                          : Row(
                              key: ValueKey('cvc-dots-$cvcLength'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < cvcLength; i++)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.006,
                                    ),
                                    child: _Dot(
                                      size: w * 0.022,
                                      color: const Color(0xFF111111),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(w * 0.065, 0, w * 0.065, w * 0.06),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.cardCvcBackHint,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: w * 0.028,
                        ),
                      ),
                    ),
                    CardBrandMark(brand: brand, height: w * 0.07),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// EMV chip.
class _Chip extends StatelessWidget {
  const _Chip({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7E3A3), Color(0xFFD4AF5A), Color(0xFFF2D58A)],
        ),
      ),
      child: CustomPaint(painter: _ChipLinesPainter()),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x66896A22)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    canvas
      ..drawLine(Offset(0, h * 0.35), Offset(w, h * 0.35), paint)
      ..drawLine(Offset(0, h * 0.65), Offset(w, h * 0.65), paint)
      ..drawLine(Offset(w * 0.38, 0), Offset(w * 0.38, h), paint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w / 2, h / 2),
            width: w * 0.34,
            height: h * 0.4,
          ),
          Radius.circular(w * 0.06),
        ),
        paint,
      );
  }

  @override
  bool shouldRepaint(_ChipLinesPainter old) => false;
}

/// One diagonal light sweep, played once when created.
class _Sheen extends StatelessWidget {
  const _Sheen({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.2, end: 1.6),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeInOut,
        builder: (context, t, _) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(t - 0.6, -1),
              end: Alignment(t + 0.6, 1),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Network logo drawn in code (no image assets).
class CardBrandMark extends StatelessWidget {
  const CardBrandMark({
    super.key,
    required this.brand,
    required this.height,
    this.onLight = false,
  });

  final CardBrand brand;
  final double height;

  /// Dark ink for use on light backgrounds (e.g. inside the text field).
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final ink = onLight ? const Color(0xFF1A1F71) : Colors.white;
    return SizedBox(
      height: height,
      child: switch (brand) {
        CardBrand.visa => FittedBox(
          child: Text(
            'VISA',
            style: TextStyle(
              color: ink,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1,
            ),
          ),
        ),
        CardBrand.mastercard => AspectRatio(
          aspectRatio: 1.6,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _Circle(height, const Color(0xFFEB001B)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _Circle(
                  height,
                  const Color(0xFFF79E1B).withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        CardBrand.mada => FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 7,
                    color: const Color(0xFF84BD00),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 26,
                    height: 7,
                    color: const Color(0xFF259BD6),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                'mada',
                style: TextStyle(
                  color: ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        CardBrand.amex => FittedBox(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: ink, width: 3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'AMEX',
              style: TextStyle(
                color: ink,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        CardBrand.unknown => FittedBox(
          child: Icon(
            Icons.credit_card_rounded,
            color: ink.withValues(alpha: onLight ? 0.4 : 0.8),
            size: 40,
          ),
        ),
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
