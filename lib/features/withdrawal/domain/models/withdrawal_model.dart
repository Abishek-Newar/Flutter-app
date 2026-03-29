import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// SDG Currency Helper
// ─────────────────────────────────────────────────────────────────────────────
class SdgFormatter {
  static String format(double amount, {bool isArabic = false}) {
    final formatted = _formatNumber(amount);
    return isArabic ? 'ج.س $formatted' : 'SDG $formatted';
  }

  static String _formatNumber(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    }
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '$intPart.${parts[1]}';
  }

  /// Calculates withdrawal fee: 2% of amount, capped at 5,000 SDG
  static double calculateFee(double amount) {
    final fee = amount * 0.02;
    return fee > 5000.0 ? 5000.0 : fee;
  }

  static double netAmount(double amount) => amount - calculateFee(amount);
}

// ─────────────────────────────────────────────────────────────────────────────
// KYC Tier
// ─────────────────────────────────────────────────────────────────────────────
enum KycTier { basic, intermediate, advanced, corporate }

extension KycTierLimits on KycTier {
  double get dailyLimit {
    switch (this) {
      case KycTier.basic:        return 50000;
      case KycTier.intermediate: return 200000;
      case KycTier.advanced:     return 500000;
      case KycTier.corporate:    return 10000000;
    }
  }

  double get monthlyLimit {
    switch (this) {
      case KycTier.basic:        return 500000;
      case KycTier.intermediate: return 2000000;
      case KycTier.advanced:     return 5000000;
      case KycTier.corporate:    return 100000000;
    }
  }

  double get singleTransactionMax => dailyLimit;

  String get labelEn {
    switch (this) {
      case KycTier.basic:        return 'Basic';
      case KycTier.intermediate: return 'Intermediate';
      case KycTier.advanced:     return 'Advanced';
      case KycTier.corporate:    return 'Corporate';
    }
  }

  String get labelAr {
    switch (this) {
      case KycTier.basic:        return 'أساسي';
      case KycTier.intermediate: return 'متوسط';
      case KycTier.advanced:     return 'متقدم';
      case KycTier.corporate:    return 'شركات';
    }
  }

  static KycTier fromString(String? s) {
    switch (s) {
      case 'intermediate': return KycTier.intermediate;
      case 'advanced':     return KycTier.advanced;
      case 'corporate':    return KycTier.corporate;
      default:             return KycTier.basic;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal Status
// ─────────────────────────────────────────────────────────────────────────────
enum WithdrawalStatus {
  pending,
  under_review,
  approved,
  processing,
  completed,
  rejected,
  cancelled,
}

extension WithdrawalStatusLabel on WithdrawalStatus {
  String get labelKey {
    switch (this) {
      case WithdrawalStatus.pending:      return 'status_pending';
      case WithdrawalStatus.under_review: return 'status_under_review';
      case WithdrawalStatus.approved:     return 'status_approved';
      case WithdrawalStatus.processing:   return 'status_processing';
      case WithdrawalStatus.completed:    return 'status_completed';
      case WithdrawalStatus.rejected:     return 'status_rejected';
      case WithdrawalStatus.cancelled:    return 'status_cancelled';
    }
  }

  bool get isFinal =>
      this == WithdrawalStatus.completed ||
      this == WithdrawalStatus.rejected ||
      this == WithdrawalStatus.cancelled;
}

// ─────────────────────────────────────────────────────────────────────────────
// Risk Level
// ─────────────────────────────────────────────────────────────────────────────
enum RiskLevel { low, medium, high }

extension RiskLevelLabel on RiskLevel {
  String get labelKey {
    switch (this) {
      case RiskLevel.low:    return 'risk_low';
      case RiskLevel.medium: return 'risk_medium';
      case RiskLevel.high:   return 'risk_high';
    }
  }

  static RiskLevel fromScore(int score) {
    if (score >= 60) return RiskLevel.high;
    if (score >= 30) return RiskLevel.medium;
    return RiskLevel.low;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal Method
// ─────────────────────────────────────────────────────────────────────────────
class WithdrawalMethodModel {
  final int id;
  final String methodName;
  final String methodNameAr;
  final List<WithdrawalFieldModel> fields;

  const WithdrawalMethodModel({
    required this.id,
    required this.methodName,
    required this.methodNameAr,
    required this.fields,
  });

  factory WithdrawalMethodModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalMethodModel(
      id:           json['id'] as int,
      methodName:   json['method_name'] as String,
      methodNameAr: json['method_name_ar'] as String? ?? json['method_name'] as String,
      fields:       (json['method_fields'] as List<dynamic>? ?? [])
          .map((f) => WithdrawalFieldModel.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  String localizedName(bool isArabic) => isArabic ? methodNameAr : methodName;
}

class WithdrawalFieldModel {
  final String inputName;
  final String inputType; // text | number | phone | select
  final String placeholder;
  final String placeholderAr;
  final bool required;
  String value;

  WithdrawalFieldModel({
    required this.inputName,
    required this.inputType,
    required this.placeholder,
    required this.placeholderAr,
    this.required = true,
    this.value = '',
  });

  factory WithdrawalFieldModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalFieldModel(
      inputName:     json['input_name'] as String,
      inputType:     json['input_type'] as String? ?? 'text',
      placeholder:   json['placeholder'] as String? ?? '',
      placeholderAr: json['placeholder_ar'] as String? ?? json['placeholder'] as String? ?? '',
      required:      json['required'] as bool? ?? true,
    );
  }

  String localizedPlaceholder(bool isArabic) =>
      isArabic ? placeholderAr : placeholder;
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal Request (outbound)
// ─────────────────────────────────────────────────────────────────────────────
class WithdrawalRequestModel {
  final int methodId;
  final double amount;
  final String pin;
  final Map<String, String> fieldValues;

  const WithdrawalRequestModel({
    required this.methodId,
    required this.amount,
    required this.pin,
    required this.fieldValues,
  });

  Map<String, dynamic> toJson() => {
    'withdrawal_method_id': methodId,
    'amount':               amount,
    'pin':                  pin,
    ...fieldValues,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal History Item
// ─────────────────────────────────────────────────────────────────────────────
class WithdrawalHistoryItem {
  final String id;
  final double amount;
  final double fee;
  final double netAmount;
  final String methodName;
  final String methodNameAr;
  final WithdrawalStatus status;
  final RiskLevel riskLevel;
  final String? rejectionReason;
  final String? rejectionReasonAr;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String referenceNumber;

  const WithdrawalHistoryItem({
    required this.id,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.methodName,
    required this.methodNameAr,
    required this.status,
    required this.riskLevel,
    this.rejectionReason,
    this.rejectionReasonAr,
    required this.createdAt,
    this.completedAt,
    required this.referenceNumber,
  });

  factory WithdrawalHistoryItem.fromJson(Map<String, dynamic> json) {
    final statusMap = {
      'pending':      WithdrawalStatus.pending,
      'under_review': WithdrawalStatus.under_review,
      'approved':     WithdrawalStatus.approved,
      'processing':   WithdrawalStatus.processing,
      'completed':    WithdrawalStatus.completed,
      'rejected':     WithdrawalStatus.rejected,
      'cancelled':    WithdrawalStatus.cancelled,
    };

    final amt  = double.tryParse('${json['amount']}')    ?? 0.0;
    final fee  = double.tryParse('${json['fee']}')       ?? SdgFormatter.calculateFee(amt);
    final net  = double.tryParse('${json['net_amount']}') ?? (amt - fee);
    final risk = int.tryParse('${json['risk_score']}')   ?? 0;

    return WithdrawalHistoryItem(
      id:               '${json['id']}',
      amount:           amt,
      fee:              fee,
      netAmount:        net,
      methodName:       json['withdrawal_method']?['method_name'] as String? ?? '',
      methodNameAr:     json['withdrawal_method']?['method_name_ar'] as String? ?? '',
      status:           statusMap[json['request_status']] ?? WithdrawalStatus.pending,
      riskLevel:        RiskLevelLabel.fromScore(risk),
      rejectionReason:  json['rejection_reason'] as String?,
      rejectionReasonAr: json['rejection_reason_ar'] as String?,
      createdAt:        DateTime.parse(json['created_at'] as String),
      completedAt:      json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      referenceNumber:  json['reference_number'] as String? ?? '#${json['id']}',
    );
  }

  String localizedMethodName(bool isAr) => isAr ? methodNameAr : methodName;
  String? localizedRejectionReason(bool isAr) =>
      isAr ? (rejectionReasonAr ?? rejectionReason) : rejectionReason;
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdrawal Limits (from server)
// ─────────────────────────────────────────────────────────────────────────────
class WithdrawalLimitsModel {
  final KycTier tier;
  final double dailyLimit;
  final double dailyUsed;
  final double monthlyLimit;
  final double monthlyUsed;
  final double singleMax;

  const WithdrawalLimitsModel({
    required this.tier,
    required this.dailyLimit,
    required this.dailyUsed,
    required this.monthlyLimit,
    required this.monthlyUsed,
    required this.singleMax,
  });

  double get dailyRemaining  => (dailyLimit - dailyUsed).clamp(0, dailyLimit);
  double get monthlyRemaining => (monthlyLimit - monthlyUsed).clamp(0, monthlyLimit);

  factory WithdrawalLimitsModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalLimitsModel(
      tier:         KycTierLimits.fromString(json['tier'] as String?),
      dailyLimit:   double.tryParse('${json['daily_limit']}')    ?? 50000,
      dailyUsed:    double.tryParse('${json['daily_used']}')     ?? 0,
      monthlyLimit: double.tryParse('${json['monthly_limit']}')  ?? 500000,
      monthlyUsed:  double.tryParse('${json['monthly_used']}')   ?? 0,
      singleMax:    double.tryParse('${json['single_max']}')     ?? 50000,
    );
  }
}
