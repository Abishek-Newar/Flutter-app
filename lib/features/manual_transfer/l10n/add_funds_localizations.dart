import 'package:flutter/material.dart';

/// Add Funds (Manual Bank Transfer) Localizations
/// Supports Arabic (ar) and English (en) with RTL/LTR layout
/// Currency: SDG (Sudanese Pound / جنيه سوداني)
class AddFundsL10n {
  final Locale locale;

  AddFundsL10n(this.locale);

  static AddFundsL10n of(BuildContext context) {
    final l = Localizations.of<AddFundsL10n>(context, AddFundsL10n);
    return l ?? AddFundsL10n(const Locale('en'));
  }

  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  // ── Currency ─────────────────────────────────────────────────────────────
  String formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return isArabic ? 'ج.س $formatted' : 'SDG $formatted';
  }

  String get currencyCode => isArabic ? 'ج.س' : 'SDG';
  String get currencyName =>
      isArabic ? 'جنيه سوداني' : 'Sudanese Pound';

  // ── AppBar / Navigation ───────────────────────────────────────────────────
  String get addFundsTitle => isArabic ? 'إضافة رصيد' : 'Add Funds';
  String get selectBankTitle => isArabic ? 'اختر البنك' : 'Select Bank';
  String get bankDetailsTitle => isArabic ? 'تفاصيل البنك' : 'Bank Details';
  String get submitTransferTitle =>
      isArabic ? 'إرسال إثبات التحويل' : 'Submit Transfer Proof';
  String get transferHistoryTitle =>
      isArabic ? 'سجل التحويلات' : 'Transfer History';
  String get toggleLanguage => isArabic ? 'English' : 'عربي';

  // ── Bank List Screen ──────────────────────────────────────────────────────
  String get availableBanks =>
      isArabic ? 'البنوك المتاحة' : 'Available Banks';
  String get noBanksAvailable =>
      isArabic ? 'لا توجد بنوك متاحة حالياً' : 'No banks available right now';
  String get loadingBanks =>
      isArabic ? 'جارٍ تحميل البنوك...' : 'Loading banks...';
  String get selectBankHint =>
      isArabic ? 'اختر بنكاً لإتمام التحويل' : 'Select a bank to add funds';
  String get bankLoadError =>
      isArabic ? 'خطأ في تحميل البنوك' : 'Error loading banks';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get viewHistory =>
      isArabic ? 'عرض السجل' : 'View History';

  // ── Bank Details Screen ───────────────────────────────────────────────────
  String get bankName => isArabic ? 'اسم البنك' : 'Bank Name';
  String get accountName => isArabic ? 'اسم الحساب' : 'Account Name';
  String get accountNumber => isArabic ? 'رقم الحساب' : 'Account Number';
  String get ibanLabel => isArabic ? 'رقم IBAN' : 'IBAN';
  String get importantInstructions =>
      isArabic ? 'تعليمات مهمة:' : 'Important Instructions:';
  String get steps => isArabic ? 'الخطوات:' : 'Steps:';
  String get step1 =>
      isArabic ? 'افتح تطبيق البنك الخاص بك' : 'Open your banking app';
  String get step2 =>
      isArabic ? 'حوّل إلى بيانات الحساب أعلاه' : 'Transfer to the account details above';
  String get step3 =>
      isArabic ? 'أضف المرجع: CC-{معرّفك}' : 'Include reference: CC-{YourUserID}';
  String get step4 =>
      isArabic ? 'احفظ إيصال التحويل' : 'Save the transfer receipt';
  String get iHaveTransferred =>
      isArabic ? 'لقد أجريت التحويل' : 'I Have Transferred';
  String get copied => isArabic ? 'تم النسخ!' : 'Copied!';
  String get tapToCopy => isArabic ? 'اضغط للنسخ' : 'Tap to copy';

  // ── Submit Transfer Screen ────────────────────────────────────────────────
  String bankLabel(String name) =>
      isArabic ? 'البنك: $name' : 'Bank: $name';
  String get amountLabel => isArabic ? 'المبلغ' : 'Amount';
  String get amountHint =>
      isArabic ? 'أدخل المبلغ المحوّل' : 'Enter transferred amount';
  String get amountSuffix => isArabic ? 'ج.س' : 'SDG';
  String get referenceLabel =>
      isArabic ? 'رقم مرجع العملية' : 'Transaction Reference';
  String get referenceHint =>
      isArabic ? 'أدخل رقم مرجع البنك' : 'Enter bank reference number';
  String get senderNameLabel =>
      isArabic ? 'اسم المُرسِل (اختياري)' : 'Sender Name (Optional)';
  String get uploadScreenshot =>
      isArabic ? 'رفع صورة إيصال التحويل:' : 'Upload Transfer Screenshot:';
  String get tapToUpload =>
      isArabic ? 'اضغط لرفع الإيصال' : 'Tap to upload screenshot';
  String get changeImage =>
      isArabic ? 'اضغط لتغيير الصورة' : 'Tap to change image';
  String get submitRequest =>
      isArabic ? 'إرسال الطلب' : 'Submit Request';
  String get submitting =>
      isArabic ? 'جارٍ الإرسال...' : 'Submitting...';
  String get minAmount =>
      isArabic ? 'الحد الأدنى 5,000 ج.س' : 'Minimum 5,000 SDG';
  String get maxAmount =>
      isArabic ? 'الحد الأقصى 500,000 ج.س' : 'Maximum 500,000 SDG';
  String get invalidAmount =>
      isArabic ? 'مبلغ غير صالح' : 'Invalid amount';
  String get requiredField => isArabic ? 'هذا الحقل مطلوب' : 'Required';
  String get screenshotRequired =>
      isArabic ? 'يرجى رفع صورة إيصال التحويل' : 'Please upload transfer screenshot';

  // ── Success Dialog ────────────────────────────────────────────────────────
  String get successTitle => isArabic ? 'تم الإرسال بنجاح' : 'Request Submitted';
  String successBody(String requestId) => isArabic
      ? 'تم استلام طلبك بنجاح!\nرقم الطلب: $requestId\nسيتم مراجعته خلال 24 ساعة.'
      : 'Your request has been received!\nRequest ID: $requestId\nIt will be reviewed within 24 hours.';
  String get ok => isArabic ? 'حسناً' : 'OK';

  // ── Transfer History Screen ───────────────────────────────────────────────
  String get noTransfers =>
      isArabic ? 'لا توجد تحويلات بعد' : 'No transfers yet';
  String get unknownBank => isArabic ? 'بنك غير معروف' : 'Unknown Bank';
  String refLabel(String ref) =>
      isArabic ? 'المرجع: $ref' : 'Ref: $ref';
  String get refreshing => isArabic ? 'جارٍ التحديث...' : 'Refreshing...';

  // ── Status Labels ─────────────────────────────────────────────────────────
  String statusLabel(String status) {
    if (isArabic) {
      switch (status) {
        case 'pending': return 'قيد المراجعة';
        case 'approved': return 'مُوافق عليه';
        case 'rejected': return 'مرفوض';
        case 'expired': return 'منتهي';
        default: return status;
      }
    } else {
      switch (status) {
        case 'pending': return 'PENDING';
        case 'approved': return 'APPROVED';
        case 'rejected': return 'REJECTED';
        case 'expired': return 'EXPIRED';
        default: return status.toUpperCase();
      }
    }
  }

  // ── Info Banner ───────────────────────────────────────────────────────────
  String get infoBannerTitle =>
      isArabic ? 'كيف يعمل إضافة الرصيد؟' : 'How does adding funds work?';
  String get infoBannerBody => isArabic
      ? '١. اختر بنكاً وحوّل المبلغ المطلوب\n'
        '٢. أرسل إيصال التحويل مع رقم المرجع\n'
        '٣. سيتم مراجعة طلبك وإضافة الرصيد خلال 24 ساعة'
      : '1. Select a bank and transfer the desired amount\n'
        '2. Submit the transfer receipt with reference number\n'
        '3. Your request will be reviewed and funds added within 24 hours';

  // ── Error Messages ────────────────────────────────────────────────────────
  String get genericError =>
      isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';
  String errorMessage(String e) =>
      isArabic ? 'خطأ: $e' : 'Error: $e';
  String get networkError =>
      isArabic ? 'خطأ في الاتصال بالشبكة' : 'Network connection error';
  String get sessionExpired =>
      isArabic ? 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً'
               : 'Session expired, please login again';
}

// ── Delegate ─────────────────────────────────────────────────────────────────
class AddFundsL10nDelegate extends LocalizationsDelegate<AddFundsL10n> {
  const AddFundsL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AddFundsL10n> load(Locale locale) async => AddFundsL10n(locale);

  @override
  bool shouldReload(AddFundsL10nDelegate old) => false;
}
