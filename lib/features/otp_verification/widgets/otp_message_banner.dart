import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/otp_verification_controller.dart';

/// Animated success/error message banner shown above the form.
/// Auto-hides after 5 seconds (controlled by [OtpVerificationController]).
class OtpMessageBanner extends StatelessWidget {
  const OtpMessageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerificationController>(
      builder: (ctrl) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ctrl.showMessage
              ? _MessageBox(
                  key: ValueKey(ctrl.messageText),
                  text: ctrl.messageText ?? '',
                  isSuccess: ctrl.isSuccessMessage,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String text;
  final bool isSuccess;

  const _MessageBox({
    super.key,
    required this.text,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bg = isSuccess ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final border = isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);

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
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isSuccess
                      ? const Color(0xFF065F46)
                      : const Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
