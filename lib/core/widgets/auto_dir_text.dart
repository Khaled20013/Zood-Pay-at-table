import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

final RegExp _rtlChar = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');
final RegExp _ltrChar = RegExp(r'[A-Za-z\u00C0-\u024F]');

/// Direction of the first strong character, or null when there is none.
TextDirection? contentDirectionOf(String text) {
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (_rtlChar.hasMatch(char)) return TextDirection.rtl;
    if (_ltrChar.hasMatch(char)) return TextDirection.ltr;
  }
  return null;
}

/// Text laid out in its own direction (so English names keep their
/// punctuation inside an Arabic screen) but aligned to the screen's start.
/// Matches of [highlight] are marked, case-insensitively.
class AutoDirText extends StatelessWidget {
  const AutoDirText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.highlight = '',
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final screenDirection = Directionality.of(context);
    return Text.rich(
      TextSpan(children: _spans()),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: contentDirectionOf(text) ?? screenDirection,
      textAlign: screenDirection == TextDirection.rtl
          ? TextAlign.right
          : TextAlign.left,
    );
  }

  List<InlineSpan> _spans() {
    final query = highlight.trim().toLowerCase();
    final lower = text.toLowerCase();
    // Indices below assume lowercasing keeps the length.
    if (query.isEmpty || lower.length != text.length) {
      return [TextSpan(text: text)];
    }
    final spans = <InlineSpan>[];
    var start = 0;
    while (true) {
      final index = lower.indexOf(query, start);
      if (index < 0) break;
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: AppColors.accentSoft,
            color: AppColors.accentDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      start = index + query.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }
}
