/// CircleCash Referral Program — Bilingual Strings
/// Add these to your assets/language/en.json and ar.json files.
///
/// Follows the exact same key-value pattern used by the existing
/// six_cash GetX translation system (rootBundle.loadString).

class ReferralStrings {
  static const Map<String, String> en = {
    // Header
    'referral_program': 'Referral Program',

    // Benefits section
    'referral_benefits': 'Referral Benefits',
    'referral_benefit_1': 'Get 100 SDG bonus when your friend signs up',
    'referral_benefit_2': 'Your friend gets 50 SDG off their first transaction',
    'referral_benefit_3': 'Earn more when your friend refers others',

    // Form
    'referral_code_label': 'Enter Referral Code (Optional)',
    'referral_code_hint': 'e.g. FRIEND25',
    'referral_code_input_hint': 'Enter a valid code to earn bonuses',

    // Buttons
    'referral_apply': 'Apply Referral Code',
    'referral_skip': 'Skip & Continue',
    'referral_no_code': "I don't have a referral code",
    'referral_applied': 'Applied!',

    // Code info panel
    'referral_special_offer': 'Special Offer Unlocked!',
    'referral_vip_offer': 'VIP Special Offer Unlocked!',

    // Code type benefits
    'referral_standard_you': 'You get: 100 SDG bonus',
    'referral_standard_friend': 'Your friend gets: 50 SDG off first transaction',
    'referral_vip_status': '🌟 VIP STATUS UNLOCKED 🌟',
    'referral_vip_you': 'You get: 250 SDG bonus',
    'referral_vip_friend': 'Your friend gets: 100 SDG + 50% discount',
    'referral_newuser_title': 'New User Special!',
    'referral_newuser_you': 'You get: 150 SDG bonus',
    'referral_newuser_friend': 'Your friend gets: 75 SDG off first transaction',

    // Stats
    'referral_stat_users': 'Happy Users',
    'referral_stat_earned': 'SDG Earned',
    'referral_stat_referrals': 'Active Referrals',

    // Terms
    'referral_terms_toggle': 'View Terms & Conditions',
    'referral_terms_title': 'Referral Program Terms & Conditions',
    'referral_terms_accept': 'I have read and agree to the terms and conditions',
    'referral_terms_1': 'Referral codes must be entered during registration and cannot be added later.',
    'referral_terms_2': 'Referrer receives 100 SDG bonus after the referred friend completes their first successful transaction.',
    'referral_terms_3': 'Referred friend receives 50 SDG off their first transaction (minimum transaction amount applies).',
    'referral_terms_4': 'Bonus amounts are credited to the CircleCash wallet within 24-48 hours.',
    'referral_terms_5': 'Referral bonuses cannot be withdrawn as cash and must be used within CircleCash.',
    'referral_terms_6': 'Each user can only use one referral code during registration.',
    'referral_terms_7': 'CircleCash reserves the right to modify or terminate the referral program at any time.',
    'referral_terms_8': 'Fraudulent activities, including self-referrals, will result in account suspension.',
    'referral_terms_9': 'VIP codes (e.g., CIRCLE50) provide enhanced benefits as specified in the code description.',
    'referral_terms_10': 'All referrals are subject to verification and approval by the CircleCash team.',

    // Messages
    'referral_error_empty': 'Please enter a referral code.',
    'referral_error_invalid': 'Invalid referral code. Please check and try again.',
    'referral_error_expired': 'This referral code has expired.',
    'referral_error_used': 'You have already used a referral code.',
    'referral_error_self': 'You cannot use your own referral code.',
    'referral_success': 'Referral applied successfully!',
    'referral_success_vip': 'VIP code applied! You get 250 SDG + 50% discount!',
    'referral_bonus_activated': '+{bonus} SDG bonus activated!',
    'referral_skip_confirm': 'Continue without a referral code? You will miss out on bonus rewards.',
    'referral_skip_yes': 'Yes, Skip',
    'referral_skip_no': 'Enter Code',
  };

  static const Map<String, String> ar = {
    // Header
    'referral_program': 'برنامج الإحالة',

    // Benefits section
    'referral_benefits': 'مميزات الإحالة',
    'referral_benefit_1': 'احصل على 100 جنيه سوداني عند تسجيل صديقك',
    'referral_benefit_2': 'يحصل صديقك على خصم 50 جنيه سوداني في أول معاملة',
    'referral_benefit_3': 'اكسب المزيد عندما يقوم صديقك بالإحالة',

    // Form
    'referral_code_label': 'أدخل كود الإحالة (اختياري)',
    'referral_code_hint': 'مثال: FRIEND25',
    'referral_code_input_hint': 'أدخل كود صالح للحصول على المكافآت',

    // Buttons
    'referral_apply': 'تطبيق كود الإحالة',
    'referral_skip': 'تخطي والاستمرار',
    'referral_no_code': 'ليس لدي كود إحالة',
    'referral_applied': 'تم التطبيق!',

    // Code info panel
    'referral_special_offer': 'عرض خاص تم فتحه!',
    'referral_vip_offer': 'عرض VIP خاص تم فتحه!',

    // Code type benefits
    'referral_standard_you': 'تحصل على: 100 جنيه سوداني مكافأة',
    'referral_standard_friend': 'يحصل صديقك على: خصم 50 جنيه سوداني',
    'referral_vip_status': '🌟 تم فتح حالة VIP 🌟',
    'referral_vip_you': 'تحصل على: 250 جنيه سوداني مكافأة',
    'referral_vip_friend': 'يحصل صديقك على: 100 جنيه + خصم 50%',
    'referral_newuser_title': 'عرض خاص للمستخدمين الجدد!',
    'referral_newuser_you': 'تحصل على: 150 جنيه سوداني مكافأة',
    'referral_newuser_friend': 'يحصل صديقك على: خصم 75 جنيه سوداني',

    // Stats
    'referral_stat_users': 'مستخدم سعيد',
    'referral_stat_earned': 'جنيه سوداني تم ربحه',
    'referral_stat_referrals': 'إحالة نشطة',

    // Terms
    'referral_terms_toggle': 'عرض الشروط والأحكام',
    'referral_terms_title': 'شروط وأحكام برنامج الإحالة',
    'referral_terms_accept': 'لقد قرأت وأوافق على الشروط والأحكام',
    'referral_terms_1': 'يجب إدخال أكواد الإحالة أثناء التسجيل ولا يمكن إضافتها لاحقاً.',
    'referral_terms_2': 'يحصل المحيل على مكافأة 100 جنيه بعد أن يكمل الصديق أول معاملة ناجحة.',
    'referral_terms_3': 'يحصل الصديق المُحال على خصم 50 جنيه في أول معاملة (ينطبق الحد الأدنى).',
    'referral_terms_4': 'يتم إضافة المكافآت إلى محفظة CircleCash خلال 24-48 ساعة.',
    'referral_terms_5': 'لا يمكن سحب مكافآت الإحالة كنقد ويجب استخدامها داخل CircleCash.',
    'referral_terms_6': 'يمكن لكل مستخدم استخدام كود إحالة واحد فقط أثناء التسجيل.',
    'referral_terms_7': 'تحتفظ CircleCash بالحق في تعديل أو إنهاء برنامج الإحالة في أي وقت.',
    'referral_terms_8': 'الأنشطة الاحتيالية، بما في ذلك الإحالة الذاتية، ستؤدي إلى تعليق الحساب.',
    'referral_terms_9': 'توفر أكواد VIP مزايا محسنة كما هو موضح في وصف الكود.',
    'referral_terms_10': 'جميع الإحالات خاضعة للتحقق والموافقة من فريق CircleCash.',

    // Messages
    'referral_error_empty': 'الرجاء إدخال كود الإحالة.',
    'referral_error_invalid': 'كود إحالة غير صالح. يرجى التحقق والمحاولة مرة أخرى.',
    'referral_error_expired': 'انتهت صلاحية كود الإحالة هذا.',
    'referral_error_used': 'لقد استخدمت كود إحالة بالفعل.',
    'referral_error_self': 'لا يمكنك استخدام كود الإحالة الخاص بك.',
    'referral_success': 'تم تطبيق الكود بنجاح!',
    'referral_success_vip': 'تم تطبيق كود VIP! تحصل على 250 جنيه + خصم 50%!',
    'referral_bonus_activated': 'تم تفعيل مكافأة +{bonus} جنيه سوداني!',
    'referral_skip_confirm': 'الاستمرار بدون كود إحالة؟ ستفوتك مكافآت إضافية.',
    'referral_skip_yes': 'نعم، تخطي',
    'referral_skip_no': 'إدخال كود',
  };
}
