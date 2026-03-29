/// CircleCash Trust & Settlement System — Bilingual Strings
/// Merge into assets/language/en.json and ar.json

class TrustStrings {
  static const Map<String, String> en = {
    // Screen titles
    'trust_settlement_title':     'Trust & Settlement',
    'trust_settlement_subtitle':  'Automated 80:20 Fund Allocation',
    'trust_currency_badge':       'Primary Currency: Sudanese Pound (SDG)',

    // Account labels
    'trust_account_label':        'Trust Account',
    'trust_account_pct':          'Trust Account (80%)',
    'trust_badge':                'TRUST 80%',
    'trust_safeguarded':          'Safeguarded Customer Funds',
    'trust_compliant':            'Compliant',
    'settlement_account_label':   'Settlement Account',
    'settlement_account_pct':     'Settlement Account (20%)',
    'settlement_badge':           'SETTLEMENT 20%',
    'settlement_liquidity':       'Operational Liquidity',
    'settlement_active':          'Active',
    'total_badge':                'TOTAL',
    'total_deposits':             'Total Customer Deposits',
    'last_updated':               'Last updated: Just now',

    // Allocation chart
    'allocation_title':           'Real-time Fund Allocation',
    'legend_trust':               'Trust Account (80%) — Safeguarded',
    'legend_settlement':          'Settlement Account (20%) — Operational',

    // Stats summary
    'trust_stat_ratio':           '80:20 Ratio',
    'trust_stat_txns':            'Total Transactions',
    'trust_stat_rebalances':      'Rebalances Today',

    // Ledger screen
    'ledger_title':               'Ledger Entries',
    'ledger_empty':               'No transactions yet',
    'ledger_col_time':            'Time',
    'ledger_col_type':            'Type',
    'ledger_col_account':         'Account',
    'ledger_col_amount':          'Amount',
    'ledger_col_user':            'User',
    'ledger_col_status':          'Status',
    'ledger_status_completed':    'Completed',
    'ledger_status_processing':   'Processing',
    'ledger_type_deposit':        'Deposit',
    'ledger_type_withdrawal':     'Withdrawal',
    'ledger_type_rebalance':      'Rebalance',

    // Architecture cards
    'arch_trust_title':           'Trust Account (80%)',
    'arch_trust_desc':            'Holds 80% of customer funds in segregated safeguarding account',
    'arch_trust_1':               'Protected from creditors',
    'arch_trust_2':               'Regulatory compliance',
    'arch_trust_3':               'Interest benefits customers',
    'arch_settle_title':          'Settlement Account (20%)',
    'arch_settle_desc':           'Maintains 20% liquidity for daily operations',
    'arch_settle_1':              'Daily transaction processing',
    'arch_settle_2':              'Withdrawal handling',
    'arch_settle_3':              'Operational expenses',
    'arch_auto_title':            'Auto-Rebalancing',
    'arch_auto_desc':             'Daily automated rebalancing via bank API integration',
    'arch_auto_1':                'End-of-day reconciliation',
    'arch_auto_2':                'Bank API transfers',
    'arch_auto_3':                'Audit trail maintenance',

    // Messages
    'trust_error_load':           'Failed to load ledger data.',
    'trust_rebalance_success':    'Daily rebalancing completed.',
    'trust_rebalance_none':       'No rebalancing needed. Ratio within threshold.',
    'trust_footer':               'CircleCash Trust & Settlement — SDG 80:20 Allocation',
    'trust_licensed':             'Licensed by Central Bank of Sudan',
  };

  static const Map<String, String> ar = {
    // Screen titles
    'trust_settlement_title':     'الثقة والتسوية',
    'trust_settlement_subtitle':  'محرك التخصيص التلقائي 80:20',
    'trust_currency_badge':       'العملة الأساسية: الجنيه السوداني (SDG)',

    // Account labels
    'trust_account_label':        'حساب الثقة',
    'trust_account_pct':          'حساب الثقة (80%)',
    'trust_badge':                'الثقة 80%',
    'trust_safeguarded':          'أموال العملاء المحمية',
    'trust_compliant':            'متوافق',
    'settlement_account_label':   'حساب التسوية',
    'settlement_account_pct':     'حساب التسوية (20%)',
    'settlement_badge':           'التسوية 20%',
    'settlement_liquidity':       'السيولة التشغيلية',
    'settlement_active':          'نشط',
    'total_badge':                'الإجمالي',
    'total_deposits':             'إجمالي ودائع العملاء',
    'last_updated':               'آخر تحديث: للتو',

    // Allocation chart
    'allocation_title':           'تخصيص الأموال في الوقت الفعلي',
    'legend_trust':               'حساب الثقة (80%) — محمي',
    'legend_settlement':          'حساب التسوية (20%) — تشغيلي',

    // Stats
    'trust_stat_ratio':           'نسبة 80:20',
    'trust_stat_txns':            'إجمالي المعاملات',
    'trust_stat_rebalances':      'إعادة التوازن اليوم',

    // Ledger
    'ledger_title':               'إدخالات دفتر الأستاذ',
    'ledger_empty':               'لا توجد معاملات بعد',
    'ledger_col_time':            'الوقت',
    'ledger_col_type':            'النوع',
    'ledger_col_account':         'الحساب',
    'ledger_col_amount':          'المبلغ',
    'ledger_col_user':            'المستخدم',
    'ledger_col_status':          'الحالة',
    'ledger_status_completed':    'مكتمل',
    'ledger_status_processing':   'قيد المعالجة',
    'ledger_type_deposit':        'إيداع',
    'ledger_type_withdrawal':     'سحب',
    'ledger_type_rebalance':      'إعادة توازن',

    // Architecture
    'arch_trust_title':           'حساب الثقة (80%)',
    'arch_trust_desc':            'يحتفظ بـ 80% من أموال العملاء في حساب حماية منفصل',
    'arch_trust_1':               'محمي من الدائنين',
    'arch_trust_2':               'الامتثال التنظيمي',
    'arch_trust_3':               'الفائدة تعود للعملاء',
    'arch_settle_title':          'حساب التسوية (20%)',
    'arch_settle_desc':           'يحافظ على 20% سيولة للعمليات اليومية',
    'arch_settle_1':              'معالجة المعاملات اليومية',
    'arch_settle_2':              'معالجة السحوبات',
    'arch_settle_3':              'المصاريف التشغيلية',
    'arch_auto_title':            'إعادة التوازن التلقائي',
    'arch_auto_desc':             'إعادة توازن تلقائية يومية عبر تكامل API البنك',
    'arch_auto_1':                'التسوية في نهاية اليوم',
    'arch_auto_2':                'تحويلات API البنك',
    'arch_auto_3':                'الحفاظ على سجل التدقيق',

    // Messages
    'trust_error_load':           'فشل تحميل بيانات دفتر الأستاذ.',
    'trust_rebalance_success':    'تمت إعادة التوازن اليومي بنجاح.',
    'trust_rebalance_none':       'لا حاجة لإعادة التوازن. النسبة ضمن الحد.',
    'trust_footer':               'نظام CircleCash للثقة والتسوية — تخصيص SDG 80:20',
    'trust_licensed':             'مرخص من بنك السودان المركزي',
  };
}
