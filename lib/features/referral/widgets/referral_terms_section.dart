import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';

/// Collapsible Terms & Conditions section.
/// Includes an accept checkbox that enables the Apply button.
class ReferralTermsSection extends StatelessWidget {
  const ReferralTermsSection({Key? key}) : super(key: key);

  static const _termKeys = [
    'referral_terms_1', 'referral_terms_2', 'referral_terms_3',
    'referral_terms_4', 'referral_terms_5', 'referral_terms_6',
    'referral_terms_7', 'referral_terms_8', 'referral_terms_9',
    'referral_terms_10',
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GetBuilder<ReferralController>(
      builder: (ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle button
          InkWell(
            onTap: ctrl.toggleTerms,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'referral_terms_toggle'.tr,
                    style: rubikSemiBold.copyWith(
                      color: primary,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: ctrl.termsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: primary, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible content
          AnimatedCrossFade(
            crossFadeState: ctrl.termsExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 280),
            firstChild: _TermsContent(
              termKeys: _termKeys,
              accepted: ctrl.termsAccepted,
              onChanged: ctrl.setTermsAccepted,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  final List<String> termKeys;
  final bool accepted;
  final void Function(bool) onChanged;

  const _TermsContent({
    Key? key,
    required this.termKeys,
    required this.accepted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'referral_terms_title'.tr,
            style: rubikSemiBold.copyWith(
              color: primary,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: 12),

          // Terms list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: termKeys.map((key) => _TermItem(text: key.tr)).toList(),
              ),
            ),
          ),

          // Divider + accept checkbox
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: accepted,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(!accepted),
                  child: Text(
                    'referral_terms_accept'.tr,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String text;
  const _TermItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: rubikRegular.copyWith(
                fontSize: 12.5,
                color: const Color(0xFF4B5563),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
