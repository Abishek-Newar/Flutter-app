import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_large_widget.dart';
import 'package:naqde_user/common/widgets/custom_logo_widget.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';
import '../widgets/referral_benefits_card.dart';
import '../widgets/referral_code_info_panel.dart';
import '../widgets/referral_message_banner.dart';
import '../widgets/referral_stats_row.dart';
import '../widgets/referral_terms_section.dart';

/// CircleCash Referral Screen
///
/// Shown during the registration flow, between PIN setup and home screen.
/// The user can enter an optional referral code or skip the step.
///
/// Navigation:
///   • After successful apply  → RouteHelper.getNavBarRoute()
///   • Skip                    → RouteHelper.getNavBarRoute()
///
/// Usage in route_helper.dart:
/// ```dart
/// static const String referralScreen = '/referral';
/// static String getReferralRoute() => referralScreen;
///
/// GetPage(
///   name: referralScreen,
///   page: () => const ReferralScreen(),
///   transition: Transition.fadeIn,
/// ),
/// ```
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load global stats without blocking the UI
    Get.find<ReferralController>().loadStats();
    // Reset any leftover state from a previous session
    Get.find<ReferralController>().reset();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onApply() async {
    final success = await Get.find<ReferralController>()
        .applyCode(_codeController.text);

    if (success && mounted) {
      await Future.delayed(const Duration(milliseconds: 1800));
      _navigateNext();
    }
  }

  void _onSkip() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'referral_skip'.tr,
          style: rubikSemiBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge),
        ),
        content: Text(
          'referral_skip_confirm'.tr,
          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('referral_skip_no'.tr,
                style: rubikSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _navigateNext();
            },
            child: Text('referral_skip_yes'.tr,
                style: rubikSemiBold.copyWith(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  void _navigateNext() {
    // Navigate to home — same pattern as post-registration flow
    Get.offAllNamed(RouteHelper.getNavBarRoute());
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppbarWidget(
        title: 'referral_program'.tr,
        isBackButtonExist: false,
        // Language toggle
        actionWidget: _LanguageToggle(),
      ),
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  // Logo
                  const CustomLogoWidget(height: 64, width: 64),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Benefits card
                  const ReferralBenefitsCard(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Code info panel (animated, shown when code is valid)
                  const ReferralCodeInfoPanel(),

                  // Message banner
                  const ReferralMessageBanner(),

                  // Code input
                  _CodeInputField(
                    controller: _codeController,
                    focusNode: _codeFocus,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Stats row
                  const ReferralStatsRow(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Terms
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 4),
                  const ReferralTermsSection(),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],
              ),
            ),
          ),

          // ── Sticky bottom buttons ────────────────────────────────────────
          _BottomActions(onApply: _onApply, onSkip: _onSkip),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

/// Referral code text field with real-time validation indicator
class _CodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _CodeInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GetBuilder<ReferralController>(
      builder: (ctrl) {
        final isValid   = ctrl.hasValidCode;
        final isLoading = ctrl.isValidating;

        Color borderColor;
        Color fillColor;
        if (isValid) {
          borderColor = const Color(0xFF10B981);
          fillColor   = const Color(0xFFECFDF5);
        } else if (ctrl.showError) {
          borderColor = const Color(0xFFEF4444);
          fillColor   = const Color(0xFFFEF2F2);
        } else {
          borderColor = const Color(0xFFE5E7EB);
          fillColor   = const Color(0xFFF9FAFB);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'referral_code_label'.tr,
              style: rubikSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),

            // Input row
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.confirmation_number_outlined,
                        color: isValid ? const Color(0xFF10B981) : Colors.grey.shade500,
                        size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.characters,
                      style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        letterSpacing: 1.5,
                        color: primary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'referral_code_hint'.tr,
                        hintStyle: rubikRegular.copyWith(
                          color: Colors.grey.shade400,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 0),
                      ),
                      maxLength: 10,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      onChanged: (v) => ctrl.onCodeChanged(v),
                      onSubmitted: (_) => ctrl.isApplied
                          ? null
                          : Get.find<ReferralController>().applyCode(controller.text),
                    ),
                  ),
                  // Loading / valid indicator
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: isLoading
                        ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: primary))
                        : isValid
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF10B981), size: 20)
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Hint text
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.grey.shade500, size: 14),
                const SizedBox(width: 6),
                Text(
                  'referral_code_input_hint'.tr,
                  style: rubikRegular.copyWith(
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Apply + Skip buttons at the bottom of the screen
class _BottomActions extends StatelessWidget {
  final Future<void> Function() onApply;
  final VoidCallback onSkip;

  const _BottomActions({
    Key? key,
    required this.onApply,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: GetBuilder<ReferralController>(
        builder: (ctrl) {
          final canApply = ctrl.hasValidCode && !ctrl.isApplied && !ctrl.isApplying;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary Apply button
              CustomLargeButtonWidget(
                text: ctrl.isApplied
                    ? 'referral_applied'.tr
                    : 'referral_apply'.tr,
                isLoading: ctrl.isApplying,
                fontSize: Dimensions.fontSizeDefault,
                backgroundColor: ctrl.isApplied
                    ? const Color(0xFF10B981)
                    : canApply
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                onTap: canApply ? onApply : null,
              ),

              const SizedBox(height: 12),

              // Skip button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: ctrl.isApplied ? null : onSkip,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'referral_skip'.tr,
                    style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // "I don't have a referral code" text link
              GestureDetector(
                onTap: ctrl.isApplied ? null : onSkip,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'referral_no_code'.tr,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Language toggle button for the AppBar
class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () => Get.updateLocale(
          isAr ? const Locale('en', 'US') : const Locale('ar', 'SD'),
        ),
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
