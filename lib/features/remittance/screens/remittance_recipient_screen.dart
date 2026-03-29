// remittance_recipient_screen.dart  —  Step 2: enter recipient details
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';
import 'package:naqde_user/features/remittance/domain/models/remittance_model.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class RemittanceRecipientScreen extends StatelessWidget {
  const RemittanceRecipientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'remit_recipient_details'.tr, isBackButtonExist: true),
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Payout badge ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeOverLarge),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_payoutIcon(ctrl.payout),
                        color: Theme.of(context).primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(ctrl.payout.i18nKey.tr,
                        style: rubikMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault)),
                    Text(
                      '  ·  ${ctrl.corridor?.localizedName(isAr) ?? ''}',
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── Common fields ──────────────────────────────────────
                _LabeledField(
                    label: 'remit_recipient_name'.tr,
                    hint: 'remit_enter_name'.tr,
                    ctrl: ctrl.nameCtrl, isAr: isAr),
                _LabeledField(
                    label: 'remit_recipient_phone'.tr,
                    hint: 'remit_enter_phone'.tr,
                    ctrl: ctrl.phoneCtrl,
                    kbType: TextInputType.phone, isAr: isAr),
                _LabeledField(
                    label: 'remit_email_optional'.tr,
                    hint: isAr ? 'اختياري' : 'Optional',
                    ctrl: ctrl.emailCtrl,
                    kbType: TextInputType.emailAddress, isAr: isAr),

                // ── Payout-adaptive fields ─────────────────────────────
                if (ctrl.payout == PayoutMethod.bankDeposit) ...[
                  _LabeledField(
                      label: 'remit_bank_name'.tr,
                      hint: 'remit_enter_bank'.tr,
                      ctrl: ctrl.bankCtrl, isAr: isAr),
                  _LabeledField(
                      label: 'remit_account_number'.tr,
                      hint: 'remit_enter_account'.tr,
                      ctrl: ctrl.accountCtrl, isAr: isAr),
                ],
                if (ctrl.payout == PayoutMethod.mobileMoney ||
                    ctrl.payout == PayoutMethod.walletTransfer)
                  _LabeledField(
                      label: 'remit_mobile_number'.tr,
                      hint: 'remit_enter_mobile'.tr,
                      ctrl: ctrl.mobileCtrl,
                      kbType: TextInputType.phone, isAr: isAr),
                if (ctrl.payout == PayoutMethod.cashPickup)
                  _LabeledField(
                      label: 'remit_pickup_location'.tr,
                      hint: isAr
                          ? 'أدخل موقع الاستلام'
                          : 'Enter pickup location',
                      ctrl: ctrl.pickupCtrl, isAr: isAr),

                // ── Save recipient toggle ──────────────────────────────
                const SizedBox(height: Dimensions.paddingSizeSmall),
                GestureDetector(
                  onTap: ctrl.toggleSave,
                  child: Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: ctrl.saveRecipient
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: ctrl.saveRecipient
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ctrl.saveRecipient
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text('remit_save_recipient'.tr,
                        style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // ── Continue ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: ctrl.recipientValid
                        ? () {
                            ctrl.goStep(3);
                            Get.toNamed(
                                RouteHelper.getRemittanceReviewRoute());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius:
                          BorderRadius.circular(Dimensions.radiusSizeSmall)),
                    ),
                    child: Text('remit_review_transfer'.tr,
                        style: rubikSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _payoutIcon(PayoutMethod m) {
    switch (m) {
      case PayoutMethod.bankDeposit:    return Icons.account_balance_rounded;
      case PayoutMethod.mobileMoney:    return Icons.phone_android_rounded;
      case PayoutMethod.cashPickup:     return Icons.storefront_rounded;
      case PayoutMethod.walletTransfer: return Icons.account_balance_wallet_rounded;
    }
  }
}

class _LabeledField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final TextInputType kbType;
  final bool isAr;
  const _LabeledField({
    required this.label, required this.hint, required this.ctrl,
    this.kbType = TextInputType.text, required this.isAr,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        keyboardType: kbType,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor, width: 2),
          ),
        ),
      ),
    ]),
  );
}
