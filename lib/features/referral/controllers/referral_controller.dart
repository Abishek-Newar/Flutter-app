import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import '../domain/models/referral_model.dart';
import '../domain/repositories/referral_repo.dart';

/// ReferralController
///
/// GetX controller for the CircleCash referral feature.
/// Register in get_di.dart alongside other controllers:
///   Get.lazyPut(() => ReferralController(referralRepo: Get.find()));
///
/// Used by [ReferralScreen] during the registration flow.
class ReferralController extends GetxController implements GetxService {
  final ReferralRepo referralRepo;
  ReferralController({required this.referralRepo});

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isValidating = false;
  bool _isApplying   = false;
  bool _isApplied    = false;
  bool _termsAccepted = false;
  bool _termsExpanded = false;

  ReferralCodeModel? _validatedCode;
  ReferralStatsModel? _stats;

  String? _errorMessage;
  String? _successMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isValidating  => _isValidating;
  bool get isApplying    => _isApplying;
  bool get isApplied     => _isApplied;
  bool get termsAccepted => _termsAccepted;
  bool get termsExpanded => _termsExpanded;
  bool get hasValidCode  => _validatedCode != null;

  ReferralCodeModel? get validatedCode => _validatedCode;
  ReferralStatsModel? get stats        => _stats;

  String? get errorMessage   => _errorMessage;
  String? get successMessage => _successMessage;

  bool get showError   => _errorMessage != null;
  bool get showSuccess => _successMessage != null;

  // ── Terms ─────────────────────────────────────────────────────────────────
  void toggleTerms() {
    _termsExpanded = !_termsExpanded;
    update();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    update();
  }

  // ── Message helpers ───────────────────────────────────────────────────────
  void _showError(String msg) {
    _errorMessage   = msg;
    _successMessage = null;
    update();
    Future.delayed(const Duration(seconds: 5), clearMessages);
  }

  void _showSuccess(String msg) {
    _successMessage = msg;
    _errorMessage   = null;
    update();
  }

  void clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
    update();
  }

  // ── Code Validation (real-time) ───────────────────────────────────────────

  /// Called on each keystroke. Only fires API call once code is ≥5 chars.
  /// Shows code info panel immediately on match.
  Future<void> onCodeChanged(String rawCode) async {
    final code = rawCode.toUpperCase().trim();

    if (code.isEmpty || code.length < 5) {
      _validatedCode = null;
      clearMessages();
      return;
    }

    _isValidating = true;
    update();

    try {
      final response = await referralRepo.validateCode(code);
      if (response.statusCode == 200 && response.body != null) {
        _validatedCode = ReferralCodeModel.fromJson(
          response.body['data'] as Map<String, dynamic>,
        );
        clearMessages();
      } else {
        _validatedCode = null;
        // Don't show error yet — user may still be typing
      }
    } catch (_) {
      _validatedCode = null;
    } finally {
      _isValidating = false;
      update();
    }
  }

  // ── Apply Code ────────────────────────────────────────────────────────────

  Future<bool> applyCode(String rawCode) async {
    final code = rawCode.toUpperCase().trim();

    if (code.isEmpty) {
      _showError('referral_error_empty'.tr);
      return false;
    }

    if (_validatedCode == null) {
      _showError('referral_error_invalid'.tr);
      return false;
    }

    _isApplying = true;
    update();

    try {
      final response = await referralRepo.applyCode(code);
      if (response.statusCode == 200) {
        final result = ReferralApplyResult.fromJson(
          response.body as Map<String, dynamic>,
        );

        if (result.success) {
          _isApplied = true;
          final bonus = _validatedCode!.referrerBonus;

          if (_validatedCode!.type == ReferralCodeType.vip) {
            _showSuccess('referral_success_vip'.tr);
          } else {
            _showSuccess(
              '${'referral_success'.tr} '
              '${'referral_bonus_activated'.tr.replaceAll('{bonus}', bonus.toStringAsFixed(0))}',
            );
          }
          update();
          return true;
        } else {
          _showError(
            Get.locale?.languageCode == 'ar'
                ? result.messageAr
                : result.messageEn,
          );
          return false;
        }
      } else {
        ApiChecker.checkApi(response);
        _showError('referral_error_invalid'.tr);
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

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<void> loadStats() async {
    try {
      final response = await referralRepo.getStats();
      if (response.statusCode == 200 && response.body != null) {
        _stats = ReferralStatsModel.fromJson(
          response.body['data'] as Map<String, dynamic>,
        );
        update();
      }
    } catch (_) {
      // Stats are cosmetic; fail silently and show defaults
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _isApplied      = false;
    _isApplying     = false;
    _isValidating   = false;
    _validatedCode  = null;
    _errorMessage   = null;
    _successMessage = null;
    _termsAccepted  = false;
    _termsExpanded  = false;
    update();
  }
}
