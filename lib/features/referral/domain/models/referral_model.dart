/// Referral code type
enum ReferralCodeType { standard, vip, newuser }

extension ReferralCodeTypeExt on ReferralCodeType {
  String get key {
    switch (this) {
      case ReferralCodeType.standard: return 'standard';
      case ReferralCodeType.vip:      return 'vip';
      case ReferralCodeType.newuser:  return 'newuser';
    }
  }

  static ReferralCodeType fromString(String s) {
    switch (s) {
      case 'vip':     return ReferralCodeType.vip;
      case 'newuser': return ReferralCodeType.newuser;
      default:        return ReferralCodeType.standard;
    }
  }
}

/// Data returned by POST /api/referral/validate
class ReferralCodeModel {
  final String code;
  final ReferralCodeType type;
  final double referrerBonus;   // SDG bonus for the person who shared the code
  final double referredBonus;   // SDG bonus/discount for new user
  final int? discountPercent;   // VIP-only % discount
  final String descriptionEn;
  final String descriptionAr;
  final bool isValid;

  ReferralCodeModel({
    required this.code,
    required this.type,
    required this.referrerBonus,
    required this.referredBonus,
    this.discountPercent,
    required this.descriptionEn,
    required this.descriptionAr,
    this.isValid = true,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeModel(
      code:            json['code'] as String,
      type:            ReferralCodeTypeExt.fromString(json['type'] as String? ?? 'standard'),
      referrerBonus:   (json['referrer_bonus'] as num).toDouble(),
      referredBonus:   (json['referred_bonus'] as num).toDouble(),
      discountPercent: json['discount_percent'] as int?,
      descriptionEn:   json['description_en'] as String? ?? '',
      descriptionAr:   json['description_ar'] as String? ?? '',
      isValid:         json['is_valid'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'code':             code,
    'type':             type.key,
    'referrer_bonus':   referrerBonus,
    'referred_bonus':   referredBonus,
    'discount_percent': discountPercent,
    'description_en':   descriptionEn,
    'description_ar':   descriptionAr,
  };
}

/// Result of POST /api/referral/apply
class ReferralApplyResult {
  final bool success;
  final String messageEn;
  final String messageAr;
  final double? bonusCredited;

  ReferralApplyResult({
    required this.success,
    required this.messageEn,
    required this.messageAr,
    this.bonusCredited,
  });

  factory ReferralApplyResult.fromJson(Map<String, dynamic> json) {
    return ReferralApplyResult(
      success:       json['status'] == 'success',
      messageEn:     json['message'] as String? ?? '',
      messageAr:     json['message_ar'] as String? ?? '',
      bonusCredited: (json['bonus_credited'] as num?)?.toDouble(),
    );
  }
}

/// GET /api/referral/stats
class ReferralStatsModel {
  final int happyUsers;
  final double totalEarned;
  final int activeReferrals;
  final String? myReferralCode;

  ReferralStatsModel({
    required this.happyUsers,
    required this.totalEarned,
    required this.activeReferrals,
    this.myReferralCode,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      happyUsers:       (json['happy_users'] as num?)?.toInt() ?? 250000,
      totalEarned:      (json['total_earned'] as num?)?.toDouble() ?? 1500000,
      activeReferrals:  (json['active_referrals'] as num?)?.toInt() ?? 45000,
      myReferralCode:   json['my_referral_code'] as String?,
    );
  }

  /// Formats large numbers: 1500000 → "1.5M+"
  static String formatStat(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M+';
    if (value >= 1000)    return '${(value / 1000).toStringAsFixed(0)}K+';
    return value.toString();
  }
}
