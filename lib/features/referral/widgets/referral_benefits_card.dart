import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

/// Top card showing the three main referral program benefits.
/// Includes a left accent border matching the HTML design.
class ReferralBenefitsCard extends StatelessWidget {
  const ReferralBenefitsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.06), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.18), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  topLeft:     isRtl ? Radius.zero : const Radius.circular(16),
                  bottomLeft:  isRtl ? Radius.zero : const Radius.circular(16),
                  topRight:    isRtl ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isRtl ? const Radius.circular(16) : Radius.zero,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.card_giftcard_rounded,
                            color: const Color(0xFFFDBB2D), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'referral_benefits'.tr,
                          style: rubikSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Benefit items
                    _BenefitRow(text: 'referral_benefit_1'.tr),
                    _BenefitRow(text: 'referral_benefit_2'.tr),
                    _BenefitRow(text: 'referral_benefit_3'.tr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
