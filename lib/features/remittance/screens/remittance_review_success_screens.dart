// remittance_review_screen.dart  —  Step 3: review + PIN entry
// remittance_success_screen.dart —  Step 4: animated success
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';
import 'package:naqde_user/features/remittance/domain/models/remittance_model.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Review Screen
// ─────────────────────────────────────────────────────────────────────────────
class RemittanceReviewScreen extends StatelessWidget {
  const RemittanceReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'remit_review_transfer'.tr, isBackButtonExist: true),
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          final q = ctrl.quote;
          if (q == null) {
            return Center(child: Text('remit_quote_expired'.tr,
                style: rubikRegular.copyWith(color: Colors.red)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Transfer summary card ──────────────────────────────
                _ReviewCard(title: 'remit_transfer_summary'.tr, rows: [
                  _Row('remit_you_send'.tr,
                      RemitFormatter.sdg(q.sendAmount, isAr: isAr)),
                  _Row('remit_recipient_gets'.tr,
                      RemitFormatter.foreign(q.receiveAmount, q.toCurrency, isAr: isAr),
                      highlight: true),
                  _Row('remit_exchange_rate'.tr,
                      '1 SDG = ${q.exchangeRate.toStringAsFixed(4)} ${q.toCurrency}'),
                  _Row('remit_fee'.tr,
                      RemitFormatter.sdg(q.fee, isAr: isAr),
                      deduction: true),
                  const Divider(height: 12),
                  _Row('remit_total_to_pay'.tr,
                      RemitFormatter.sdg(q.totalToPay, isAr: isAr),
                      bold: true),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ── Recipient card ─────────────────────────────────────
                _ReviewCard(title: 'remit_recipient_details'.tr, rows: [
                  _Row('remit_recipient_name'.tr,  ctrl.nameCtrl.text),
                  _Row('remit_recipient_phone'.tr, ctrl.phoneCtrl.text),
                  _Row('remit_destination'.tr,
                      ctrl.corridor?.localizedName(isAr) ?? ''),
                  _Row('remit_payout_method'.tr,  ctrl.payout.i18nKey.tr),
                  if (ctrl.bankCtrl.text.isNotEmpty)
                    _Row('remit_bank_name'.tr,    ctrl.bankCtrl.text),
                  if (ctrl.accountCtrl.text.isNotEmpty)
                    _Row('remit_account_number'.tr, ctrl.accountCtrl.text),
                  if (ctrl.mobileCtrl.text.isNotEmpty)
                    _Row('remit_mobile_number'.tr, ctrl.mobileCtrl.text),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ── Delivery estimate ──────────────────────────────────
                Row(children: [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 6),
                  Text('${'remit_delivery'.tr}: ',
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor)),
                  Text(ctrl.payout.deliveryKey.tr,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.green.shade600)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ── Quote countdown ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: (ctrl.countdown < 60
                        ? Colors.red : Colors.orange).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeExtraSmall),
                  ),
                  child: Row(children: [
                    Icon(Icons.timer_outlined,
                        size: 14,
                        color: ctrl.countdown < 60
                            ? Colors.red
                            : Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text('${'remit_rate_expires'.tr}: ${ctrl.countdownLabel}',
                        style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: ctrl.countdown < 60
                                ? Colors.red
                                : Colors.orange.shade700)),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ── Fraud challenge banner (blueprint FraudChallengeException) ─
                if (ctrl.fraudChallenge != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(
                          Dimensions.radiusSizeSmall),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('remit_verification_required'.tr,
                              style: rubikSemiBold.copyWith(
                                  color: Colors.orange.shade800,
                                  fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: 4),
                          Text(
                            '${isAr ? "التحقق عبر" : "Verify via"}: '
                            '${ctrl.fraudChallenge!.methods.join(", ")}',
                            style: rubikRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault),
                          ),
                        ]),
                  ),

                // ── PIN input ──────────────────────────────────────────
                Text('remit_enter_pin'.tr,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: ctrl.pinCtrl,
                  obscureText: true,
                  obscuringCharacter: '●',
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  onChanged: (_) => ctrl.update(),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall),
                    fieldHeight: 56, fieldWidth: 56,
                    activeFillColor:   Theme.of(context).cardColor,
                    inactiveFillColor: Theme.of(context).cardColor,
                    selectedFillColor: Theme.of(context).cardColor,
                    activeColor:   Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).dividerColor,
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                  enableActiveFill: true,
                ),
                const SizedBox(height: 6),
                Text('remit_terms_note'.tr,
                    style: rubikLight.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── Confirm button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: ctrl.pinReady &&
                            ctrl.quoteReady &&
                            !ctrl.submitting
                        ? ctrl.submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius:
                          BorderRadius.circular(Dimensions.radiusSizeSmall)),
                    ),
                    child: ctrl.submitting
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('remit_confirm'.tr,
                            style: rubikSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeLarge)),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Center(
                  child: Text('remit_fatf_compliant'.tr,
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                ),

                // ── Navigate to success when step == 4 ────────────────
                if (ctrl.step == 4)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.offNamed(RouteHelper.getRemittanceSuccessRoute());
                  }) as Widget? ?? const SizedBox.shrink(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Screen
// ─────────────────────────────────────────────────────────────────────────────
class RemittanceSuccessScreen extends StatelessWidget {
  const RemittanceSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ── Success icon ───────────────────────────────────
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_outline_rounded,
                        size: 64, color: Colors.green.shade600),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('remit_transfer_sent'.tr,
                      style: rubikSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraOverLarge),
                      textAlign: TextAlign.center),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text('remit_success_msg'.tr,
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor,
                          height: 1.6),
                      textAlign: TextAlign.center),

                  // ── Reference number ───────────────────────────────
                  if (ctrl.result != null) ...[
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeSmall),
                      ),
                      child: Text(
                        '${isAr ? "المرجع" : "Ref"}: ${ctrl.result!.reference}',
                        style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                  const Spacer(),

                  // ── CBoS / FATF badge ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(
                        Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.06),
                      borderRadius: BorderRadius.circular(
                          Dimensions.radiusSizeSmall),
                    ),
                    child: Row(children: [
                      Icon(Icons.verified_outlined,
                          size: 16,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('remit_fatf_compliant'.tr,
                            style: rubikLight.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── View history ───────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: OutlinedButton(
                      onPressed: () => Get.offNamed(
                          RouteHelper.getRemittanceHistoryRoute()),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(Dimensions.radiusSizeSmall)),
                      ),
                      child: Text('remit_history'.tr,
                          style: rubikMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeDefault)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // ── Send another ───────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.reset();
                        Get.offAllNamed(
                            RouteHelper.getRemittanceCorridorRoute());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(Dimensions.radiusSizeSmall)),
                      ),
                      child: Text('remit_send_another'.tr,
                          style: rubikSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeDefault)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared review widgets
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _ReviewCard({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: rubikMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge)),
      const Divider(height: 16),
      ...rows,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool highlight, deduction, bold;
  const _Row(this.label, this.value,
      {this.highlight = false, this.deduction = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label,
            style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor))),
        Text(value,
            style: (bold ? rubikSemiBold : rubikRegular).copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: highlight
                    ? Colors.green.shade600
                    : deduction
                        ? Colors.red.shade500
                        : bold
                            ? Theme.of(context).primaryColor
                            : null)),
      ],
    ),
  );
}
