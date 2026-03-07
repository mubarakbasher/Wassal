import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';

  Locale _locale;

  LocaleProvider(this._locale);

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _persist(locale.languageCode);
    notifyListeners();
  }

  Future<void> _persist(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  static Future<LocaleProvider> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    if (saved != null) {
      return LocaleProvider(Locale(saved));
    }

    final deviceLang = Platform.localeName.split('_').first;
    final locale = deviceLang == 'ar' ? const Locale('ar') : const Locale('en');
    return LocaleProvider(locale);
  }
}
