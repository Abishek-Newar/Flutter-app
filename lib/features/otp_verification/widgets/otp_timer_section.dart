import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/otp_verification_controller.dart';

/// Animated countdown display + resend button row.
/// Countdown turns red and pulses when ≤30 seconds remain.
/// Resend button is disabled during cooldown and shows remaining seconds.
class OtpTimerSection extends StatelessWidget {
  final String identifier;
  final bool isForgetPassword;

  const OtpTimerSection({
    super.key,
    required this.identifier,
    this.isForgetPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerificationController>(
      builder: (ctrl) {
        final primary = Theme.of(context).colorScheme.primary;
        final isWarning = ctrl.isCountdownWarning;
        final isExpired = ctrl.isExpired;

        return Column(
          children: [
            // Countdown box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'otp_code_expires'.tr,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Pulse animation on warning
                  _PulsingText(
                    text: isExpired ? '00:00' : ctrl.countdownDisplay,
                    isPulsing: isWarning || isExpired,
                    color: (isWarning || isExpired)
                        ? const Color(0xFFB21F1F)
                        : primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Resend section
            Column(
              children: [
                Text(
                  'otp_resend_question'.tr,
                  style: rubikRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: ctrl.canResend
                      ? () => ctrl.resendOtp(phoneOrEmail: identifier)
                      : null,
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: ctrl.canResend ? primary : Colors.grey.shade400,
                  ),
                  label: Text(
                    ctrl.canResend
                        ? 'otp_resend'.tr
                        : ctrl.resendCooldown > 0
                            ? 'otp_wait_seconds'
                                .tr
                                .replaceAll('{n}', '${ctrl.resendCooldown}')
                            : 'otp_resend'.tr,
                    style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: ctrl.canResend ? primary : Colors.grey.shade400,
                    ),
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

/// Text widget that pulses opacity when [isPulsing] is true.
class _PulsingText extends StatefulWidget {
  final String text;
  final bool isPulsing;
  final Color color;

  const _PulsingText({
    required this.text,
    required this.isPulsing,
    required this.color,
  });

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.4).animate(_anim);
    if (widget.isPulsing) _anim.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingText old) {
    super.didUpdateWidget(old);
    if (widget.isPulsing && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.isPulsing && _anim.isAnimating) {
      _anim.stop();
      _anim.value = 1.0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        style: TextStyle(
          fontFamily: 'Roboto Mono',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: widget.color,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
