import 'package:flutter/material.dart';

/// Controls the current app locale for the Add Funds feature.
/// Drop into your Provider/ChangeNotifier tree.
class AddFundsLocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void toggle() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void setArabic() => setLocale(const Locale('ar'));
  void setEnglish() => setLocale(const Locale('en'));
}
