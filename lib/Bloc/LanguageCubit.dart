import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart' as constants;

/// App language (English / Modern Standard Arabic). Defaults to the device
/// language and remembers the guest's choice.
class LanguageCubit extends Cubit<Locale> {
  LanguageCubit({SharedPreferences? prefs, Locale? deviceLocale})
    : _prefs = prefs,
      super(
        _initial(prefs, deviceLocale ?? PlatformDispatcher.instance.locale),
      ) {
    _apply(state);
  }

  static LanguageCubit get(BuildContext context) => BlocProvider.of(context);

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
    _apply(next);
    _prefs?.setString(_prefsKey, next.languageCode);
    emit(next);
  }

  void toggle() => setLocale(isArabic ? english : arabic);

  /// Keeps the globals read by formatters and API headers in sync.
  static void _apply(Locale locale) {
    Intl.defaultLocale = locale.languageCode;
    constants.lang = locale.languageCode;
  }
}
