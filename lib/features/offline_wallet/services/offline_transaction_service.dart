// lib/features/offline_wallet/services/offline_transaction_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../domain/models/offline_wallet_models.dart';

class OfflineTransactionService {
  static const String _tableName     = 'offline_transactions';
  static const double _maxOfflineBal = 10000.0;
  static const Duration _txExpiry    = Duration(hours: 24);

  Database? _db;
  String _walletId      = '';
  double _offlineBalance = 0.0;
  bool   _initialized   = false;

  final _balanceCtrl    = StreamController<WalletBalance>.broadcast();
  final _recentTxCtrl   = StreamController<List<OfflineTransaction>>.broadcast();
  final _syncStatusCtrl = StreamController<SyncStatus>.broadcast();
  StreamSubscription?   _connectivitySub;

  Stream<WalletBalance>            get balanceStream          => _balanceCtrl.stream;
  Stream<List<OfflineTransaction>> get recentTransactionsStream => _recentTxCtrl.stream;
  Stream<SyncStatus>               get syncStatusStream        => _syncStatusCtrl.stream;
  String                           get currentWalletId         => _walletId;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init({required String walletId, double initialBalance = 0}) async {
    if (_initialized) return;
    _walletId       = walletId;
    _offlineBalance = initialBalance.clamp(0, _maxOfflineBal);
    OfflineTransaction.setCurrentWalletId(walletId);

    final dbPath = p.join(await getDatabasesPath(), 'circlecash_offline.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE $_tableName (
          id                 TEXT PRIMARY KEY,
          sender_wallet_id   TEXT NOT NULL,
          receiver_wallet_id TEXT NOT NULL,
          amount             REAL NOT NULL,
          timestamp          INTEGER NOT NULL,
          status             TEXT DEFAULT 'pending',
          method             TEXT NOT NULL,
          note               TEXT,
          signed_payload     TEXT NOT NULL,
          synced             INTEGER DEFAULT 0
        )
      ''');
    });

    _initialized = true;
    await _expireOldTransactions();
    await _refreshStreams();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final r = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (r != ConnectivityResult.none) syncWithBackend();
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
    _balanceCtrl.close();
    _recentTxCtrl.close();
    _syncStatusCtrl.close();
    _db?.close();
  }

  // ── Create Payment ────────────────────────────────────────────────────────

  Future<TransactionResult> createPayment({
    required String recipientWalletId,
    required double amount,
    required String pin,
    String?  note,
    bool useBluetooth = false,
    bool useNFC       = false,
    bool useSMS       = false,
    String? smsRecipientPhone,
  }) async {
    if (!_initialized) return TransactionResult.failure('Wallet not initialized');
    if (recipientWalletId.trim() == _walletId) {
      return TransactionResult.failure('Cannot send to your own wallet');
    }
    if (amount <= 0 || amount > _offlineBalance) {
      return TransactionResult.failure('Insufficient offline balance');
    }

    final method = useBluetooth ? TransmissionMethod.bluetooth
        : useNFC ? TransmissionMethod.nfc
        : useSMS ? TransmissionMethod.sms
        : TransmissionMethod.online;

    final tx = _buildTransaction(
      recipientWalletId: recipientWalletId,
      amount: amount,
      method: method,
      note: note,
    );

    await _saveTransaction(tx);
    _offlineBalance -= amount;
    await _refreshStreams();

    return TransactionResult.success(
      message: method == TransmissionMethod.online
          ? 'Transaction pending — will sync when connected'
          : 'Transaction queued via ${method.name}',
      transactionId: tx.id,
    );
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<void> syncWithBackend() async {
    if (!_initialized) return;
    _syncStatusCtrl.add(SyncStatus.syncing);
    try {
      final pending = await _getPendingTransactions();
      if (pending.isEmpty) { _syncStatusCtrl.add(SyncStatus.completed); return; }
      await Future.delayed(const Duration(milliseconds: 600));
      for (final tx in pending) { await _markSynced(tx.id); }
      _syncStatusCtrl.add(SyncStatus.completed);
    } catch (_) {
      _syncStatusCtrl.add(SyncStatus.failed);
    }
    await _refreshStreams();
  }

  // ── History / Balance ─────────────────────────────────────────────────────

  Future<List<OfflineTransaction>> getTransactionHistory({int limit = 50}) async {
    if (_db == null) return [];
    final rows = await _db!.query(_tableName, orderBy: 'timestamp DESC', limit: limit);
    return rows.map(OfflineTransaction.fromMap).toList();
  }

  Future<WalletBalance> getBalance() async {
    if (_db == null) return WalletBalance.empty();
    final rows = await _db!.query(_tableName,
        where: "status = 'pending' AND sender_wallet_id = ?",
        whereArgs: [_walletId]);
    final pendingAmt = rows.fold<double>(0, (s, r) => s + (r['amount'] as num).toDouble());
    return WalletBalance(
      confirmed:  _offlineBalance,
      pending:    pendingAmt,
      spendable:  (_offlineBalance - pendingAmt).clamp(0, _maxOfflineBal),
      isFrozen:   false,
    );
  }

  // ── Private ───────────────────────────────────────────────────────────────

  OfflineTransaction _buildTransaction({
    required String recipientWalletId,
    required double amount,
    required TransmissionMethod method,
    String? note,
  }) {
    final id      = _generateId();
    final payload = _signPayload(id: id, sender: _walletId, receiver: recipientWalletId, amount: amount);
    return OfflineTransaction(
      id:               id,
      senderWalletId:   _walletId,
      receiverWalletId: recipientWalletId,
      amount:           amount,
      timestamp:        DateTime.now(),
      status:           TransactionStatus.pending,
      method:           method,
      note:             note,
      signedPayload:    payload,
    );
  }

  String _generateId() {
    final rand  = Random.secure();
    final bytes = List<int>.generate(12, (_) => rand.nextInt(256));
    return 'OW-${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';
  }

  String _signPayload({required String id, required String sender, required String receiver, required double amount}) {
    final raw     = '$id:$sender:$receiver:${amount.toStringAsFixed(2)}:${DateTime.now().millisecondsSinceEpoch}';
    final encoded = base64Url.encode(utf8.encode(raw));
    return encoded;
  }

  Future<void> _saveTransaction(OfflineTransaction tx) async =>
      await _db?.insert(_tableName, tx.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<OfflineTransaction>> _getPendingTransactions() async {
    if (_db == null) return [];
    final rows = await _db!.query(_tableName, where: 'synced = 0', orderBy: 'timestamp ASC');
    return rows.map(OfflineTransaction.fromMap).toList();
  }

  Future<void> _markSynced(String id) async =>
      await _db?.update(_tableName, {'synced': 1, 'status': 'confirmed'}, where: 'id = ?', whereArgs: [id]);

  Future<void> _expireOldTransactions() async {
    final cutoff = DateTime.now().subtract(_txExpiry).millisecondsSinceEpoch;
    await _db?.update(_tableName, {'status': 'rejected'},
        where: "synced = 0 AND status = 'pending' AND timestamp < ?", whereArgs: [cutoff]);
  }

  Future<void> _refreshStreams() async {
    _balanceCtrl.add(await getBalance());
    _recentTxCtrl.add(await getTransactionHistory(limit: 20));
  }
}
