import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_large_widget.dart';
import 'package:naqde_user/common/widgets/custom_logo_widget.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';
import '../widgets/referral_benefits_card.dart';
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
    Get.find<ReferralController>().reset();
    Get.find<ReferralController>().loadMyCode();
    Get.find<ReferralController>().loadStats();
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

                  // Your own referral code card (from /referral/my-code)
                  const _MyCodeCard(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Benefits card
                  const ReferralBenefitsCard(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

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

/// Your own referral code card — loaded from GET /referral/my-code
class _MyCodeCard extends StatelessWidget {
  const _MyCodeCard();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(builder: (ctrl) {
      if (ctrl.loadingMyCode) {
        return const Center(child: CircularProgressIndicator());
      }
      final code = ctrl.myCode;
      if (code == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('your_referral_code'.tr,
            style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Text(code.code,
                  style: rubikSemiBold.copyWith(
                    fontSize: 22, letterSpacing: 3,
                    color: Theme.of(context).primaryColor)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code.code));
                Get.snackbar('', Get.locale?.languageCode == 'ar'
                    ? 'تم نسخ الكود!' : 'Code copied!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(12));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text('copy'.tr, style: rubikMedium.copyWith(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _StatChip(Icons.people_outline, '${code.totalReferrals}', 'referrals'.tr),
            const SizedBox(width: 8),
            _StatChip(Icons.verified_outlined, '${code.rewarded}', 'rewarded'.tr),
            const SizedBox(width: 8),
            _StatChip(Icons.attach_money, '${code.totalEarnedSdg.toStringAsFixed(0)}', 'earned'.tr),
          ]),
        ]),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Icon(icon, size: 14, color: Theme.of(context).primaryColor),
        const SizedBox(height: 2),
        Text(value, style: rubikSemiBold.copyWith(fontSize: 13)),
        Text(label, style: rubikRegular.copyWith(fontSize: 9, color: Colors.grey),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}

/// Referral code text field — enter a friend's code
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
        final isValid = ctrl.hasValidCode;

        final borderColor = isValid
            ? const Color(0xFF10B981)
            : ctrl.showError
                ? const Color(0xFFEF4444)
                : const Color(0xFFE5E7EB);
        final fillColor = isValid
            ? const Color(0xFFECFDF5)
            : ctrl.showError
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFF9FAFB);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'referral_code_label'.tr,
              style: rubikSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
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
                    onChanged: ctrl.onCodeChanged,
                    onSubmitted: (_) {
                      if (!ctrl.isApplied) ctrl.applyCode(controller.text);
                    },
                  ),
                ),
                if (isValid)
                  const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.check_circle,
                      color: Color(0xFF10B981), size: 20),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.info_outline, color: Colors.grey.shade500, size: 14),
              const SizedBox(width: 6),
              Text('referral_code_input_hint'.tr,
                style: rubikRegular.copyWith(
                  fontSize: 12.5, color: Colors.grey.shade500)),
            ]),
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
          final canApply = ctrl.hasValidCode && !ctrl.isApplied && !ctrl.isApplying && ctrl.termsAccepted;

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
