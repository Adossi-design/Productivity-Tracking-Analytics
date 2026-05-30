import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app language preference (English/French) with persistence
class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale_lang';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_key) ?? 'en';
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggle() async {
    _locale = _locale.languageCode == 'en'
        ? const Locale('fr')
        : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _locale.languageCode);
    notifyListeners();
  }
}
