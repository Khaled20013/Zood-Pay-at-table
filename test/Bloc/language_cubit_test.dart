import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zood_pay_at_table/Bloc/LanguageCubit.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';

void main() {
  tearDown(() => Intl.defaultLocale = null);

  group('LanguageCubit', () {
    test('follows an Arabic device and falls back to English', () {
      expect(
        LanguageCubit(deviceLocale: const Locale('ar', 'SA')).state,
        LanguageCubit.arabic,
      );
      expect(
        LanguageCubit(deviceLocale: const Locale('fr')).state,
        LanguageCubit.english,
      );
    });

    test('toggle switches language, updates Intl and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LanguageCubit(prefs: prefs, deviceLocale: const Locale('en'));

      cubit.toggle();

      expect(cubit.state, LanguageCubit.arabic);
      expect(Intl.defaultLocale, 'ar');
      expect(
        LanguageCubit(prefs: prefs, deviceLocale: const Locale('en')).state,
        LanguageCubit.arabic,
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
