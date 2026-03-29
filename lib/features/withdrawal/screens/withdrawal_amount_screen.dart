import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/features/withdrawal/controllers/withdrawal_controller.dart';
import 'package:naqde_user/features/withdrawal/domain/models/withdrawal_model.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';

class WithdrawalAmountScreen extends StatefulWidget {
  const WithdrawalAmountScreen({super.key});
  @override
  State<WithdrawalAmountScreen> createState() => _WithdrawalAmountScreenState();
}

class _WithdrawalAmountScreenState extends State<WithdrawalAmountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<WithdrawalController>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(title: 'withdraw_money'.tr, isBackButtonExist: true),
        body: GetBuilder<WithdrawalController>(
          builder: (ctrl) {
            final balance = (Get.find<ProfileController>().userInfo?.balance ?? 0).toDouble();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Available Balance Card ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.75),
                        ],
                        begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        end:   isAr ? Alignment.centerLeft  : Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('available_balance'.tr,
                            style: rubikRegular.copyWith(
                                color: Colors.white70,
                                fontSize: Dimensions.fontSizeDefault)),
                        const SizedBox(height: 6),
                        Text(SdgFormatter.format(balance, isArabic: isAr),
                            style: rubikSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeOverOverLarge)),
                        const SizedBox(height: 10),
                        Text('amounts_in_sdg'.tr,
                            style: rubikLight.copyWith(
                                color: Colors.white60,
                                fontSize: Dimensions.fontSizeSmall)),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Limits Row ─────────────────────────────────────────
                  if (ctrl.limits != null) ...[
                    Row(children: [
                      Expanded(child: _LimitChip(
                        label: 'daily_limit_remaining'.tr,
                        value: SdgFormatter.format(ctrl.limits!.dailyRemaining, isArabic: isAr),
                        context: context,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _LimitChip(
                        label: 'monthly_limit_remaining'.tr,
                        value: SdgFormatter.format(ctrl.limits!.monthlyRemaining, isArabic: isAr),
                        context: context,
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  // ── Amount Input ───────────────────────────────────────
                  Text('enter_withdrawal_amount'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextField(
                    controller: ctrl.amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge),
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      prefixText: isAr ? null : 'SDG  ',
                      suffixText: isAr ? 'ج.س' : null,
                      prefixStyle: rubikRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeLarge),
                      suffixStyle: rubikRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeLarge),
                      hintText: '0.00',
                      errorText: ctrl.errorMessage,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        borderSide: BorderSide(
                            color: Theme.of(context).dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onChanged: ctrl.onAmountChanged,
                  ),
                  const SizedBox(height: 8),
                  Text('${'min_withdrawal'.tr}   ·   ${'max_withdrawal'.tr}',
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Fee Breakdown ──────────────────────────────────────
                  if (ctrl.enteredAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(children: [
                        _FeeRow(
                          label: 'withdrawal_amount'.tr,
                          value: SdgFormatter.format(ctrl.enteredAmount, isArabic: isAr),
                          context: context,
                        ),
                        _FeeRow(
                          label: 'withdrawal_fee'.tr,
                          value: '- ${SdgFormatter.format(ctrl.fee, isArabic: isAr)}',
                          context: context,
                          isDeduction: true,
                        ),
                        const Divider(),
                        _FeeRow(
                          label: 'you_will_receive'.tr,
                          value: SdgFormatter.format(ctrl.netAmount, isArabic: isAr),
                          context: context,
                          isBold: true,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Text('fee_calculated'.tr,
                        style: rubikLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],

                  // ── Method Selection ────────────────────────────────────
                  if (ctrl.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (ctrl.methods.isEmpty)
                    Center(child: Text('no_withdrawal_methods'.tr,
                        style: rubikRegular.copyWith(
                            color: Theme.of(context).hintColor)))
                  else ...[
                    Text('select_withdrawal_method'.tr,
                        style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ...ctrl.methods.map((method) => _MethodTile(
                      method: method,
                      isSelected: ctrl.selectedMethod?.id == method.id,
                      isAr: isAr,
                      onTap: () => ctrl.selectMethod(method),
                    )),
                  ],
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // ── Continue Button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: ctrl.enteredAmount >= 1000 &&
                              ctrl.errorMessage == null &&
                              ctrl.selectedMethod != null
                          ? () => Get.toNamed(RouteHelper.getWithdrawalDetailsRoute())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                        ),
                      ),
                      child: Text('confirm_and_submit'.tr,
                          style: rubikSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeLarge)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Center(
                    child: Text('cbos_compliance'.tr,
                        style: rubikLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LimitChip extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  const _LimitChip({required this.label, required this.value, required this.context});
  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: rubikLight.copyWith(fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor)),
          const SizedBox(height: 2),
          Text(value,
              style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor)),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  final bool isDeduction;
  final bool isBold;
  const _FeeRow({
    required this.label, required this.value, required this.context,
    this.isDeduction = false, this.isBold = false,
  });
  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: (isBold ? rubikMedium : rubikRegular).copyWith(
                  fontSize: Dimensions.fontSizeDefault)),
          Text(value,
              style: (isBold ? rubikSemiBold : rubikRegular).copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: isDeduction
                      ? Colors.red.shade600
                      : isBold
                          ? Theme.of(context).primaryColor
                          : null)),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final WithdrawalMethodModel method;
  final bool isSelected;
  final bool isAr;
  final VoidCallback onTap;
  const _MethodTile({
    required this.method, required this.isSelected,
    required this.isAr, required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Icon(
            method.methodName.toLowerCase().contains('bank')
                ? Icons.account_balance
                : Icons.phone_android,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(method.localizedName(isAr),
                style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isSelected ? Theme.of(context).primaryColor : null)),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
        ]),
      ),
    );
  }
}
