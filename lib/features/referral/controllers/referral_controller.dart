import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import '../domain/models/referral_model.dart';
import '../domain/repositories/referral_repo.dart';

class ReferralController extends GetxController implements GetxService {
  final ReferralRepo referralRepo;
  ReferralController({required this.referralRepo});

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isApplying    = false;
  bool _isApplied     = false;
  bool _termsAccepted = false;
  bool _termsExpanded = false;
  bool _loadingMyCode = false;

  MyCodeResponse? _myCode;
  ReferralStatsModel? _stats;
  String? _pendingCode;   // code currently typed in input field

  String? _errorMessage;
  String? _successMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isApplying     => _isApplying;
  bool get isApplied      => _isApplied;
  bool get termsAccepted  => _termsAccepted;
  bool get termsExpanded  => _termsExpanded;
  bool get loadingMyCode  => _loadingMyCode;

  /// True when the typed code is ≥5 chars (format valid).
  bool get hasValidCode   => (_pendingCode?.length ?? 0) >= 5;

  MyCodeResponse?    get myCode => _myCode;
  ReferralStatsModel? get stats => _stats;

  String? get errorMessage   => _errorMessage;
  String? get successMessage => _successMessage;
  bool    get showError      => _errorMessage != null;
  bool    get showSuccess    => _successMessage != null;

  // ── Terms ─────────────────────────────────────────────────────────────────
  void toggleTerms() { _termsExpanded = !_termsExpanded; update(); }
  void setTermsAccepted(bool v) { _termsAccepted = v; update(); }

  // ── Message helpers ───────────────────────────────────────────────────────
  void _showError(String msg) {
    _errorMessage = msg; _successMessage = null;
    update();
    Future.delayed(const Duration(seconds: 5), clearMessages);
  }

  void _showSuccess(String msg) {
    _successMessage = msg; _errorMessage = null;
    update();
  }

  void clearMessages() {
    _errorMessage = null; _successMessage = null;
    update();
  }

  // ── Own referral code ─────────────────────────────────────────────────────

  Future<void> loadMyCode() async {
    _loadingMyCode = true;
    update();
    try {
      final response = await referralRepo.getMyCode();
      if (response.statusCode == 200 && response.body != null) {
        _myCode = MyCodeResponse.fromJson(response.body as Map<String, dynamic>);
        update();
      }
    } catch (_) {
      // Fail silently — own code is cosmetic on this screen
    } finally {
      _loadingMyCode = false;
      update();
    }
  }

  // ── Code input (format validation only — no API call per keystroke) ────────

  void onCodeChanged(String rawCode) {
    _pendingCode = rawCode.toUpperCase().trim();
    clearMessages();
    update();
  }

  // ── Apply a friend's referral code ────────────────────────────────────────

  Future<bool> applyCode(String rawCode) async {
    final code = rawCode.toUpperCase().trim();
    if (code.isEmpty) { _showError('referral_error_empty'.tr); return false; }
    if (code.length < 5) { _showError('referral_error_invalid'.tr); return false; }

    _isApplying = true;
    update();

    try {
      final response = await referralRepo.applyCode(code);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body as Map<String, dynamic>;
        final ok = body['status'] == 'success' || body['success'] == true;
        if (ok) {
          _isApplied = true;
          final bonus = (body['data']?['bonus_credited'] ?? body['bonus_credited'] ?? 0) as num;
          _showSuccess(bonus > 0
              ? '${'referral_success'.tr} (+${bonus.toStringAsFixed(0)} SDG)'
              : 'referral_success'.tr);
          // Refresh own code/stats
          await loadMyCode();
          return true;
        } else {
          final msg = _localizedMessage(body);
          _showError(msg.isNotEmpty ? msg : 'referral_error_invalid'.tr);
          return false;
        }
      } else {
        ApiChecker.checkApi(response);
        final msg = response.body is Map ? _localizedMessage(response.body as Map<String, dynamic>) : '';
        _showError(msg.isNotEmpty ? msg : 'referral_error_invalid'.tr);
        return false;
      }
    } catch (_) {
      _showError('referral_error_invalid'.tr);
      return false;
    } finally {
      _isApplying = false;
      update();
    }
  }

  String _localizedMessage(Map<String, dynamic> body) {
    final isAr = Get.locale?.languageCode == 'ar';
    return (isAr
        ? body['message_ar'] ?? body['message']
        : body['message'])?.toString() ?? '';
  }

  // ── Stats (global program stats only) ────────────────────────────────────

  Future<void> loadStats() async {
    try {
      final response = await referralRepo.getStats();
      if (response.statusCode == 200 && response.body != null) {
        final data = (response.body['data'] ?? response.body) as Map<String, dynamic>;
        _stats = ReferralStatsModel.fromJson(data);
        update();
      }
    } catch (_) {
      // Stats are cosmetic; fail silently
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _isApplied      = false;
    _isApplying     = false;
    _pendingCode    = null;
    _errorMessage   = null;
    _successMessage = null;
    _termsAccepted  = false;
    _termsExpanded  = false;
    update();
  }
}
