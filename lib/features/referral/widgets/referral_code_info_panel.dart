import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';
import '../domain/models/referral_model.dart';

/// Animated panel that slides in when a valid referral code is detected,
/// showing the specific rewards for that code type.
/// Maps to the HTML's #codeInfo element.
class ReferralCodeInfoPanel extends StatelessWidget {
  const ReferralCodeInfoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(
      builder: (ctrl) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: ctrl.hasValidCode
              ? _CodePanel(
                  key: ValueKey(ctrl.validatedCode!.code),
                  code: ctrl.validatedCode!,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _CodePanel extends StatelessWidget {
  final ReferralCodeModel code;
  const _CodePanel({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVip = code.type == ReferralCodeType.vip;
    final isAr  = Get.locale?.languageCode == 'ar';

    final bg      = isVip ? const Color(0xFFEDE9FE) : const Color(0xFFFEF3C7);
    final border  = isVip ? const Color(0xFF8B5CF6) : const Color(0xFFFBBF24);
    final titleC  = isVip ? const Color(0xFF8B5CF6) : const Color(0xFF92400E);
    final textC   = isVip ? const Color(0xFF5B21B6) : const Color(0xFF78350F);

    final List<String> benefits = _getBenefits(code, isAr);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with optional VIP badge
          Row(
            children: [
              if (isVip) ...[
                _VipBadge(),
                const SizedBox(width: 8),
              ] else
                Icon(Icons.star_rounded, color: titleC, size: 18),
              if (!isVip) const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isVip ? 'referral_vip_offer'.tr : 'referral_special_offer'.tr,
                  style: rubikSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: titleC,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Benefits list
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_rounded, color: textC, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: textC,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getBenefits(ReferralCodeModel c, bool isAr) {
    switch (c.type) {
      case ReferralCodeType.vip:
        return [
          'referral_vip_status'.tr,
          'referral_vip_you'.tr,
          'referral_vip_friend'.tr,
        ];
      case ReferralCodeType.newuser:
        return [
          'referral_newuser_title'.tr,
          'referral_newuser_you'.tr,
          'referral_newuser_friend'.tr,
        ];
      default:
        return [
          'referral_standard_you'.tr,
          'referral_standard_friend'.tr,
        ];
    }
  }
}

/// Purple VIP badge pill
class _VipBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            'VIP',
            style: rubikSemiBold.copyWith(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
