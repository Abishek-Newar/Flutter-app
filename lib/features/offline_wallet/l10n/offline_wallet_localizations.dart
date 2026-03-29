import 'package:flutter/material.dart';

/// CircleCash — Offline Wallet Localizations
/// Supports Arabic (ar) and English (en) with SDG currency.
class OfflineWalletLocalizations {
  final Locale locale;
  const OfflineWalletLocalizations(this.locale);

  static OfflineWalletLocalizations of(BuildContext context) {
    return Localizations.of<OfflineWalletLocalizations>(
            context, OfflineWalletLocalizations) ??
        const OfflineWalletLocalizations(Locale('en'));
  }

  static const delegate = _OfflineWalletLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ── Currency ────────────────────────────────────────────────────────────────

  String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    if (isArabic) {
      return 'ج.س $formatted';
    }
    return 'SDG $formatted';
  }

  String get currencyName => isArabic ? 'جنيه سوداني' : 'Sudanese Pound';
  String get currencyCode => 'SDG';

  // ── App Bar & General ───────────────────────────────────────────────────────

  String get offlineWalletTitle =>
      isArabic ? 'محفظة سيركل كاش' : 'CircleCash Offline Wallet';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get done => isArabic ? 'تم' : 'Done';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'تم بنجاح' : 'Success';
  String get warning => isArabic ? 'تحذير' : 'Warning';
  String get noData => isArabic ? 'لا توجد بيانات' : 'No data available';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';

  // ── Balance Card ────────────────────────────────────────────────────────────

  String get confirmedBalance => isArabic ? 'الرصيد المؤكد' : 'Confirmed Balance';
  String get pendingBalance => isArabic ? 'الرصيد المعلق' : 'Pending Balance';
  String get spendableBalance => isArabic ? 'الرصيد المتاح' : 'Spendable Balance';
  String get walletFrozen => isArabic ? 'المحفظة مجمدة' : 'Wallet Frozen';
  String get walletFrozenMessage =>
      isArabic ? 'تم تجميد محفظتك لأسباب أمنية' : 'Your wallet is frozen for security reasons';
  String get offlineMode => isArabic ? 'وضع عدم الاتصال' : 'Offline Mode';

  // ── Quick Actions ───────────────────────────────────────────────────────────

  String get scanQR => isArabic ? 'مسح QR' : 'Scan QR';
  String get showQR => isArabic ? 'عرض QR' : 'Show QR';
  String get bluetooth => isArabic ? 'بلوتوث' : 'Bluetooth';
  String get nfc => isArabic ? 'NFC' : 'NFC';
  String get sendViaSMS => isArabic ? 'إرسال عبر SMS' : 'Send via SMS';
  String get send => isArabic ? 'إرسال' : 'Send';
  String get receive => isArabic ? 'استقبال' : 'Receive';

  // ── Send / Payment ──────────────────────────────────────────────────────────

  String get sendPayment => isArabic ? 'إرسال دفعة' : 'Send Payment';
  String get recipientWalletId => isArabic ? 'معرف محفظة المستلم' : 'Recipient Wallet ID';
  String get amount => isArabic ? 'المبلغ' : 'Amount';
  String get amountHint => isArabic ? 'أدخل المبلغ بالجنيه السوداني' : 'Enter amount in SDG';
  String get note => isArabic ? 'ملاحظة (اختياري)' : 'Note (optional)';
  String get pin => isArabic ? 'رمز PIN' : 'PIN';
  String get enterPin => isArabic ? 'أدخل رمز PIN' : 'Enter your PIN';
  String get confirmPin => isArabic ? 'تأكيد رمز PIN' : 'Confirm PIN';
  String get transmissionMethod => isArabic ? 'طريقة الإرسال' : 'Transmission Method';
  String get sendOnline => isArabic ? 'إرسال عبر الإنترنت' : 'Send Online';
  String get sendBluetooth => isArabic ? 'إرسال عبر بلوتوث' : 'Send via Bluetooth';
  String get sendNFC => isArabic ? 'إرسال عبر NFC' : 'Send via NFC';
  String get sendSMS => isArabic ? 'إرسال عبر SMS' : 'Send via SMS';
  String get transactionPending =>
      isArabic ? 'المعاملة معلقة - ستُزامن عند الاتصال' : 'Transaction pending — will sync when connected';
  String get transactionSyncing => isArabic ? 'جاري المزامنة...' : 'Syncing...';
  String get holdDeviceNearRecipient =>
      isArabic ? 'اقترب من هاتف المستلم لإتمام العملية' : 'Hold device near recipient to complete';

  // ── Validation ──────────────────────────────────────────────────────────────

  String get requiredField => isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
  String get invalidAmount => isArabic ? 'مبلغ غير صالح' : 'Invalid amount';
  String minimumAmount(double min) =>
      isArabic ? 'الحد الأدنى ${formatCurrency(min)}' : 'Minimum ${formatCurrency(min)}';
  String maximumAmount(double max) =>
      isArabic ? 'الحد الأقصى ${formatCurrency(max)}' : 'Maximum ${formatCurrency(max)}';
  String get insufficientBalance =>
      isArabic ? 'الرصيد غير كافٍ' : 'Insufficient balance';
  String get invalidPin => isArabic ? 'رمز PIN غير صحيح' : 'Invalid PIN';
  String get pinLocked =>
      isArabic ? 'المحفظة مقفلة مؤقتاً بسبب محاولات PIN الفاشلة' : 'Wallet temporarily locked due to failed PIN attempts';
  String get selfTransferError =>
      isArabic ? 'لا يمكن الإرسال إلى محفظتك الخاصة' : 'Cannot send to your own wallet';

  // ── Transaction History ─────────────────────────────────────────────────────

  String get transactionHistory => isArabic ? 'سجل المعاملات' : 'Transaction History';
  String get noTransactions =>
      isArabic ? 'لا توجد معاملات بعد' : 'No transactions yet';
  String get sent => isArabic ? 'مُرسل' : 'Sent';
  String get received => isArabic ? 'مُستلم' : 'Received';

  String statusLabel(String status) {
    if (isArabic) {
      switch (status) {
        case 'CONFIRMED': return 'مؤكدة';
        case 'PENDING': return 'معلقة';
        case 'REJECTED': return 'مرفوضة';
        case 'DISPUTED': return 'متنازع عليها';
        case 'RELAYED': return 'محوّلة';
        default: return status;
      }
    }
    switch (status) {
      case 'CONFIRMED': return 'Confirmed';
      case 'PENDING': return 'Pending';
      case 'REJECTED': return 'Rejected';
      case 'DISPUTED': return 'Disputed';
      case 'RELAYED': return 'Relayed';
      default: return status;
    }
  }

  // ── Sync ────────────────────────────────────────────────────────────────────

  String get syncing => isArabic ? 'جاري المزامنة' : 'Syncing';
  String get syncCompleted => isArabic ? 'اكتملت المزامنة' : 'Sync completed';
  String get syncFailed => isArabic ? 'فشلت المزامنة' : 'Sync failed';
  String get syncOffline => isArabic ? 'غير متصل بالإنترنت' : 'No internet connection';
  String get lastSynced => isArabic ? 'آخر مزامنة' : 'Last synced';
  String get syncNow => isArabic ? 'مزامنة الآن' : 'Sync Now';
  String pendingTransactions(int count) =>
      isArabic ? '$count معاملة معلقة' : '$count pending transaction(s)';

  // ── Bluetooth ───────────────────────────────────────────────────────────────

  String get bluetoothSend => isArabic ? 'إرسال عبر البلوتوث' : 'Send via Bluetooth';
  String get bluetoothReceive => isArabic ? 'استقبال عبر البلوتوث' : 'Receive via Bluetooth';
  String get bluetoothScanning => isArabic ? 'جاري البحث عن الأجهزة...' : 'Scanning for devices...';
  String get bluetoothUnavailable =>
      isArabic ? 'البلوتوث غير متاح أو مُعطّل' : 'Bluetooth unavailable or disabled';
  String get noBluetoothNodes =>
      isArabic ? 'لا توجد أجهزة قريبة' : 'No nearby devices found';
  String nearbyDevices(int count) =>
      isArabic ? '$count جهاز قريب' : '$count nearby device(s)';
  String get meshBroadcastSuccess =>
      isArabic ? 'تم الإرسال عبر الشبكة' : 'Broadcast via mesh network';

  // ── NFC ─────────────────────────────────────────────────────────────────────

  String get nfcTapToPay => isArabic ? 'انقر للدفع' : 'Tap to Pay';
  String get nfcReceive => isArabic ? 'استقبال بـ NFC' : 'Receive via NFC';
  String get nfcUnavailable => isArabic ? 'NFC غير متاح على هذا الجهاز' : 'NFC not available on this device';
  String get holdNearDevice =>
      isArabic ? 'اقترب من الهاتف الآخر' : 'Hold near the other device';
  String get nfcWriteSuccess =>
      isArabic ? 'تم الكتابة على الوسم' : 'Written to NFC tag successfully';
  String get nfcTransactionReceived =>
      isArabic ? 'تم استلام الدفعة عبر NFC' : 'Payment received via NFC';

  // ── SMS Relay ───────────────────────────────────────────────────────────────

  String get smsRelay => isArabic ? 'إرسال عبر SMS' : 'SMS Relay';
  String get recipientPhone => isArabic ? 'رقم هاتف المستلم' : 'Recipient phone number';
  String get smsSending => isArabic ? 'جاري الإرسال عبر SMS...' : 'Sending via SMS...';
  String smsChunkProgress(int sent, int total) =>
      isArabic ? 'إرسال الجزء $sent من $total' : 'Sending chunk $sent of $total';
  String get smsDelivered => isArabic ? 'تم الإرسال عبر SMS' : 'Delivered via SMS';

  // ── Connection Status ───────────────────────────────────────────────────────

  String get internet => isArabic ? 'الإنترنت' : 'Internet';
  String get mesh => isArabic ? 'شبكة Mesh' : 'Mesh';
  String get connected => isArabic ? 'متصل' : 'Connected';
  String get disconnected => isArabic ? 'غير متصل' : 'Disconnected';

  // ── Security ────────────────────────────────────────────────────────────────

  String get securityTitle => isArabic ? 'الأمان' : 'Security';
  String get changePin => isArabic ? 'تغيير رمز PIN' : 'Change PIN';
  String get emergencyFreeze => isArabic ? 'تجميد طارئ' : 'Emergency Freeze';
  String get emergencyFreezeConfirm =>
      isArabic ? 'هل أنت متأكد من تجميد المحفظة؟ لا يمكن إلغاؤه إلا عبر الدعم.'
               : 'Are you sure you want to freeze? Only support can unfreeze.';
  String get keyRotation => isArabic ? 'تجديد المفاتيح' : 'Key Rotation';
  String get disputeDetected =>
      isArabic ? 'تم اكتشاف تعارض في المعاملات' : 'Transaction dispute detected';

  // ── Limits ──────────────────────────────────────────────────────────────────

  String get limitsTitle => isArabic ? 'حدود المحفظة' : 'Wallet Limits';
  String get maxOfflineBalance => isArabic ? 'الحد الأقصى للرصيد' : 'Max Offline Balance';
  String get dailySendLimit => isArabic ? 'حد الإرسال اليومي' : 'Daily Send Limit';
  String get dailyReceiveLimit => isArabic ? 'حد الاستقبال اليومي' : 'Daily Receive Limit';
  String get maxPendingTx => isArabic ? 'الحد الأقصى للمعاملات المعلقة' : 'Max Pending Transactions';

  // ── Disputes ────────────────────────────────────────────────────────────────

  String get disputeTitle => isArabic ? 'تعارض المعاملة' : 'Transaction Dispute';
  String get doubleSpend => isArabic ? 'إنفاق مزدوج' : 'Double Spend';
  String get disputeAutoResolved => isArabic ? 'تم حل التعارض تلقائياً' : 'Dispute auto-resolved';
  String get disputeUnderReview => isArabic ? 'التعارض قيد المراجعة' : 'Dispute under review';

  // ── Time formatting ─────────────────────────────────────────────────────────

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return isArabic ? 'الآن' : 'Just now';
    } else if (diff.inMinutes < 60) {
      return isArabic ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return isArabic ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
    } else {
      return isArabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
    }
  }
}

// ── Delegate ───────────────────────────────────────────────────────────────────

class _OfflineWalletLocalizationsDelegate
    extends LocalizationsDelegate<OfflineWalletLocalizations> {
  const _OfflineWalletLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<OfflineWalletLocalizations> load(Locale locale) async =>
      OfflineWalletLocalizations(locale);

  @override
  bool shouldReload(_OfflineWalletLocalizationsDelegate old) => false;
}
