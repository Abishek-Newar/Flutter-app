// remittance_amount_screen.dart  —  Step 1: enter SDG amount + live quote
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';
import 'package:naqde_user/features/remittance/domain/models/remittance_model.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class RemittanceAmountScreen extends StatelessWidget {
  const RemittanceAmountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'remit_get_rate'.tr, isBackButtonExist: true),
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          final c       = ctrl.corridor!;
          final balance =
              (Get.find<ProfileController>().userInfo?.balance ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Corridor pill ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSizeSmall),
                ),
                child: Row(children: [
                  Text(c.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    '${isAr ? "السودان" : "Sudan"} → ${c.localizedName(isAr)} (${c.currency})',
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault),
                  )),
                  Text(ctrl.payout.i18nKey.tr,
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Wallet balance ─────────────────────────────────────
              Row(children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: Theme.of(context).hintColor),
                const SizedBox(width: 6),
                Text('${'available_balance'.tr}: ',
                    style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor)),
                Text(RemitFormatter.sdg(balance, isAr: isAr),
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Amount input ───────────────────────────────────────
              Text('remit_you_send'.tr,
                  style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextField(
                controller: ctrl.amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge),
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  prefixText: isAr ? null : 'SDG  ',
                  suffixText: isAr ? '  ج.س' : null,
                  prefixStyle: rubikRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeLarge),
                  suffixStyle: rubikRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeLarge),
                  hintText: '0.00',
                  errorText: ctrl.amountError,
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                onChanged: ctrl.onAmountChanged,
              ),
              const SizedBox(height: 6),
              Text('${'remit_min'.tr}  ·  ${'remit_max'.tr}',
                  style: rubikLight.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Get / refresh rate ─────────────────────────────────
              if (!ctrl.quoteReady)
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: ctrl.amount >= 500 &&
                            ctrl.amountError == null &&
                            !ctrl.loadingQuote
                        ? ctrl.fetchQuote
                        : null,
                    icon: ctrl.loadingQuote
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync_rounded),
                    label: Text(
                      ctrl.loadingQuote
                          ? '...'
                          : ctrl.quoteExpired
                              ? 'remit_refresh_rate'.tr
                              : 'remit_get_rate'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).primaryColor),
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius:
                          BorderRadius.circular(Dimensions.radiusSizeSmall)),
                    ),
                  ),
                ),

              // ── Live quote card ────────────────────────────────────
              if (ctrl.quoteReady) ...[
                _QuoteCard(ctrl: ctrl, isAr: isAr),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      ctrl.goStep(2);
                      Get.toNamed(RouteHelper.getRemittanceRecipientRoute());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius:
                          BorderRadius.circular(Dimensions.radiusSizeSmall)),
                    ),
                    child: Text('remit_recipient_details'.tr,
                        style: rubikSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge)),
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Center(
                child: Text('remit_fatf_compliant'.tr,
                    style: rubikLight.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor)),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

// ── Quote card ────────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final RemittanceController ctrl;
  final bool isAr;
  const _QuoteCard({required this.ctrl, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final q = ctrl.quote!;
    final timerColor =
        ctrl.countdown < 60 ? Colors.red : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.06),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [

        // Timer row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('remit_quote_valid'.tr,
              style: rubikLight.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor)),
          Row(children: [
            Icon(Icons.timer_outlined, size: 14, color: timerColor),
            const SizedBox(width: 4),
            Text(ctrl.countdownLabel,
                style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: timerColor)),
          ]),
        ]),
        const Divider(height: 20),

        // Send → receive row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QCol(label: 'remit_you_send'.tr,
                value: RemitFormatter.sdg(q.sendAmount, isAr: isAr)),
            Icon(isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                color: Theme.of(context).hintColor, size: 18),
            _QCol(label: 'remit_recipient_gets'.tr,
                value: RemitFormatter.foreign(q.receiveAmount, q.toCurrency, isAr: isAr),
                highlight: true),
          ],
        ),
        const SizedBox(height: 12),

        // Rate + fee row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QCol(label: 'remit_exchange_rate'.tr,
                value: '1 SDG = ${q.exchangeRate.toStringAsFixed(4)} ${q.toCurrency}'),
            _QCol(label: 'remit_fee'.tr,
                value: RemitFormatter.sdg(q.fee, isAr: isAr),
                deduction: true),
          ],
        ),
        const Divider(height: 20),

        // Total row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('remit_total_to_pay'.tr,
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
          Text(RemitFormatter.sdg(q.totalToPay, isAr: isAr),
              style: rubikSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor)),
        ]),
      ]),
    );
  }
}

class _QCol extends StatelessWidget {
  final String label, value;
  final bool highlight, deduction;
  const _QCol({
    required this.label, required this.value,
    this.highlight = false, this.deduction = false,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: rubikLight.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor)),
      const SizedBox(height: 2),
      Text(value,
          style: rubikMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: highlight
                  ? Colors.green.shade600
                  : deduction ? Colors.red.shade500 : null)),
    ],
  );
}
