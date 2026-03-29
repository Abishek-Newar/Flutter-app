import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import 'package:naqde_user/util/app_constants.dart';
import '../domain/models/otp_model.dart';

/// OTP Verification Controller
///
/// Bilingual GetX controller for the CircleCash OTP verification flow.
/// Extends the existing six_cash GetX + API client pattern.
///
/// Supports 4 delivery methods: SMS, WhatsApp, Email, Push.
/// Timer counts down from [AppConstants.otpResendTime] seconds.
/// Cooldown of 30s is enforced before resend is available.
class OtpVerificationController extends GetxController
    implements GetxService {
  final ApiClient apiClient;
  OtpVerificationController({required this.apiClient});

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _canResend = false;
  bool _isAgentRequesting = false;

  String? _otp;
  OtpMethod _selectedMethod = OtpMethod.sms;
  int _secondsLeft = 120;    // countdown to expiry
  int _resendCooldown = 0;   // cooldown after resend

  Timer? _countdownTimer;
  Timer? _resendCooldownTimer;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isVerifying => _isVerifying;
  bool get canResend => _canResend;
  bool get isExpired => _secondsLeft <= 0;
  bool get isAgentRequesting => _isAgentRequesting;
  bool get isOtpComplete => (_otp?.length ?? 0) == 6;

  String? get otp => _otp;
  OtpMethod get selectedMethod => _selectedMethod;
  int get secondsLeft => _secondsLeft;
  int get resendCooldown => _resendCooldown;

  String get countdownDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isCountdownWarning => _secondsLeft <= 30 && _secondsLeft > 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  void init({OtpMethod method = OtpMethod.sms}) {
    _selectedMethod = method;
    startCountdown();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.onClose();
  }

  // ── OTP Input ─────────────────────────────────────────────────────────────
  void setOtp(String? value) {
    _otp = value;
    update();
  }

  void clearOtp() {
    _otp = null;
    update();
  }

  // ── Method Selection ──────────────────────────────────────────────────────
  void selectMethod(OtpMethod method) {
    if (_selectedMethod == method) return;
    _selectedMethod = method;
    clearOtp();
    hideMessage();
    update();
    // Auto-resend with new method — phoneOrEmail is managed at the screen level
    // so we skip auto-send here and let the screen trigger it
    update();
  }

  // ── Countdown Timer ───────────────────────────────────────────────────────
  void startCountdown({int? seconds}) {
    _countdownTimer?.cancel();
    _secondsLeft = seconds ?? 120;
    _canResend = false;
    update();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        update();
      } else {
        _canResend = true;
        _countdownTimer?.cancel();
        update();
      }
    });
  }

  void cancelTimers() {
    _countdownTimer?.cancel();
    _resendCooldownTimer?.cancel();
  }

  void _startResendCooldown() {
    _resendCooldown = 30;
    _canResend = false;
    update();

    _resendCooldownTimer?.cancel();
    _resendCooldownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendCooldown > 0) {
        _resendCooldown--;
        update();
      } else {
        _canResend = true;
        _resendCooldownTimer?.cancel();
        update();
      }
    });
  }

  // ── Message State ─────────────────────────────────────────────────────────
  String? _messageText;
  bool _isSuccessMessage = true;
  bool _showMessage = false;

  bool get showMessage => _showMessage;
  String? get messageText => _messageText;
  bool get isSuccessMessage => _isSuccessMessage;

  void showStatusMessage(String text, {bool isSuccess = true}) {
    _messageText = text;
    _isSuccessMessage = isSuccess;
    _showMessage = true;
    update();
    Future.delayed(const Duration(seconds: 5), hideMessage);
  }

  void hideMessage() {
    _showMessage = false;
    update();
  }

  // ── API Calls ─────────────────────────────────────────────────────────────

  /// Send OTP to device via selected method.
  /// [silent] = true means no success snackbar (used on method switch).
  Future<void> sendOtp({
    required String phoneOrEmail,
    bool silent = false,
  }) async {
    _isLoading = true;
    update();

    try {
      final response = await apiClient.postData(
        AppConstants.otpSendUri,
        {
          'identifier': phoneOrEmail,
          'method': _selectedMethod.key,
        },
      );

      if (response.statusCode == 200) {
        startCountdown();
        _startResendCooldown();
        if (!silent) {
          final methodLabel = Get.locale?.languageCode == 'ar'
              ? _selectedMethod.labelAr()
              : _selectedMethod.labelEn();
          showStatusMessage(
            'otp_resend_success'
                .tr
                .replaceAll('{method}', methodLabel),
            isSuccess: true,
          );
        }
      } else {
        showStatusMessage('otp_error_invalid'.tr, isSuccess: false);
      }
    } catch (e) {
      showStatusMessage('otp_error_invalid'.tr, isSuccess: false);
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Verify OTP code entered by user.
  Future<bool> verifyOtp({
    required String phoneOrEmail,
    required String pin,
    required bool isForgetPassword,
  }) async {
    if (pin.length != 6) {
      showStatusMessage('otp_error_invalid'.tr, isSuccess: false);
      return false;
    }

    _isVerifying = true;
    update();

    try {
      final response = await apiClient.postData(
        AppConstants.otpVerifyUri,
        {
          'identifier': phoneOrEmail,
          'otp': pin,
          'method': _selectedMethod.key,
          'type': isForgetPassword ? 'forgot_password' : 'registration',
        },
      );

      if (response.statusCode == 200) {
        cancelTimers();
        showStatusMessage('otp_success'.tr, isSuccess: true);
        return true;
      } else {
        final msg = response.body?['message'] ?? 'otp_error_invalid'.tr;
        showStatusMessage(msg, isSuccess: false);
        return false;
      }
    } catch (e) {
      showStatusMessage('otp_error_invalid'.tr, isSuccess: false);
      return false;
    } finally {
      _isVerifying = false;
      update();
    }
  }

  /// Resend OTP — only callable when [canResend] is true.
  Future<void> resendOtp({required String phoneOrEmail}) async {
    if (!_canResend) return;
    await sendOtp(phoneOrEmail: phoneOrEmail, silent: false);
  }

  /// Request agent/human callback for verification assistance.
  Future<void> requestAgentCallback({required String phoneOrEmail}) async {
    _isAgentRequesting = true;
    update();

    try {
      final response = await apiClient.postData(
        AppConstants.otpAgentRequestUri,
        {'identifier': phoneOrEmail},
      );

      if (response.statusCode == 200) {
        showCustomSnackBarHelper('otp_callback_requested'.tr, isError: false);
      } else {
        showCustomSnackBarHelper('otp_error_invalid'.tr, isError: true);
      }
    } catch (_) {
      showCustomSnackBarHelper('otp_error_invalid'.tr, isError: true);
    } finally {
      _isAgentRequesting = false;
      update();
    }
  }
}
