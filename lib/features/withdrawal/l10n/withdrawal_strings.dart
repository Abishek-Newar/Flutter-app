/// CircleCash — Withdrawal Feature Bilingual Strings
/// Merge into assets/language/en.json and ar.json

class WithdrawalStrings {
  // ── English ──────────────────────────────────────────────────────────────
  static const Map<String, String> en = {
    // Screen titles
    'withdrawal': 'Withdrawal',
    'withdraw_funds': 'Withdraw Funds',
    'withdrawal_request': 'Withdrawal Request',
    'withdrawal_history': 'Withdrawal History',
    'withdrawal_confirmation': 'Confirm Withdrawal',
    'withdrawal_success': 'Withdrawal Submitted',

    // Method selection
    'select_withdrawal_method': 'Select Withdrawal Method',
    'withdrawal_method': 'Withdrawal Method',
    'bank_transfer': 'Bank Transfer',
    'mobile_wallet': 'Mobile Wallet',
    'no_withdrawal_methods': 'No withdrawal methods available',

    // Amount entry
    'enter_withdrawal_amount': 'Enter Amount',
    'withdrawal_amount': 'Withdrawal Amount',
    'amount_in_sdg': 'Amount in SDG',
    'available_balance': 'Available Balance',
    'withdrawal_fee': 'Withdrawal Fee (2%)',
    'withdrawal_fee_max': 'Max fee: SDG 5,000',
    'you_will_receive': 'You Will Receive',
    'min_withdrawal': 'Min: SDG 1,000',
    'max_withdrawal': 'Max: SDG 500,000',
    'daily_limit_remaining': 'Daily Limit Remaining',
    'monthly_limit_remaining': 'Monthly Limit Remaining',
    'insufficient_balance': 'Insufficient balance',
    'exceeds_daily_limit': 'Amount exceeds your daily limit',
    'exceeds_single_limit': 'Amount exceeds single transaction limit',
    'amount_too_low': 'Minimum withdrawal is SDG 1,000',

    // Form fields
    'bank_account_number': 'Bank Account Number',
    'account_holder_name': 'Account Holder Name',
    'bank_name': 'Bank Name',
    'branch_name': 'Branch Name',
    'phone_number': 'Phone Number',
    'enter_account_number': 'Enter account number',
    'enter_account_holder': 'Enter account holder name',
    'select_bank': 'Select Bank',
    'enter_branch': 'Enter branch (optional)',
    'enter_phone': 'e.g. +249 9X XXX XXXX',

    // KYC tier limits
    'kyc_tier': 'KYC Tier',
    'kyc_basic': 'Basic',
    'kyc_intermediate': 'Intermediate',
    'kyc_advanced': 'Advanced',
    'kyc_corporate': 'Corporate',
    'basic_daily_limit': 'Daily limit: SDG 50,000',
    'intermediate_daily_limit': 'Daily limit: SDG 200,000',
    'advanced_daily_limit': 'Daily limit: SDG 500,000',
    'corporate_daily_limit': 'Daily limit: SDG 10,000,000',
    'upgrade_kyc': 'Upgrade KYC to increase limits',

    // Confirmation
    'withdrawal_details': 'Withdrawal Details',
    'recipient_details': 'Recipient Details',
    'processing_time': 'Processing Time',
    'processing_time_value': '1–3 business days',
    'enter_pin': 'Enter PIN to confirm',
    'confirm_and_submit': 'Confirm & Submit',

    // Risk / security
    'risk_assessment': 'Security Check',
    'risk_low': 'Standard Processing',
    'risk_medium': 'Additional Review Required',
    'risk_high': 'Manual Review Required',
    'dual_approval_required': 'This amount requires dual approval',
    'request_under_review': 'Your request is under review',

    // Status
    'status_pending': 'Pending',
    'status_under_review': 'Under Review',
    'status_approved': 'Approved',
    'status_processing': 'Processing',
    'status_completed': 'Completed',
    'status_rejected': 'Rejected',
    'status_cancelled': 'Cancelled',

    // History
    'no_withdrawal_history': 'No withdrawal history',
    'withdrawal_ref': 'Reference',
    'submitted_on': 'Submitted',
    'completed_on': 'Completed',
    'rejection_reason': 'Reason',
    'view_details': 'View Details',

    // Success / error
    'withdrawal_submitted_msg': 'Your withdrawal request has been submitted. You will be notified once processed.',
    'withdrawal_failed': 'Withdrawal request failed',
    'try_again': 'Try Again',

    // SDG formatting
    'currency_sdg': 'SDG',
    'sdg_prefix': 'SDG',
    'fee_calculated': 'Fee is 2% of amount, max SDG 5,000',
    'cbos_compliance': 'Compliant with Central Bank of Sudan regulations',
    'amounts_in_sdg': 'All amounts in Sudanese Pound (SDG)',
  };

  // ── Arabic ────────────────────────────────────────────────────────────────
  static const Map<String, String> ar = {
    // Screen titles
    'withdrawal': 'سحب',
    'withdraw_funds': 'سحب الأموال',
    'withdrawal_request': 'طلب سحب',
    'withdrawal_history': 'سجل السحوبات',
    'withdrawal_confirmation': 'تأكيد السحب',
    'withdrawal_success': 'تم تقديم طلب السحب',

    // Method selection
    'select_withdrawal_method': 'اختر طريقة السحب',
    'withdrawal_method': 'طريقة السحب',
    'bank_transfer': 'تحويل بنكي',
    'mobile_wallet': 'محفظة جوال',
    'no_withdrawal_methods': 'لا توجد طرق سحب متاحة',

    // Amount entry
    'enter_withdrawal_amount': 'أدخل المبلغ',
    'withdrawal_amount': 'مبلغ السحب',
    'amount_in_sdg': 'المبلغ بالجنيه السوداني',
    'available_balance': 'الرصيد المتاح',
    'withdrawal_fee': 'رسوم السحب (2٪)',
    'withdrawal_fee_max': 'الحد الأقصى للرسوم: 5,000 ج.س',
    'you_will_receive': 'ستستلم',
    'min_withdrawal': 'الحد الأدنى: 1,000 ج.س',
    'max_withdrawal': 'الحد الأقصى: 500,000 ج.س',
    'daily_limit_remaining': 'المتبقي من الحد اليومي',
    'monthly_limit_remaining': 'المتبقي من الحد الشهري',
    'insufficient_balance': 'رصيد غير كافٍ',
    'exceeds_daily_limit': 'المبلغ يتجاوز حدك اليومي',
    'exceeds_single_limit': 'المبلغ يتجاوز حد المعاملة الواحدة',
    'amount_too_low': 'الحد الأدنى للسحب 1,000 ج.س',

    // Form fields
    'bank_account_number': 'رقم الحساب البنكي',
    'account_holder_name': 'اسم صاحب الحساب',
    'bank_name': 'اسم البنك',
    'branch_name': 'اسم الفرع',
    'phone_number': 'رقم الهاتف',
    'enter_account_number': 'أدخل رقم الحساب',
    'enter_account_holder': 'أدخل اسم صاحب الحساب',
    'select_bank': 'اختر البنك',
    'enter_branch': 'أدخل الفرع (اختياري)',
    'enter_phone': 'مثال: 9X XXX XXXX 249+',

    // KYC tier limits
    'kyc_tier': 'مستوى التحقق',
    'kyc_basic': 'أساسي',
    'kyc_intermediate': 'متوسط',
    'kyc_advanced': 'متقدم',
    'kyc_corporate': 'شركات',
    'basic_daily_limit': 'الحد اليومي: 50,000 ج.س',
    'intermediate_daily_limit': 'الحد اليومي: 200,000 ج.س',
    'advanced_daily_limit': 'الحد اليومي: 500,000 ج.س',
    'corporate_daily_limit': 'الحد اليومي: 10,000,000 ج.س',
    'upgrade_kyc': 'رفع مستوى التحقق لزيادة الحدود',

    // Confirmation
    'withdrawal_details': 'تفاصيل السحب',
    'recipient_details': 'بيانات المستلم',
    'processing_time': 'وقت المعالجة',
    'processing_time_value': '1–3 أيام عمل',
    'enter_pin': 'أدخل الرقم السري للتأكيد',
    'confirm_and_submit': 'تأكيد وإرسال',

    // Risk / security
    'risk_assessment': 'فحص الأمان',
    'risk_low': 'معالجة اعتيادية',
    'risk_medium': 'يتطلب مراجعة إضافية',
    'risk_high': 'يتطلب مراجعة يدوية',
    'dual_approval_required': 'هذا المبلغ يتطلب موافقة مزدوجة',
    'request_under_review': 'طلبك قيد المراجعة',

    // Status
    'status_pending': 'قيد الانتظار',
    'status_under_review': 'قيد المراجعة',
    'status_approved': 'موافق عليه',
    'status_processing': 'جاري المعالجة',
    'status_completed': 'مكتمل',
    'status_rejected': 'مرفوض',
    'status_cancelled': 'ملغى',

    // History
    'no_withdrawal_history': 'لا يوجد سجل سحوبات',
    'withdrawal_ref': 'المرجع',
    'submitted_on': 'تاريخ التقديم',
    'completed_on': 'تاريخ الإكمال',
    'rejection_reason': 'السبب',
    'view_details': 'عرض التفاصيل',

    // Success / error
    'withdrawal_submitted_msg': 'تم تقديم طلب السحب بنجاح. ستتلقى إشعاراً عند المعالجة.',
    'withdrawal_failed': 'فشل طلب السحب',
    'try_again': 'حاول مرة أخرى',

    // SDG formatting
    'currency_sdg': 'ج.س',
    'sdg_prefix': 'ج.س',
    'fee_calculated': 'الرسوم 2٪ من المبلغ، الحد الأقصى 5,000 ج.س',
    'cbos_compliance': 'متوافق مع لوائح بنك السودان المركزي',
    'amounts_in_sdg': 'جميع المبالغ بالجنيه السوداني (ج.س)',
  };
}
