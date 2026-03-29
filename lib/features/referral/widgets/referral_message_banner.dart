import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';

/// Animated success/error banner for the referral screen.
class ReferralMessageBanner extends StatelessWidget {
  const ReferralMessageBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(
      builder: (ctrl) {
        final show    = ctrl.showError || ctrl.showSuccess;
        final isError = ctrl.showError;
        final text    = isError ? ctrl.errorMessage : ctrl.successMessage;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: show && text != null
              ? _Banner(key: ValueKey(text), text: text, isError: isError)
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final bool isError;
  const _Banner({Key? key, required this.text, required this.isError})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color  = isError ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final bg     = isError ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    final border = isError ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0);
    final textC  = isError ? const Color(0xFF991B1B) : const Color(0xFF065F46);

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color, size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: textC,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
