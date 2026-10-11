import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/routing/deep_link_service.dart';
import 'package:zood_pay_at_table/core/utils/currency_formatter.dart';
import 'package:zood_pay_at_table/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  group('DeepLinkService.locationFor', () {
    test('maps the QR link on control.zood.ai', () {
      expect(
        DeepLinkService.locationFor(
          Uri.parse(
            'https://control.zood.ai/pay-at-table/40de86d3987ef0a98768ad61/menu',
          ),
        ),
        '/pay-at-table/40de86d3987ef0a98768ad61/menu',
      );
    });

    test('maps the zoodpay:// custom scheme', () {
      expect(
        DeepLinkService.locationFor(
          Uri.parse('zoodpay://pay-at-table/40de86d3987ef0a98768ad61/menu'),
        ),
        '/pay-at-table/40de86d3987ef0a98768ad61/menu',
      );
    });

    test('ignores unrelated links', () {
      expect(
        DeepLinkService.locationFor(Uri.parse('https://example.com/about')),
        isNull,
      );
    });
  });

  group('CurrencyFormatter', () {
    test('formats SAR amounts with two decimals', () {
      expect(CurrencyFormatter.format(18), 'SAR\u00A018.00');
      expect(CurrencyFormatter.formatDelta(2), '+ SAR\u00A02.00');
      expect(CurrencyFormatter.formatDelta(0), 'Free');
    });
  });

  group('WelcomeScreen.locationForInput', () {
    test('accepts a full link or a bare table code', () {
      const location = '/pay-at-table/40de86d3987ef0a98768ad61/menu';
      expect(
        WelcomeScreen.locationForInput(
          ' https://control.zood.ai/pay-at-table/40de86d3987ef0a98768ad61/menu ',
        ),
        location,
      );
      expect(
        WelcomeScreen.locationForInput(' 40de86d3987ef0a98768ad61 '),
        location,
      );
      expect(WelcomeScreen.locationForInput('not a code!'), isNull);
      expect(WelcomeScreen.locationForInput('https://example.com/x'), isNull);
    });
  });
}
