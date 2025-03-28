import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends GetxService {
  static const String LANGUAGE_CODE = 'languageCode';
  static const String COUNTRY_CODE = 'countryCode';

  // Default locale
  static const Locale DEFAULT_LOCALE = Locale('fr', 'FR');

  // Load saved locale from SharedPreferences
  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(LANGUAGE_CODE) ?? DEFAULT_LOCALE.languageCode;
    String countryCode = prefs.getString(COUNTRY_CODE) ?? DEFAULT_LOCALE.countryCode ?? '';

    return Locale(languageCode, countryCode);
  }

  // Save locale to SharedPreferences
  Future<void> saveLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, locale.languageCode);
    await prefs.setString(COUNTRY_CODE, locale.countryCode ?? '');
  }

  // Change app locale
  void changeLocale(String languageCode, String countryCode) {
    Locale locale = Locale(languageCode, countryCode);
    saveLocale(locale);
    Get.updateLocale(locale);
  }
}
