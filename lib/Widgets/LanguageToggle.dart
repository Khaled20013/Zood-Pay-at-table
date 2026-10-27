import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Bloc/LanguageCubit.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// Pill that switches between English and Arabic. Use [onDark] over photos.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final foreground = onDark ? Colors.white : AppColors.primaryDark;
    return Tooltip(
      message: l10n.switchLanguageTooltip,
      child: Material(
        color: onDark
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.primary.withValues(alpha: 0.08),
        shape: StadiumBorder(
          side: BorderSide(
            color: onDark
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => context.read<LanguageCubit>().toggle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate_rounded, size: 16, color: foreground),
                const SizedBox(width: 6),
                Text(
                  l10n.switchLanguageLabel,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
