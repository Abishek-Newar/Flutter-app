import 'package:naqde_user/common/models/language_model.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationController extends GetxController {
  final SharedPreferences sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    loadCurrentLanguage();
  }



  // Default: Arabic (languages[0] = ar after app_constants change)
  Locale _locale = const Locale('ar', 'SA');
  bool _isLtr = false;  // Arabic is RTL by default
  List<LanguageModel> _languages = [];

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  List<LanguageModel> get languages => _languages;

  void setLanguage(Locale locale) {
    _locale = locale;
    _isLtr = _locale.languageCode != 'ar';
    saveLanguage(_locale);
    Get.updateLocale(locale);
  }

  Future<int> loadCurrentLanguage() async {
    // If no language saved yet, default to Arabic
    final savedLang    = sharedPreferences.getString(AppConstants.languageCode) ?? 'ar';
    final savedCountry = sharedPreferences.getString(AppConstants.customerCountryCode) ?? 'SA';
    _locale = Locale(savedLang, savedCountry);
    _isLtr  = _locale.languageCode != 'ar';

    for(int index = 0; index<AppConstants.languages.length; index++) {
      if(AppConstants.languages[index].languageCode == _locale.languageCode) {
        _selectedIndex = index;
        break;
      }
    }
    _languages = [];
    _languages.addAll(AppConstants.languages);


    return _selectedIndex;
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.customerCountryCode, locale.countryCode!);
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectIndex(int index, {isUpdate = true}) {
    _selectedIndex = index;
   if(isUpdate){
     update();
   }
  }

  void searchLanguage(String query) {
    if (query.isEmpty) {
      _languages  = [];
      _languages = AppConstants.languages;
    } else {
      _selectedIndex = -1;
      _languages = [];
      for (var language in AppConstants.languages) {
        if (language.languageName!.toLowerCase().contains(query.toLowerCase())) {
          _languages.add(language);
        }
      }
    }
    update();
  }
}