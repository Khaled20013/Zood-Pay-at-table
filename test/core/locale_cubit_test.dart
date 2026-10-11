import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zood_pay_at_table/core/localization/locale_cubit.dart';
import 'package:zood_pay_at_table/core/utils/currency_formatter.dart';

void main() {
  tearDown(() => Intl.defaultLocale = null);

  group('LocaleCubit', () {
    test('follows an Arabic device and falls back to English', () {
      expect(
        LocaleCubit(deviceLocale: const Locale('ar', 'SA')).state,
        LocaleCubit.arabic,
      );
      expect(
        LocaleCubit(deviceLocale: const Locale('fr')).state,
        LocaleCubit.english,
      );
    });

    test('toggle switches language, updates Intl and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs: prefs, deviceLocale: const Locale('en'));

      cubit.toggle();

      expect(cubit.state, LocaleCubit.arabic);
      expect(Intl.defaultLocale, 'ar');
      expect(
        LocaleCubit(prefs: prefs, deviceLocale: const Locale('en')).state,
        LocaleCubit.arabic,
      );
    });
  });

  group('CurrencyFormatter in Arabic', () {
    test('puts the riyal symbol after Western digits', () {
      Intl.defaultLocale = 'ar';
      expect(CurrencyFormatter.format(18), '18.00\u00A0ر.س');
      expect(CurrencyFormatter.formatDelta(2), '+ 2.00\u00A0ر.س');
      expect(CurrencyFormatter.formatDelta(0), 'مجانًا');
    });
  });
}
