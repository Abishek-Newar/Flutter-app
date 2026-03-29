import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:naqde_user/features/withdrawal/domain/models/withdrawal_model.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class WithdrawalSuccessScreen extends StatelessWidget {
  const WithdrawalSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Success animation ──────────────────────────────────
                SizedBox(
                  height: 180,
                  child: Lottie.asset(
                    'assets/animationFile/success.json',
                    repeat: false,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text('withdrawal_success'.tr,
                    style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraOverLarge),
                    textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('withdrawal_submitted_msg'.tr,
                    style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                        height: 1.6),
                    textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text('processing_time_value'.tr,
                        style: rubikLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor)),
                  ],
                ),

                const Spacer(),

                // ── CBoS note ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                  ),
                  child: Row(children: [
                    Icon(Icons.verified_outlined,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('cbos_compliance'.tr,
                          style: rubikLight.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── View history button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () =>
                        Get.offAllNamed(RouteHelper.getWithdrawalHistoryRoute()),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSizeSmall),
                      ),
                    ),
                    child: Text('withdrawal_history'.tr,
                        style: rubikMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault)),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ── Back to home button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.getNavBarRoute()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSizeSmall),
                      ),
                    ),
                    child: Text('home'.tr,
                        style: rubikSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
