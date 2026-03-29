// ─────────────────────────────────────────────────────────────────────────────
// remittance_model.dart
// All data models for the Remittance feature.
// Based on blueprint: RemittanceService (Quote, Recipient, RemittanceResult,
//   FraudChallengeException) + LedgerService (double-entry journal).
// SDG source currency · Bilingual EN / AR
// ─────────────────────────────────────────────────────────────────────────────

// ── SDG / foreign currency formatter ────────────────────────────────────────
class RemitFormatter {
  /// SDG 1,234.56  /  ج.س 1,234.56
  static String sdg(double amount, {bool isAr = false}) {
    final n = _fmt(amount);
    return isAr ? 'ج.س $n' : 'SDG $n';
  }

  /// e.g. EGP 500.00  /  100.00 USD
  static String foreign(double amount, String currency, {bool isAr = false}) {
    final n = _fmt(amount);
    return isAr ? '$n $currency' : '$currency $n';
  }

  static String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$whole.${parts[1]}';
  }
}

// ── Payout method ────────────────────────────────────────────────────────────
enum PayoutMethod { bankDeposit, mobileMoney, cashPickup, walletTransfer }

extension PayoutMethodX on PayoutMethod {
  String get code {
    switch (this) {
      case PayoutMethod.bankDeposit:    return 'bank_deposit';
      case PayoutMethod.mobileMoney:    return 'mobile_money';
      case PayoutMethod.cashPickup:     return 'cash_pickup';
      case PayoutMethod.walletTransfer: return 'wallet_transfer';
    }
  }

  String get i18nKey => code; // matches JSON language keys exactly

  String get deliveryKey {
    switch (this) {
      case PayoutMethod.walletTransfer: return 'remit_delivery_instant';
      case PayoutMethod.mobileMoney:    return 'remit_delivery_same_day';
      default:                          return 'remit_delivery_1_3_days';
    }
  }

  static PayoutMethod fromCode(String? s) {
    switch (s) {
      case 'mobile_money':    return PayoutMethod.mobileMoney;
      case 'cash_pickup':     return PayoutMethod.cashPickup;
      case 'wallet_transfer': return PayoutMethod.walletTransfer;
      default:                return PayoutMethod.bankDeposit;
    }
  }
}

// ── Corridor (destination country) ──────────────────────────────────────────
class RemitCorridor {
  final String code;       // ISO-2
  final String nameEn;
  final String nameAr;
  final String currency;   // destination ISO-3
  final String flag;       // emoji
  final bool popular;
  final List<PayoutMethod> methods;

  const RemitCorridor({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.currency,
    required this.flag,
    required this.methods,
    this.popular = false,
  });

  String localizedName(bool isAr) => isAr ? nameAr : nameEn;

  static const List<RemitCorridor> all = [
    RemitCorridor(code:'EG', nameEn:'Egypt',          nameAr:'مصر',                      currency:'EGP', flag:'🇪🇬', popular:true,  methods:[PayoutMethod.bankDeposit, PayoutMethod.mobileMoney, PayoutMethod.cashPickup]),
    RemitCorridor(code:'SA', nameEn:'Saudi Arabia',   nameAr:'المملكة العربية السعودية', currency:'SAR', flag:'🇸🇦', popular:true,  methods:[PayoutMethod.bankDeposit, PayoutMethod.walletTransfer]),
    RemitCorridor(code:'AE', nameEn:'UAE',             nameAr:'الإمارات',                 currency:'AED', flag:'🇦🇪', popular:true,  methods:[PayoutMethod.bankDeposit, PayoutMethod.walletTransfer, PayoutMethod.cashPickup]),
    RemitCorridor(code:'US', nameEn:'United States',  nameAr:'الولايات المتحدة',          currency:'USD', flag:'🇺🇸', popular:true,  methods:[PayoutMethod.bankDeposit, PayoutMethod.walletTransfer]),
    RemitCorridor(code:'GB', nameEn:'United Kingdom', nameAr:'المملكة المتحدة',           currency:'GBP', flag:'🇬🇧', popular:false, methods:[PayoutMethod.bankDeposit]),
    RemitCorridor(code:'ET', nameEn:'Ethiopia',       nameAr:'إثيوبيا',                  currency:'ETB', flag:'🇪🇹', popular:false, methods:[PayoutMethod.mobileMoney, PayoutMethod.cashPickup]),
    RemitCorridor(code:'JO', nameEn:'Jordan',         nameAr:'الأردن',                   currency:'JOD', flag:'🇯🇴', popular:false, methods:[PayoutMethod.bankDeposit]),
    RemitCorridor(code:'QA', nameEn:'Qatar',          nameAr:'قطر',                      currency:'QAR', flag:'🇶🇦', popular:true,  methods:[PayoutMethod.bankDeposit, PayoutMethod.walletTransfer]),
    RemitCorridor(code:'KW', nameEn:'Kuwait',         nameAr:'الكويت',                   currency:'KWD', flag:'🇰🇼', popular:false, methods:[PayoutMethod.bankDeposit]),
  ];

  static RemitCorridor? byCode(String c) {
    for (final x in all) { if (x.code == c) return x; }
    return null;
  }
}

// ── Quote — maps blueprint Quote class ──────────────────────────────────────
class RemittanceQuote {
  final String   quoteId;
  final double   sendAmount;      // SDG
  final double   receiveAmount;   // destination currency
  final double   exchangeRate;
  final double   fee;             // SDG
  final double   totalToPay;      // sendAmount + fee (SDG)
  final String   fromCurrency;    // always SDG
  final String   toCurrency;
  final String   destinationCountry;
  final String   payoutMethod;
  final DateTime expiresAt;       // blueprint: 10-minute window

  const RemittanceQuote({
    required this.quoteId,
    required this.sendAmount,
    required this.receiveAmount,
    required this.exchangeRate,
    required this.fee,
    required this.totalToPay,
    required this.fromCurrency,
    required this.toCurrency,
    required this.destinationCountry,
    required this.payoutMethod,
    required this.expiresAt,
  });

  bool     get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeLeft  => expiresAt.difference(DateTime.now());

  factory RemittanceQuote.fromJson(Map<String, dynamic> j) {
    final send = _d(j['send_amount']);
    final fee  = _d(j['fee']);
    return RemittanceQuote(
      quoteId:            j['quote_id']            as String,
      sendAmount:         send,
      receiveAmount:      _d(j['receive_amount']),
      exchangeRate:       _d(j['rate']),
      fee:                fee,
      totalToPay:         send + fee,
      fromCurrency:       j['from_currency']        as String? ?? 'SDG',
      toCurrency:         j['to_currency']          as String? ?? '',
      destinationCountry: j['destination_country']  as String? ?? '',
      payoutMethod:       j['payout_method']        as String? ?? 'bank_deposit',
      expiresAt:          DateTime.parse(j['expires_at'] as String),
    );
  }
  static double _d(dynamic v) => double.tryParse('$v') ?? 0.0;
}

// ── Recipient — maps blueprint Recipient class ───────────────────────────────
class RemittanceRecipient {
  final String  name;
  final String  phone;
  final String? email;
  final String  country;
  final String  payoutMethod;
  final String? bankName;
  final String? accountNumber;
  final String? mobileNumber;
  final String? pickupLocation;

  const RemittanceRecipient({
    required this.name,
    required this.phone,
    this.email,
    required this.country,
    required this.payoutMethod,
    this.bankName,
    this.accountNumber,
    this.mobileNumber,
    this.pickupLocation,
  });

  Map<String, dynamic> toJson() => {
    'name':          name,
    'phone':         phone,
    if (email != null)          'email':           email,
    'country':       country,
    'payout_method': payoutMethod,
    if (bankName != null)       'bank_name':        bankName,
    if (accountNumber != null)  'account_number':   accountNumber,
    if (mobileNumber != null)   'mobile_number':    mobileNumber,
    if (pickupLocation != null) 'pickup_location':  pickupLocation,
  };
}

// ── FraudChallenge — maps blueprint FraudChallengeException ─────────────────
class FraudChallenge {
  final List<String> methods;
  final String sessionId;
  const FraudChallenge({required this.methods, required this.sessionId});
}

// ── RemittanceResult — maps blueprint RemittanceResult ───────────────────────
class RemittanceResult {
  final String   reference;
  final String   status;
  final DateTime createdAt;

  const RemittanceResult({
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  factory RemittanceResult.fromJson(Map<String, dynamic> j) => RemittanceResult(
    reference: j['reference'] as String,
    status:    j['status']    as String,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}

// ── Remittance status ────────────────────────────────────────────────────────
enum RemittanceStatus { pending, processing, completed, failed, cancelled, refunded }

extension RemittanceStatusX on RemittanceStatus {
  String get i18nKey {
    switch (this) {
      case RemittanceStatus.pending:    return 'remit_status_pending';
      case RemittanceStatus.processing: return 'remit_status_processing';
      case RemittanceStatus.completed:  return 'remit_status_completed';
      case RemittanceStatus.failed:     return 'remit_status_failed';
      case RemittanceStatus.cancelled:  return 'remit_status_cancelled';
      case RemittanceStatus.refunded:   return 'remit_status_refunded';
    }
  }

  static RemittanceStatus from(String? s) {
    switch (s) {
      case 'processing': return RemittanceStatus.processing;
      case 'completed':  return RemittanceStatus.completed;
      case 'failed':     return RemittanceStatus.failed;
      case 'cancelled':  return RemittanceStatus.cancelled;
      case 'refunded':   return RemittanceStatus.refunded;
      default:           return RemittanceStatus.pending;
    }
  }
}

// ── History item ─────────────────────────────────────────────────────────────
class RemittanceHistoryItem {
  final String            id;
  final String            reference;
  final double            sendAmount;
  final double            receiveAmount;
  final double            fee;
  final String            toCurrency;
  final String            destinationCountry;
  final String            recipientName;
  final String            payoutMethod;
  final RemittanceStatus  status;
  final DateTime          createdAt;
  final DateTime?         completedAt;

  const RemittanceHistoryItem({
    required this.id,
    required this.reference,
    required this.sendAmount,
    required this.receiveAmount,
    required this.fee,
    required this.toCurrency,
    required this.destinationCountry,
    required this.recipientName,
    required this.payoutMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory RemittanceHistoryItem.fromJson(Map<String, dynamic> j) =>
      RemittanceHistoryItem(
        id:                 '${j['id']}',
        reference:          j['reference']           as String? ?? '',
        sendAmount:         _d(j['send_amount']),
        receiveAmount:      _d(j['receive_amount']),
        fee:                _d(j['fee']),
        toCurrency:         j['to_currency']         as String? ?? '',
        destinationCountry: j['destination_country'] as String? ?? '',
        recipientName:      j['recipient_name']      as String? ?? '',
        payoutMethod:       j['payout_method']       as String? ?? '',
        status:             RemittanceStatusX.from(j['status'] as String?),
        createdAt:          DateTime.parse(j['created_at'] as String),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String) : null,
      );
  static double _d(dynamic v) => double.tryParse('$v') ?? 0.0;
}
