import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/l10n.dart';
import '../localization/locale_cubit.dart';
import '../theme/app_colors.dart';

/// Pill that switches between English and Arabic. Use [onDark] over photos.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          onTap: () => context.read<LocaleCubit>().toggle(),
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
