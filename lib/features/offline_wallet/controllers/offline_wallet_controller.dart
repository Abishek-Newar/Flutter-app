// lib/features/offline_wallet/controllers/offline_wallet_controller.dart
//
// GetX controller for the Offline Wallet feature.
// Wires OfflineTransactionService, NfcService, BluetoothMeshService
// and OfflineWalletRepo into the app's GetX + ApiClient pattern.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import '../domain/models/offline_wallet_models.dart';
import '../domain/repositories/offline_wallet_repo.dart';
import '../services/offline_transaction_service.dart';
import '../services/nfc_service.dart';
import '../services/bluetooth_mesh_service.dart';

class OfflineWalletController extends GetxController {
  final OfflineWalletRepo repo;

  OfflineWalletController({required this.repo});

  // ── Services (lazily initialised) ─────────────────────────────────────────
  final txService    = OfflineTransactionService();
  final nfcService   = NFCService();
  final meshService  = BluetoothMeshService();

  // ── State ─────────────────────────────────────────────────────────────────
  bool   _isLoading        = false;
  bool   _isNfcAvailable   = false;
  bool   _isSyncing        = false;
  int    _pendingSyncCount = 0;

  OfflineWalletStatus? _status;
  WalletBalance        _balance = WalletBalance.empty();
  List<OfflineTransaction> _history = [];

  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool   get isLoading        => _isLoading;
  bool   get isNfcAvailable   => _isNfcAvailable;
  bool   get isSyncing        => _isSyncing;
  int    get pendingSyncCount => _pendingSyncCount;
  bool   get isArabic         => Get.locale?.languageCode == 'ar';

  OfflineWalletStatus? get status  => _status;
  WalletBalance        get balance => _balance;
  List<OfflineTransaction> get history => _history;
  String? get errorMessage => _errorMessage;

  double get offlineBalance   => _balance.spendable;
  double get maxOfflineBalance => 10000.0;

  // SDG formatter
  String formatSdg(double amount) {
    final formatted = amount.toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return isArabic ? 'ج.س $formatted' : 'SDG $formatted';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initWallet();
  }

  @override
  void onClose() {
    txService.dispose();
    nfcService.dispose();
    meshService.dispose();
    super.onClose();
  }

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> _initWallet() async {
    _isLoading = true;
    update();

    try {
      // Get wallet ID from profile controller
      final profile = Get.find<ProfileController>();
      final walletId = profile.userInfo?.uniqueId ?? 'default_wallet';

      // Initialise local sqflite service
      await txService.init(walletId: walletId);

      // Initialise hardware services
      await meshService.initialize();
      _isNfcAvailable = await nfcService.isNfcAvailable();

      // Load status from API
      await loadStatus();

      // Subscribe to balance stream
      txService.balanceStream.listen((b) {
        _balance = b;
        update();
      });

      // Subscribe to sync status stream
      txService.syncStatusStream.listen((s) {
        _isSyncing = s == SyncStatus.syncing;
        update();
      });

      // Subscribe to recent transactions
      txService.recentTransactionsStream.listen((txns) {
        _pendingSyncCount = txns.where((t) => !t.synced).length;
        update();
      });

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> loadStatus() async {
    try {
      final response = await repo.getStatus();
      if (response.statusCode == 200 && response.body != null) {
        _status = OfflineWalletStatus.fromJson(response.body);
        update();
      }
    } catch (_) {
      // Offline — use local state
    }
  }

  Future<void> loadHistory() async {
    _history = await txService.getTransactionHistory(limit: 50);
    update();
  }

  // ── Payment Actions ───────────────────────────────────────────────────────

  Future<bool> sendPayment({
    required String recipientWalletId,
    required double amount,
    required String pin,
    String? note,
    bool useNfc       = false,
    bool useBluetooth = false,
    bool useSms       = false,
    String? smsPhone,
  }) async {
    final result = await txService.createPayment(
      recipientWalletId: recipientWalletId,
      amount: amount,
      pin: pin,
      note: note,
      useNFC: useNfc,
      useBluetooth: useBluetooth,
      useSMS: useSms,
      smsRecipientPhone: smsPhone,
    );

    if (result.success) {
      showCustomSnackBarHelper(result.message, isError: false);
    } else {
      showCustomSnackBarHelper(result.message, isError: true);
    }

    await loadHistory();
    return result.success;
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<void> syncNow() async {
    _isSyncing = true;
    update();
    await txService.syncWithBackend();
    _isSyncing = false;
    await loadHistory();
    update();
  }

  // ── NFC Actions ───────────────────────────────────────────────────────────

  /// Initiate NFC send — call this before navigating to NFCTransferScreen
  Future<bool> checkNfcAvailable() async {
    _isNfcAvailable = await nfcService.isNfcAvailable();
    update();
    return _isNfcAvailable;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return isArabic ? 'مبلغ غير صالح' : 'Invalid amount';
    }
    if (amount < 1) {
      return isArabic ? 'الحد الأدنى ج.س 1' : 'Minimum SDG 1';
    }
    if (amount > offlineBalance) {
      return isArabic ? 'الرصيد غير كافٍ' : 'Insufficient balance';
    }
    if (amount > maxOfflineBalance) {
      return isArabic
          ? 'الحد الأقصى ج.س 10,000'
          : 'Maximum SDG 10,000';
    }
    return null;
  }
}
