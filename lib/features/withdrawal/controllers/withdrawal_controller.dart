// withdrawal_controller.dart  — STABLE version
// Fixes: broadened success check, Bankak fallback, proper null safety,
//        response body normalisation (content / data / direct body).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import 'package:naqde_user/helper/route_helper.dart';
import '../domain/models/withdrawal_model.dart';
import '../domain/repositories/withdrawal_repo.dart';

class WithdrawalController extends GetxController {
  final WithdrawalRepo withdrawalRepo;
  WithdrawalController({required this.withdrawalRepo});

  // ── State ─────────────────────────────────────────────────────────────────
  bool _loading    = false;
  bool _submitting = false;
  bool _methodsLoaded = false;

  List<WithdrawalMethodModel>  _methods  = [];
  WithdrawalMethodModel?       _method;
  WithdrawalLimitsModel?       _limits;
  final List<WithdrawalHistoryItem>  _history  = [];
  WithdrawalHistoryItem?       _detail;

  double  _amount  = 0.0;
  String? _amtErr;
  int     _page    = 1;
  bool    _hasMore = true;

  final Map<String, TextEditingController> fieldCtrl = {};
  final amountCtrl = TextEditingController();
  final pinCtrl    = TextEditingController();

  // ── Getters ──────────────────────────────────────────────────────────────
  bool  get isLoading    => _loading;
  bool  get isSubmitting => _submitting;
  bool  get isArabic     => Get.locale?.languageCode == 'ar';
  List<WithdrawalMethodModel> get methods  => _methods;
  WithdrawalMethodModel?      get selectedMethod => _method;
  WithdrawalLimitsModel?      get limits   => _limits;
  List<WithdrawalHistoryItem> get history  => _history;
  WithdrawalHistoryItem?      get detail   => _detail;
  double get enteredAmount => _amount;
  String? get amountError  => _amtErr;
  bool   get hasMore       => _hasMore;
  double get fee           => SdgFormatter.calculateFee(_amount);
  double get netAmount     => SdgFormatter.netAmount(_amount);

  bool get canSubmit =>
      _amount >= 1000 && _amtErr == null && _method != null &&
      pinCtrl.text.length == 4 && _fieldsOk();

  // ── Aliases for screen compatibility ──────────────────────────────────────
  TextEditingController get amountController => amountCtrl;
  TextEditingController get pinController    => pinCtrl;
  String? get errorMessage                   => _amtErr;
  Map<String, TextEditingController> get fieldControllers => fieldCtrl;
  bool get hasMoreHistory                    => _hasMore;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadMethods();
    loadLimits();
  }

  // ── Methods loader ────────────────────────────────────────────────────────
  Future<void> loadMethods({bool reload = false}) async {
    if (_methodsLoaded && !reload) return;
    _loading = true; update();

    try {
      final resp = await withdrawalRepo.getMethods();
      // normalise: accept content | data | direct list
      final raw = resp.statusCode == 200
          ? (resp.body is Map
              ? (resp.body['content'] ?? resp.body['data'] ?? [])
              : resp.body)
          : null;

      if (raw is List && raw.isNotEmpty) {
        _methods = raw
            .map((m) => WithdrawalMethodModel.fromJson(m as Map<String, dynamic>))
            .toList();
        _methodsLoaded = true;
      }
    } catch (_) {}

    // Always ensure Bankak is present as fallback
    if (_methods.isEmpty) {
      _methods = [
        WithdrawalMethodModel(
          id: 1,
          methodName: 'Bank of Khartoum (Bankak)',
          methodNameAr: 'بنك الخرطوم (بنكك)',
          fields: [
            WithdrawalFieldModel(inputName: 'account_number', placeholder: 'Account Number',
                placeholderAr: 'رقم الحساب', inputType: 'text', required: true),
            WithdrawalFieldModel(inputName: 'account_name', placeholder: 'Account Holder Name',
                placeholderAr: 'اسم صاحب الحساب', inputType: 'text', required: true),
          ],
        ),
      ];
      _methodsLoaded = true;
    }

    if (_method == null && _methods.isNotEmpty) selectMethod(_methods.first);
    _loading = false; update();
  }

  // ── Limits loader ─────────────────────────────────────────────────────────
  Future<void> loadLimits() async {
    try {
      final resp = await withdrawalRepo.getLimits();
      final raw = resp.statusCode == 200
          ? (resp.body is Map
              ? (resp.body['content'] ?? resp.body['data'] ?? resp.body)
              : null)
          : null;
      if (raw is Map<String, dynamic>) {
        _limits = WithdrawalLimitsModel.fromJson(raw);
      }
    } catch (_) {}
    update();
  }

  // ── Method selection ──────────────────────────────────────────────────────
  void selectMethod(WithdrawalMethodModel m) {
    _method = m;
    fieldCtrl.forEach((_, c) => c.dispose());
    fieldCtrl.clear();
    for (final f in m.fields) {
      fieldCtrl[f.inputName] = TextEditingController();
    }
    update();
  }

  // ── Amount ────────────────────────────────────────────────────────────────
  void onAmountChanged(String val) {
    _amount  = double.tryParse(val.replaceAll(',', '')) ?? 0.0;
    _amtErr  = _validateAmt();
    update();
  }

  String? _validateAmt() {
    if (_amount <= 0) return null;
    if (_amount < 1000) {
      return isArabic ? 'الحد الأدنى ج.س 1,000' : 'Minimum SDG 1,000';
    }
    if (_limits != null) {
      if (_amount > _limits!.singleMax) {
        return isArabic
            ? 'يتجاوز حد المعاملة الواحدة'
            : 'Exceeds single transaction limit';
      }
      if (_amount > _limits!.dailyRemaining) {
        return isArabic
            ? 'يتجاوز حدك اليومي المتبقي'
            : 'Exceeds your daily remaining limit';
      }
    }
    final bal = _walletBalance();
    if (_amount > bal) {
      return isArabic ? 'الرصيد غير كافٍ' : 'Insufficient balance';
    }
    return null;
  }

  double _walletBalance() {
    try {
      return (Get.find<ProfileController>().userInfo?.balance ?? 0).toDouble();
    } catch (_) { return 0.0; }
  }

  bool _fieldsOk() {
    if (_method == null) return false;
    for (final f in _method!.fields) {
      if (f.required &&
          (fieldCtrl[f.inputName]?.text.trim().isEmpty ?? true)) { return false; }
    }
    return true;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submitWithdrawal() async {
    if (!canSubmit) return;
    _submitting = true; update();

    final Map<String, String> vals = {};
    fieldCtrl.forEach((k, c) => vals[k] = c.text.trim());

    final body = WithdrawalRequestModel(
      methodId:    _method!.id,
      amount:      _amount,
      pin:         pinCtrl.text,
      fieldValues: vals,
    ).toJson();

    try {
      final resp = await withdrawalRepo.submitRequest(body);
      final ok = resp.statusCode == 200 &&
          resp.body != null &&
          resp.body['errors'] == null &&
          resp.body['error'] == null;

      if (ok) {
        Get.find<ProfileController>().getProfileData(reload: true);
        Get.offAllNamed(RouteHelper.getWithdrawalSuccessRoute());
      } else {
        final msg = resp.body is Map
            ? (resp.body['message'] ?? resp.body['error'] ?? '')
            : '';
        showCustomSnackBarHelper(
          msg.toString().isNotEmpty
              ? msg.toString()
              : (isArabic
                  ? 'فشل طلب السحب. يرجى المحاولة مرة أخرى.'
                  : 'Withdrawal request failed. Please try again.'),
          isError: true,
        );
      }
    } catch (e) {
      showCustomSnackBarHelper(
        isArabic ? 'خطأ في الاتصال' : 'Connection error. Please try again.',
        isError: true,
      );
    }

    _submitting = false; update();
  }

  // ── History ───────────────────────────────────────────────────────────────
  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) { _page = 1; _hasMore = true; _history.clear(); }
    if (!_hasMore) return;
    _loading = true; update();

    try {
      final resp = await withdrawalRepo.getHistory(page: _page);
      final raw  = resp.statusCode == 200
          ? (resp.body is Map
              ? (resp.body['content'] ?? resp.body['data'] ?? [])
              : [])
          : null;
      if (raw is List) {
        final items = raw
            .map((i) => WithdrawalHistoryItem.fromJson(i as Map<String, dynamic>))
            .toList();
        _history.addAll(items);
        _hasMore = items.length >= 15;
        if (_hasMore) _page++;
      }
    } catch (_) { ApiChecker.checkApi(Response(statusCode: 500)); }

    _loading = false; update();
  }

  Future<void> loadDetail(String id) async {
    _loading = true; update();
    try {
      final resp = await withdrawalRepo.getDetail(id);
      final raw = resp.statusCode == 200
          ? (resp.body is Map
              ? (resp.body['content'] ?? resp.body['data'])
              : null)
          : null;
      if (raw is Map<String, dynamic>) {
        _detail = WithdrawalHistoryItem.fromJson(raw);
      }
    } catch (_) {}
    _loading = false; update();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    amountCtrl.clear(); pinCtrl.clear();
    fieldCtrl.forEach((_, c) => c.clear());
    _amount = 0.0; _amtErr = null;
    update();
  }

  @override
  void onClose() {
    amountCtrl.dispose(); pinCtrl.dispose();
    fieldCtrl.forEach((_, c) => c.dispose());
    super.onClose();
  }
}
