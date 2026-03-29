import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_large_widget.dart';
import 'package:naqde_user/common/widgets/custom_logo_widget.dart';
import 'package:naqde_user/features/auth/controllers/auth_controller.dart';
import 'package:naqde_user/features/auth/controllers/create_account_controller.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/otp_verification_controller.dart';
import '../domain/models/otp_model.dart';
import '../widgets/otp_step_indicator.dart';
import '../widgets/otp_method_selector.dart';
import '../widgets/otp_digit_input.dart';
import '../widgets/otp_timer_section.dart';
import '../widgets/otp_agent_section.dart';
import '../widgets/otp_message_banner.dart';

/// Bilingual OTP Verification Screen for CircleCash.
///
/// Usage:
/// ```dart
/// Get.to(() => const OtpVerificationScreen());
/// // or with phone number for forgot-password:
/// Get.to(() => const OtpVerificationScreen(phoneNumber: '+249123456789'));
/// ```
///
/// Parameters:
///   [phoneNumber]      — Passed when this screen is used for forgot-password flow.
///                        When null, uses phone from [CreateAccountController].
///   [isForgetPassword] — Set true when coming from forgot-password flow.
class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final bool isForgetPassword;

  const OtpVerificationScreen({
    Key? key,
    this.phoneNumber,
    this.isForgetPassword = false,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GlobalKey<OtpDigitInputState> _otpInputKey =
      GlobalKey<OtpDigitInputState>();

  String get _identifier {
    if (widget.phoneNumber != null) return widget.phoneNumber!;
    return Get.find<CreateAccountController>().phoneNumber ?? '';
  }

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<OtpVerificationController>();
    ctrl.init();
  }

  @override
  void dispose() {
    Get.find<OtpVerificationController>().cancelTimers();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final ctrl = Get.find<OtpVerificationController>();
    final otp = ctrl.otp ?? '';

    final success = await ctrl.verifyOtp(
      phoneOrEmail: _identifier,
      pin: otp,
      isForgetPassword: widget.isForgetPassword,
    );

    if (success && mounted) {
      // Delegate to AuthController for navigation (same as existing flow)
      if (widget.isForgetPassword) {
        Get.find<AuthController>().verificationForForgetPass(
          _identifier,
          otp,
        );
      } else {
        Get.find<AuthController>().phoneVerify(_identifier, otp);
      }
    } else {
      // Shake + clear on failure
      _otpInputKey.currentState?.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppbarWidget(
        title: 'otp_secure_verification'.tr,
        onTap: () {
          Get.find<OtpVerificationController>().cancelTimers();
          Get.back();
        },
        // Language toggle action
        actionWidget: _LanguageToggleButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Step indicator
                    const OtpStepIndicator(currentStep: 3, totalSteps: 4),

                    // Logo + info
                    const CustomLogoWidget(height: 64, width: 64),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      'otp_secure_verification'.tr,
                      style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraOverLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _PhoneEmailRow(identifier: _identifier),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    // Status message banner
                    const OtpMessageBanner(),

                    // Method selector
                    const OtpMethodSelector(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Agent help section
                    OtpAgentSection(identifier: _identifier),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Method badge (active method label)
                    _MethodBadge(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // OTP input label
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'otp_enter_code'.tr,
                        style: rubikSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 6-digit input
                    OtpDigitInput(
                      key: _otpInputKey,
                      onCompleted: (otp) {
                        // Auto-submit when all 6 entered
                        _handleVerify();
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Countdown + resend
                    OtpTimerSection(
                      identifier: _identifier,
                      isForgetPassword: widget.isForgetPassword,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  ],
                ),
              ),
            ),

            // Sticky Verify button
            _VerifyButton(onTap: _handleVerify),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

/// Masked phone + email row shown under the title.
class _PhoneEmailRow extends StatelessWidget {
  final String identifier;
  const _PhoneEmailRow({Key? key, required this.identifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
            text: 'we_have_send_the_code'.tr + ' ',
            style: rubikLight.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          TextSpan(
            text: _maskIdentifier(identifier),
            style: rubikSemiBold.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        ]),
      ),
    );
  }

  String _maskIdentifier(String id) {
    if (id.contains('@')) {
      // Email mask
      final parts = id.split('@');
      final name = parts[0];
      final masked = name.length > 3
          ? name.substring(0, 3) + '***'
          : '***';
      return '$masked@${parts[1]}';
    }
    // Phone mask — show last 4 digits
    if (id.length > 4) {
      return '**** ${id.substring(id.length - 4)}';
    }
    return id;
  }
}

/// Chip showing the currently selected delivery method.
class _MethodBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerificationController>(
      builder: (ctrl) {
        final isAr = Get.locale?.languageCode == 'ar';
        final label = isAr
            ? ctrl.selectedMethod.labelAr()
            : ctrl.selectedMethod.labelEn();

        final icons = {
          OtpMethod.sms: Icons.sms_outlined,
          OtpMethod.whatsapp: Icons.chat_outlined,
          OtpMethod.email: Icons.email_outlined,
          OtpMethod.push: Icons.notifications_outlined,
        };

        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[ctrl.selectedMethod]!,
                    color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: rubikSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Sticky verify button at the bottom of the screen.
class _VerifyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VerifyButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GetBuilder<OtpVerificationController>(
        builder: (ctrl) {
          final isActive = ctrl.isOtpComplete && !ctrl.isVerifying;
          return CustomLargeButtonWidget(
            text: ctrl.isVerifying
                ? 'otp_verifying'.tr
                : 'otp_verify_continue'.tr,
            isLoading: ctrl.isVerifying,
            fontSize: Dimensions.fontSizeDefault,
            backgroundColor: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
            onTap: isActive ? onTap : null,
          );
        },
      ),
    );
  }
}

/// Compact language toggle in the AppBar actions area.
class _LanguageToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () {
          if (isAr) {
            Get.updateLocale(const Locale('en', 'US'));
          } else {
            Get.updateLocale(const Locale('ar', 'SD'));
          }
        },
        child: Text(
          isAr ? 'English' : 'العربية',
          style: rubikSemiBold.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}
