/// OTP verification method enum
enum OtpMethod { sms, whatsapp, email, push }

extension OtpMethodExt on OtpMethod {
  String get key {
    switch (this) {
      case OtpMethod.sms: return 'sms';
      case OtpMethod.whatsapp: return 'whatsapp';
      case OtpMethod.email: return 'email';
      case OtpMethod.push: return 'push';
    }
  }

  String labelEn() {
    switch (this) {
      case OtpMethod.sms: return 'SMS OTP';
      case OtpMethod.whatsapp: return 'WhatsApp';
      case OtpMethod.email: return 'Email OTP';
      case OtpMethod.push: return 'Push Notification';
    }
  }

  String labelAr() {
    switch (this) {
      case OtpMethod.sms: return 'رسالة نصية';
      case OtpMethod.whatsapp: return 'واتساب';
      case OtpMethod.email: return 'البريد الإلكتروني';
      case OtpMethod.push: return 'إشعار فوري';
    }
  }

  String descEn() {
    switch (this) {
      case OtpMethod.sms: return 'Send code via text';
      case OtpMethod.whatsapp: return 'Send code via WhatsApp';
      case OtpMethod.email: return 'Send code via email';
      case OtpMethod.push: return 'Send code via app';
    }
  }

  String descAr() {
    switch (this) {
      case OtpMethod.sms: return 'إرسال الرمز عبر SMS';
      case OtpMethod.whatsapp: return 'إرسال الرمز عبر واتساب';
      case OtpMethod.email: return 'إرسال الرمز عبر البريد';
      case OtpMethod.push: return 'إرسال الرمز عبر التطبيق';
    }
  }
}

/// Represents a completed OTP send/verify request cycle
class OtpRequestModel {
  final String? phoneNumber;
  final String? email;
  final OtpMethod method;
  final bool isForgetPassword;
  final DateTime createdAt;

  OtpRequestModel({
    this.phoneNumber,
    this.email,
    required this.method,
    this.isForgetPassword = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
