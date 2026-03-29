/// Account type enum — mirrors LedgerAccount constants in Laravel
enum TrustAccountType { trust, settlement }

extension TrustAccountTypeExt on TrustAccountType {
  String get key   => this == TrustAccountType.trust ? 'trust' : 'settlement';
  String get label => this == TrustAccountType.trust ? 'trust_account_pct' : 'settlement_account_pct';
  double get ratio => this == TrustAccountType.trust ? 0.8 : 0.2;

  static TrustAccountType fromString(String s) =>
      s == 'settlement' ? TrustAccountType.settlement : TrustAccountType.trust;
}

/// Ledger transaction type
enum LedgerTxType { deposit, withdrawal, rebalance }

extension LedgerTxTypeExt on LedgerTxType {
  String get key {
    switch (this) {
      case LedgerTxType.deposit:    return 'deposit';
      case LedgerTxType.withdrawal: return 'withdrawal';
      case LedgerTxType.rebalance:  return 'rebalance';
    }
  }

  static LedgerTxType fromString(String s) {
    switch (s) {
      case 'withdrawal': return LedgerTxType.withdrawal;
      case 'rebalance':  return LedgerTxType.rebalance;
      default:           return LedgerTxType.deposit;
    }
  }
}

/// One ledger entry row (a sub-record within a parent transaction)
class LedgerEntryModel {
  final int          id;
  final int          transactionId;
  final TrustAccountType account;
  final double       amount;      // positive = credit, negative = debit
  final double       balanceAfter;
  final String       description;
  final DateTime     createdAt;
  final String       currency;

  LedgerEntryModel({
    required this.id,
    required this.transactionId,
    required this.account,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
    this.currency = 'SDG',
  });

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id:            json['id'] as int,
      transactionId: json['transaction_id'] as int,
      account:       TrustAccountTypeExt.fromString(json['account_type'] as String? ?? 'trust'),
      amount:        (json['amount'] as num).toDouble(),
      balanceAfter:  (json['balance_after'] as num).toDouble(),
      description:   json['description'] as String? ?? '',
      createdAt:     DateTime.parse(json['created_at'] as String),
      currency:      json['currency'] as String? ?? 'SDG',
    );
  }
}

/// A processed transaction (parent record with two ledger splits)
class TrustTransactionModel {
  final int          id;
  final int          userId;
  final double       amount;
  final LedgerTxType type;
  final String       status;
  final double       trustAmount;      // 80%
  final double       settlementAmount; // 20%
  final DateTime     createdAt;
  final String       currency;
  final List<LedgerEntryModel> entries;

  TrustTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.trustAmount,
    required this.settlementAmount,
    required this.createdAt,
    this.currency = 'SDG',
    this.entries  = const [],
  });

  factory TrustTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['ledger_entries'] as List<dynamic>? ?? [];
    return TrustTransactionModel(
      id:               json['id'] as int,
      userId:           json['user_id'] as int,
      amount:           (json['amount'] as num).toDouble(),
      type:             LedgerTxTypeExt.fromString(json['type'] as String? ?? 'deposit'),
      status:           json['status'] as String? ?? 'completed',
      trustAmount:      (json['trust_amount'] as num).toDouble(),
      settlementAmount: (json['settlement_amount'] as num).toDouble(),
      createdAt:        DateTime.parse(json['created_at'] as String),
      currency:         json['currency'] as String? ?? 'SDG',
      entries:          rawEntries
          .map((e) => LedgerEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Snapshot of both account balances  (GET /trust/balances)
class TrustBalanceModel {
  final double trustBalance;
  final double settlementBalance;
  final double totalBalance;
  final double trustRatio;        // current actual ratio (ideally 0.80)
  final double settlementRatio;   // current actual ratio (ideally 0.20)
  final bool   isCompliant;       // true when ratios are within ±1% tolerance
  final DateTime updatedAt;
  final int    totalTransactions;
  final int    rebalancesToday;

  TrustBalanceModel({
    required this.trustBalance,
    required this.settlementBalance,
    required this.totalBalance,
    required this.trustRatio,
    required this.settlementRatio,
    required this.isCompliant,
    required this.updatedAt,
    required this.totalTransactions,
    required this.rebalancesToday,
  });

  factory TrustBalanceModel.fromJson(Map<String, dynamic> json) {
    final trust      = (json['trust_balance']      as num).toDouble();
    final settlement = (json['settlement_balance'] as num).toDouble();
    final total      = trust + settlement;
    return TrustBalanceModel(
      trustBalance:      trust,
      settlementBalance: settlement,
      totalBalance:      total,
      trustRatio:        total > 0 ? trust / total      : 0.8,
      settlementRatio:   total > 0 ? settlement / total : 0.2,
      isCompliant:       json['is_compliant'] as bool? ?? true,
      updatedAt:         DateTime.parse(json['updated_at'] as String),
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      rebalancesToday:   (json['rebalances_today']   as num?)?.toInt() ?? 0,
    );
  }

  /// Calculated allocation split for a given amount
  static Map<String, double> split(double amount, {bool isDeposit = true}) {
    final sign = isDeposit ? 1.0 : -1.0;
    return {
      'trust':      amount * 0.8 * sign,
      'settlement': amount * 0.2 * sign,
      'total':      amount * sign,
    };
  }

  /// Format SDG number: 1500000 → "SDG 1,500,000.00"
  static String formatSdg(double amount) {
    final abs  = amount.abs();
    final sign = amount < 0 ? '-' : '';
    // Manual comma formatting
    final parts   = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final dec     = parts[1];
    final buffer  = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '${sign}SDG $formatted.$dec';
  }
}

/// Result of POST /trust/rebalance
class RebalanceResultModel {
  final bool   rebalanced;
  final double transferAmount;
  final TrustAccountType? direction; // null if no rebalance needed
  final String messageEn;
  final String messageAr;

  RebalanceResultModel({
    required this.rebalanced,
    required this.transferAmount,
    this.direction,
    required this.messageEn,
    required this.messageAr,
  });

  factory RebalanceResultModel.fromJson(Map<String, dynamic> json) {
    return RebalanceResultModel(
      rebalanced:     json['rebalanced'] as bool? ?? false,
      transferAmount: (json['transfer_amount'] as num?)?.toDouble() ?? 0,
      direction:      json['direction'] != null
          ? TrustAccountTypeExt.fromString(json['direction'] as String)
          : null,
      messageEn:      json['message']    as String? ?? '',
      messageAr:      json['message_ar'] as String? ?? '',
    );
  }
}
