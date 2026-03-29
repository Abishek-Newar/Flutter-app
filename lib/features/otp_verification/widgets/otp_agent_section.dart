import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/otp_verification_controller.dart';

/// Agent / customer-support help section shown below the method cards.
/// Mirrors the HTML's agentSection.
class OtpAgentSection extends StatelessWidget {
  final String identifier;

  const OtpAgentSection({Key? key, required this.identifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.headset_mic_outlined,
                color: primary, size: 28),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Title
          Text(
            'otp_need_help'.tr,
            style: rubikSemiBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),

          // Text (always LTR for phone number)
          Text(
            'otp_agent_text'.tr,
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Callback button
          GetBuilder<OtpVerificationController>(
            builder: (ctrl) => SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: ctrl.isAgentRequesting
                    ? null
                    : () => ctrl.requestAgentCallback(
                        phoneOrEmail: identifier),
                icon: ctrl.isAgentRequesting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      )
                    : Icon(Icons.phone_callback_outlined,
                        color: primary, size: 18),
                label: Text(
                  'otp_request_callback'.tr,
                  style: rubikSemiBold.copyWith(
                    color: primary,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
