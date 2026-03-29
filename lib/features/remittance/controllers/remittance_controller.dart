// remittance_controller.dart
// Implements the complete blueprint flow:
//   Step 0 — Select corridor + payout method
//   Step 1 — Enter SDG amount → fetchQuote (10-min countdown)
//   Step 2 — Fill recipient details
//   Step 3 — Review + PIN → precheck → send
//   Step 4 — Success

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import '../domain/models/remittance_model.dart';
import '../domain/repositories/remittance_repo.dart';

class RemittanceController extends GetxController {
  final RemittanceRepo repo;
  RemittanceController({required this.repo});

  // ── Step ──────────────────────────────────────────────────────────────
  int _step = 0;
  int get step => _step;
  void goStep(int s) { _step = s; update(); }

  // ── Corridor / payout ─────────────────────────────────────────────────
  RemitCorridor? _corridor;
  PayoutMethod   _payout = PayoutMethod.bankDeposit;
  RemitCorridor? get corridor => _corridor;
  PayoutMethod   get payout   => _payout;
  bool get corridorSelected   => _corridor != null;

  void selectCorridor(RemitCorridor c) {
    _corridor = c;
    if (!c.methods.contains(_payout)) _payout = c.methods.first;
    _clearQuote();
    update();
  }

  void selectPayout(PayoutMethod m) {
    _payout = m;
    _clearQuote();
    update();
  }

  // ── Amount ────────────────────────────────────────────────────────────
  final amountCtrl = TextEditingController();
  double  _amount      = 0.0;
  String? _amountError;
  double  get amount       => _amount;
  String? get amountError  => _amountError;

  void onAmountChanged(String v) {
    _amount = double.tryParse(v.replaceAll(',', '')) ?? 0.0;
    _amountError = _validateAmount();
    _clearQuote();
    update();
  }

  String? _validateAmount() {
    if (_amount <= 0) return null;
    if (_amount < 500)       return 'remit_min'.tr;
    if (_amount > 2000000)   return 'remit_max'.tr;
    if (_amount > _balance()) return 'insufficient_balance'.tr;
    return null;
  }

  double _balance() {
    try {
      return Get.find<ProfileController>().userInfo?.balance ?? 0.0;
    } catch (_) { return 0.0; }
  }

  // ── Quote (blueprint getQuote) ────────────────────────────────────────
  RemittanceQuote? _quote;
  RemittanceQuote? get quote      => _quote;
  bool get quoteReady    => _quote != null && !_quote!.isExpired;
  bool get quoteExpired  => _quote != null &&  _quote!.isExpired;

  bool _loadingQuote = false;
  bool get loadingQuote => _loadingQuote;

  // 10-minute countdown (blueprint: expiresAt)
  Timer? _timer;
  int _countdown = 600;
  int get countdown => _countdown;
  String get countdownLabel {
    final m = _countdown ~/ 60;
    final s = (_countdown % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> fetchQuote() async {
    if (_amount < 500 || _corridor == null || _amountError != null) return;
    _loadingQuote = true; _quote = null; update();

    final resp = await repo.getQuote({
      'from_currency':        'SDG',
      'to_currency':          _corridor!.currency,
      'amount':               _amount,
      'payout_method':        _payout.code,
      'destination_country':  _corridor!.code,
    });

    if (resp.statusCode == 200 && resp.body['content'] != null) {
      _quote = RemittanceQuote.fromJson(
          resp.body['content'] as Map<String, dynamic>);
      _startTimer();
    } else {
      ApiChecker.checkApi(resp);
    }
    _loadingQuote = false; update();
  }

  void _startTimer() {
    _stopTimer();
    _countdown = _quote?.timeLeft.inSeconds.clamp(0, 600) ?? 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) { _countdown--; update(); }
      else { _quote = null; _stopTimer(); update(); }
    });
  }

  void _stopTimer()  { _timer?.cancel(); _timer = null; }
  void _clearQuote() { _quote = null; _stopTimer(); }

  // ── Recipient fields ──────────────────────────────────────────────────
  final nameCtrl    = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final emailCtrl   = TextEditingController();
  final bankCtrl    = TextEditingController();
  final accountCtrl = TextEditingController();
  final mobileCtrl  = TextEditingController();
  final pickupCtrl  = TextEditingController();
  bool _saveRecipient = false;
  bool get saveRecipient => _saveRecipient;
  void toggleSave() { _saveRecipient = !_saveRecipient; update(); }

  bool get recipientValid {
    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return false;
    switch (_payout) {
      case PayoutMethod.bankDeposit:
        return bankCtrl.text.trim().isNotEmpty && accountCtrl.text.trim().isNotEmpty;
      case PayoutMethod.mobileMoney:
      case PayoutMethod.walletTransfer:
        return mobileCtrl.text.trim().isNotEmpty;
      case PayoutMethod.cashPickup:
        return pickupCtrl.text.trim().isNotEmpty;
    }
  }

  RemittanceRecipient get _buildRecipient => RemittanceRecipient(
    name:          nameCtrl.text.trim(),
    phone:         phoneCtrl.text.trim(),
    email:         emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
    country:       _corridor!.code,
    payoutMethod:  _payout.code,
    bankName:      _payout == PayoutMethod.bankDeposit ? bankCtrl.text.trim() : null,
    accountNumber: _payout == PayoutMethod.bankDeposit ? accountCtrl.text.trim() : null,
    mobileNumber:  (_payout == PayoutMethod.mobileMoney ||
                    _payout == PayoutMethod.walletTransfer)
                   ? mobileCtrl.text.trim() : null,
    pickupLocation: _payout == PayoutMethod.cashPickup ? pickupCtrl.text.trim() : null,
  );

  // ── PIN ───────────────────────────────────────────────────────────────
  final pinCtrl = TextEditingController();
  bool get pinReady => pinCtrl.text.length >= 4;

  // ── Fraud challenge (blueprint FraudChallengeException) ───────────────
  FraudChallenge? _fraudChallenge;
  FraudChallenge? get fraudChallenge => _fraudChallenge;

  // ── Submit (blueprint sendMoney: precheck + send) ─────────────────────
  bool _submitting = false;
  bool get submitting => _submitting;

  RemittanceResult? _result;
  RemittanceResult? get result => _result;

  Future<void> submit() async {
    if (!pinReady || !quoteReady) return;
    _submitting = true; _fraudChallenge = null; update();

    // ─ Step 1: fraud pre-check (blueprint) ─────────────────────────────
    final pre = await repo.precheck({
      'quote_id':  _quote!.quoteId,
      'device_id': 'cc_device_${DateTime.now().millisecondsSinceEpoch}',
    });

    if (pre.statusCode == 200) {
      final pd = pre.body as Map<String, dynamic>;
      if (pd['decision'] == 'BLOCK') {
        showCustomSnackBarHelper('remit_blocked'.tr, isError: true);
        _submitting = false; update(); return;
      }
      if (pd['requires_verification'] == true) {
        // Blueprint: FraudChallengeException → surface as UI state
        _fraudChallenge = FraudChallenge(
          methods:   List<String>.from(pd['methods'] ?? ['sms']),
          sessionId: pd['session_id'] as String? ?? '',
        );
        _submitting = false; update(); return;
      }
    }

    // ─ Step 2: submit transaction (blueprint) ───────────────────────────
    final resp = await repo.send({
      'quote_id':  _quote!.quoteId,
      'recipient': _buildRecipient.toJson(),
      'pin':       pinCtrl.text,
      'device_id': 'cc_device_sd',
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      _result = RemittanceResult.fromJson(resp.body as Map<String, dynamic>);
      Get.find<ProfileController>().getProfileData(reload: true);
      _stopTimer();
      _step = 4;
    } else if (resp.statusCode == 202) {
      // Blueprint: 202 = fraud challenge mid-submission
      final bd = resp.body as Map<String, dynamic>;
      _fraudChallenge = FraudChallenge(
        methods: ['sms', 'email'],
        sessionId: bd['session_id'] as String? ?? '',
      );
    } else {
      showCustomSnackBarHelper(
          (resp.body['message'] as String?) ?? 'remit_failed'.tr,
          isError: true);
    }
    _submitting = false; update();
  }

  // ── Retry quote on expiry ─────────────────────────────────────────────
  Future<void> retryQuote() async {
    _clearQuote();
    await fetchQuote();
  }

  // ── History ───────────────────────────────────────────────────────────
  List<RemittanceHistoryItem> _history = [];
  bool _historyLoading = false;
  bool _hasMore = true;
  int  _histPage = 1;
  List<RemittanceHistoryItem> get history        => _history;
  bool                        get historyLoading  => _historyLoading;
  bool                        get hasMore         => _hasMore;

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) { _histPage = 1; _hasMore = true; _history.clear(); }
    if (!_hasMore) return;
    _historyLoading = true; update();
    final resp = await repo.getHistory(page: _histPage);
    if (resp.statusCode == 200 && resp.body['content'] != null) {
      final items = (resp.body['content'] as List<dynamic>)
          .map((i) => RemittanceHistoryItem.fromJson(i as Map<String, dynamic>))
          .toList();
      _history.addAll(items);
      _hasMore = items.length >= 15;
      if (_hasMore) _histPage++;
    }
    _historyLoading = false; update();
  }

  // ── Reset ─────────────────────────────────────────────────────────────
  void reset() {
    _step = 0; _corridor = null; _payout = PayoutMethod.bankDeposit;
    _amount = 0; _amountError = null; _quote = null;
    _result = null; _fraudChallenge = null; _saveRecipient = false;
    for (final c in [amountCtrl, pinCtrl, nameCtrl, phoneCtrl, emailCtrl,
                     bankCtrl, accountCtrl, mobileCtrl, pickupCtrl]) c.clear();
    _stopTimer(); update();
  }

  @override
  void onClose() {
    _stopTimer();
    for (final c in [amountCtrl, pinCtrl, nameCtrl, phoneCtrl, emailCtrl,
                     bankCtrl, accountCtrl, mobileCtrl, pickupCtrl]) c.dispose();
    super.onClose();
  }
}
