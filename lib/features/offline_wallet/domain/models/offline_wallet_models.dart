// lib/features/offline_wallet/domain/models/offline_wallet_models.dart
// All data models for the Offline Wallet feature.

// ── Enums ─────────────────────────────────────────────────────────────────────

enum TransactionStatus { confirmed, pending, rejected, disputed, relayed }

enum TransmissionMethod { online, bluetooth, nfc, sms }

enum SyncStatus { idle, syncing, completed, failed, offline }

enum NFCEventType { writeSuccess, transactionReceived, error, scanning }

// ── Wallet Balance ─────────────────────────────────────────────────────────────

class WalletBalance {
  final double confirmed;
  final double pending;
  final double spendable;
  final bool isFrozen;

  const WalletBalance({
    required this.confirmed,
    required this.pending,
    required this.spendable,
    required this.isFrozen,
  });

  factory WalletBalance.empty() => const WalletBalance(
        confirmed: 0,
        pending: 0,
        spendable: 0,
        isFrozen: false,
      );

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        confirmed: (json['confirmed'] as num?)?.toDouble() ?? 0,
        pending: (json['pending'] as num?)?.toDouble() ?? 0,
        spendable: (json['spendable'] as num?)?.toDouble() ?? 0,
        isFrozen: json['is_frozen'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'confirmed': confirmed,
        'pending': pending,
        'spendable': spendable,
        'is_frozen': isFrozen,
      };
}

// ── Offline Transaction ────────────────────────────────────────────────────────

class OfflineTransaction {
  final String id;
  final String senderWalletId;
  final String receiverWalletId;
  final double amount;
  final DateTime timestamp;
  final TransactionStatus status;
  final TransmissionMethod method;
  final String? note;
  final String signedPayload;
  final bool synced;

  const OfflineTransaction({
    required this.id,
    required this.senderWalletId,
    required this.receiverWalletId,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.method,
    this.note,
    required this.signedPayload,
    this.synced = false,
  });

  bool get isOutgoing => senderWalletId == _currentWalletId;

  // Set this via OfflineWalletController after login
  static String _currentWalletId = '';
  static void setCurrentWalletId(String id) => _currentWalletId = id;

  factory OfflineTransaction.fromMap(Map<String, dynamic> map) =>
      OfflineTransaction(
        id: map['id'] as String,
        senderWalletId: map['sender_wallet_id'] as String,
        receiverWalletId: map['receiver_wallet_id'] as String,
        amount: (map['amount'] as num).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        status: TransactionStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'pending'),
          orElse: () => TransactionStatus.pending,
        ),
        method: TransmissionMethod.values.firstWhere(
          (m) => m.name == (map['method'] as String? ?? 'online'),
          orElse: () => TransmissionMethod.online,
        ),
        note: map['note'] as String?,
        signedPayload: map['signed_payload'] as String,
        synced: (map['synced'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_wallet_id': senderWalletId,
        'receiver_wallet_id': receiverWalletId,
        'amount': amount,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'status': status.name,
        'method': method.name,
        'note': note,
        'signed_payload': signedPayload,
        'synced': synced ? 1 : 0,
      };

  OfflineTransaction copyWith({TransactionStatus? status, bool? synced}) =>
      OfflineTransaction(
        id: id,
        senderWalletId: senderWalletId,
        receiverWalletId: receiverWalletId,
        amount: amount,
        timestamp: timestamp,
        status: status ?? this.status,
        method: method,
        note: note,
        signedPayload: signedPayload,
        synced: synced ?? this.synced,
      );
}

// ── Transaction Result ─────────────────────────────────────────────────────────

class TransactionResult {
  final bool success;
  final String message;
  final String? transactionId;
  final TransactionStatus? status;

  const TransactionResult({
    required this.success,
    required this.message,
    this.transactionId,
    this.status,
  });

  factory TransactionResult.success({
    required String message,
    String? transactionId,
    TransactionStatus status = TransactionStatus.pending,
  }) =>
      TransactionResult(
        success: true,
        message: message,
        transactionId: transactionId,
        status: status,
      );

  factory TransactionResult.failure(String message) =>
      TransactionResult(success: false, message: message);
}

// ── NFC Event ─────────────────────────────────────────────────────────────────

class NFCEvent {
  final NFCEventType type;
  final Map<String, dynamic>? data;

  const NFCEvent({required this.type, this.data});
}

// ── Signed Transaction (for NFC write) ────────────────────────────────────────

class SignedTransaction {
  final String id;
  final String senderWalletId;
  final String receiverWalletId;
  final double amount;
  final DateTime timestamp;
  final String signature;
  final String? note;

  const SignedTransaction({
    required this.id,
    required this.senderWalletId,
    required this.receiverWalletId,
    required this.amount,
    required this.timestamp,
    required this.signature,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_wallet_id': senderWalletId,
        'receiver_wallet_id': receiverWalletId,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'signature': signature,
        'note': note,
      };

  factory SignedTransaction.fromJson(Map<String, dynamic> json) =>
      SignedTransaction(
        id: json['id'] as String,
        senderWalletId: json['sender_wallet_id'] as String,
        receiverWalletId: json['receiver_wallet_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        signature: json['signature'] as String,
        note: json['note'] as String?,
      );
}

// ── Discovered Bluetooth Node ─────────────────────────────────────────────────

class DiscoveredNode {
  final String nodeId;
  final String? walletId;
  final int rssi;

  const DiscoveredNode({
    required this.nodeId,
    this.walletId,
    required this.rssi,
  });
}

// ── Offline Wallet Status (from API) ─────────────────────────────────────────

class OfflineWalletStatus {
  final bool isEnabled;
  final double offlineBalance;
  final double maxOfflineBalance;
  final int pendingSyncCount;
  final DateTime? lastSyncedAt;

  const OfflineWalletStatus({
    required this.isEnabled,
    required this.offlineBalance,
    required this.maxOfflineBalance,
    required this.pendingSyncCount,
    this.lastSyncedAt,
  });

  factory OfflineWalletStatus.fromJson(Map<String, dynamic> json) =>
      OfflineWalletStatus(
        isEnabled: json['is_enabled'] as bool? ?? false,
        offlineBalance: (json['offline_balance'] as num?)?.toDouble() ?? 0,
        maxOfflineBalance:
            (json['max_offline_balance'] as num?)?.toDouble() ?? 10000,
        pendingSyncCount: json['pending_sync_count'] as int? ?? 0,
        lastSyncedAt: json['last_synced_at'] != null
            ? DateTime.tryParse(json['last_synced_at'] as String)
            : null,
      );
}
