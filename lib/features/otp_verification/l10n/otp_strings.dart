/// OTP Verification — Bilingual String Constants
/// Integrates with the existing six_cash GetX localization system.
///
/// Add these keys to your lang/en.json and lang/ar.json (or language maps).
/// They follow the same naming convention already in the app (snake_case).

class OtpStrings {
  // ── English ──────────────────────────────────────────────────────────────
  static const Map<String, String> en = {
    // Screen titles & header
    'otp_secure_verification': 'Secure Verification',
    'otp_header_subtitle': 'Step 3 of 4 — Identity Check',

    // Labels
    'otp_phone_label': 'Phone Number',
    'otp_email_label': 'Email Address',
    'otp_choose_method': 'Choose verification method',
    'otp_enter_code': 'Enter 6-digit code',
    'otp_code_expires': 'Code expires in',

    // Method names
    'otp_method_sms': 'SMS OTP',
    'otp_method_sms_desc': 'Send code via text',
    'otp_method_whatsapp': 'WhatsApp',
    'otp_method_whatsapp_desc': 'Send code via WhatsApp',
    'otp_method_email': 'Email OTP',
    'otp_method_email_desc': 'Send code via email',
    'otp_method_push': 'Push Notification',
    'otp_method_push_desc': 'Send code via app',

    // Buttons
    'otp_verify_continue': 'Verify & Continue',
    'otp_resend': 'Resend OTP',
    'otp_resend_question': "Didn't receive the code?",
    'otp_request_callback': 'Request Callback',

    // Agent section
    'otp_need_help': 'Need help?',
    'otp_agent_text': 'Visit our office or call +249 900 123 456 for assistance with verification.',

    // Status messages
    'otp_success': 'Verification successful! Redirecting...',
    'otp_error_invalid': 'Invalid code. Please try again.',
    'otp_error_expired': 'Code expired. Please request a new one.',
    'otp_error_attempts': 'Too many attempts. Account temporarily locked.',
    'otp_resend_success': 'New code sent via {method}',
    'otp_callback_requested': "Callback requested. We'll contact you shortly.",
    'otp_sending': 'Sending...',
    'otp_verifying': 'Verifying...',
    'otp_wait_seconds': 'Wait {n}s',

    // Accessibility
    'otp_digit_label': 'Digit {n}',
    'otp_step_completed': 'Step {n} completed',
    'otp_step_active': 'Step {n} active',
    'otp_step_pending': 'Step {n} pending',
  };

  // ── Arabic ────────────────────────────────────────────────────────────────
  static const Map<String, String> ar = {
    // Screen titles & header
    'otp_secure_verification': 'التحقق الآمن',
    'otp_header_subtitle': 'الخطوة 3 من 4 — التحقق من الهوية',

    // Labels
    'otp_phone_label': 'رقم الهاتف',
    'otp_email_label': 'البريد الإلكتروني',
    'otp_choose_method': 'اختر طريقة التحقق',
    'otp_enter_code': 'أدخل الرمز المكون من 6 أرقام',
    'otp_code_expires': 'ينتهي الرمز في',

    // Method names
    'otp_method_sms': 'رسالة نصية',
    'otp_method_sms_desc': 'إرسال الرمز عبر SMS',
    'otp_method_whatsapp': 'واتساب',
    'otp_method_whatsapp_desc': 'إرسال الرمز عبر واتساب',
    'otp_method_email': 'البريد الإلكتروني',
    'otp_method_email_desc': 'إرسال الرمز عبر البريد',
    'otp_method_push': 'إشعار فوري',
    'otp_method_push_desc': 'إرسال الرمز عبر التطبيق',

    // Buttons
    'otp_verify_continue': 'تحقق واستمر',
    'otp_resend': 'إعادة إرسال الرمز',
    'otp_resend_question': 'لم تستلم الرمز؟',
    'otp_request_callback': 'طلب اتصال',

    // Agent section
    'otp_need_help': 'تحتاج مساعدة؟',
    'otp_agent_text': 'قم بزيارة مكتبنا أو اتصل على +249 900 123 456 للمساعدة في التحقق.',

    // Status messages
    'otp_success': 'تم التحقق بنجاح! جارٍ التحويل...',
    'otp_error_invalid': 'رمز غير صحيح. يرجى المحاولة مرة أخرى.',
    'otp_error_expired': 'انتهت صلاحية الرمز. يرجى طلب رمز جديد.',
    'otp_error_attempts': 'محاولات كثيرة جداً. تم تأمين الحساب مؤقتاً.',
    'otp_resend_success': 'تم إرسال رمز جديد عبر {method}',
    'otp_callback_requested': 'تم طلب الاتصال. سنتواصل معك قريباً.',
    'otp_sending': 'جارٍ الإرسال...',
    'otp_verifying': 'جارٍ التحقق...',
    'otp_wait_seconds': 'انتظر {n}ث',

    // Accessibility
    'otp_digit_label': 'رقم {n}',
    'otp_step_completed': 'الخطوة {n} مكتملة',
    'otp_step_active': 'الخطوة {n} نشطة',
    'otp_step_pending': 'الخطوة {n} معلقة',
  };
}
