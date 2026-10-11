import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language (English / Modern Standard Arabic). Defaults to the device
/// language and remembers the guest's choice.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({SharedPreferences? prefs, Locale? deviceLocale})
    : _prefs = prefs,
      super(
        _initial(prefs, deviceLocale ?? PlatformDispatcher.instance.locale),
      ) {
    Intl.defaultLocale = state.languageCode;
  }

  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');
  static const List<Locale> supportedLocales = [english, arabic];
  static const String _prefsKey = 'app_language';

  final SharedPreferences? _prefs;

  bool get isArabic => state.languageCode == arabic.languageCode;

  static Locale _initial(SharedPreferences? prefs, Locale device) {
    final saved = prefs?.getString(_prefsKey);
    final code = saved ?? device.languageCode;
    return code == arabic.languageCode ? arabic : english;
  }

  void setLocale(Locale locale) {
    final next = locale.languageCode == arabic.languageCode ? arabic : english;
    if (next == state) return;
    Intl.defaultLocale = next.languageCode;
    _prefs?.setString(_prefsKey, next.languageCode);
    emit(next);
  }

  void toggle() => setLocale(isArabic ? english : arabic);
}
