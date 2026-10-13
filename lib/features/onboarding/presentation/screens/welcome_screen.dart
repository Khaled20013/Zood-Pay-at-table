import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/deep_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../table_session/domain/entities/table_session.dart';

/// Lets a guest paste a table link or code when they didn't arrive from a
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

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _link = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _link.dispose();
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
    return Scaffold(
      body: SafeArea(
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
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.welcomeTitle,
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.welcomeBody,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        label: l10n.scanQrCode,
                        icon: Icons.qr_code_scanner_rounded,
                        onPressed: () => context.push(AppRoutes.scan),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _link,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _openLink(),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                          hintText: l10n.welcomeLinkHint,
                          prefixIcon: const Icon(Icons.link_rounded),
                          errorText: _error,
                          suffixIcon: IconButton(
                            tooltip: l10n.welcomeOpenTable,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            onPressed: _openLink,
                          ),
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
    );
  }
}
