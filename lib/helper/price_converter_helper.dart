// price_converter_helper.dart  — SDG ONLY, $ REMOVED everywhere.
import 'package:get/get.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/features/splash/controllers/splash_controller.dart';

class PriceConverterHelper {
  static bool get _ar => Get.locale?.languageCode == 'ar';

  static String convertPrice(double price,
      {double? discount, String? discountType}) {
    if (discount != null) {
      price = discountType == 'percent'
          ? price - (discount / 100) * price
          : price - discount;
    }
    return _sdg(price < 0 ? 0 : price);
  }

  static String balanceWithSymbol({String? balance}) =>
      _sdg((double.tryParse(balance ?? '0') ?? 0).clamp(0, double.infinity));

  static String availableBalance() {
    final b = Get.find<ProfileController>().userInfo?.balance ?? 0.0;
    return _sdg(b > 0 ? b : 0);
  }

  static String newBalanceWithDebit(
      {required double inputBalance, required double charge}) {
    final cur = (Get.find<ProfileController>().userInfo?.balance ?? 0).toDouble();
    return _sdg(cur - inputBalance - charge);
  }

  /// Returns formatted new balance after receiving credit (request money / add money).
  static String newBalanceWithCredit({required double inputBalance}) {
    final cur = (Get.find<ProfileController>().userInfo?.balance ?? 0).toDouble();
    return _sdg(cur + inputBalance);
  }

  /// Returns the currency symbol hint text used in input fields (e.g. "0.00").
  static String balanceInputHint() => '0.00';

  /// Returns amount + charge as a double (used for balance sufficiency check).
  static double balanceWithCharge({required double? amount, required double charge}) {
    return (amount ?? 0) + charge;
  }

  /// Calculates a charge from an amount.
  /// If [isPercent] is true (default), returns amount * charge / 100.
  /// Otherwise treats [charge] as a flat value.
  static double convertCharge({
    required double? amount,
    double? charge,
    bool isPercent = true,
  }) {
    if (charge == null || charge == 0 || amount == null || amount == 0) return 0;
    return isPercent ? (amount * charge) / 100.0 : charge;
  }

  /// Calculates charge value. [type] is 'percent' or 'flat'.
  static double? calculation(double? amount, double? charge, String type) {
    if (amount == null || charge == null) return null;
    return type == 'percent' ? (amount * charge) / 100.0 : charge;
  }

  /// Parses a formatted currency string (e.g. "SDG 1,234.56") to a plain double.
  static double getAmountFromInputFormatter(String text) {
    if (text.isEmpty) return 0;
    // Strip currency symbols and whitespace, keep digits and decimal point
    final clean = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  static String calculateCharge(double amt) {
    try {
      final sc   = Get.find<SplashController>();
      final rate = (sc.configModel?.cashOutChargePercent ?? 0).toDouble();
      return _sdg(amt * rate / 100);
    } catch (_) { return _sdg(0); }
  }

  // ── internal ──────────────────────────────────────────────────────────────
  static String _sdg(double v) {
    final sym = _ar ? 'ج.س' : 'SDG';
    return '$sym ${_num(v.abs())}';
  }

  static String _num(double v) {
    final s = v.toStringAsFixed(2).split('.');
    return '${s[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}.${s[1]}';
  }
}
