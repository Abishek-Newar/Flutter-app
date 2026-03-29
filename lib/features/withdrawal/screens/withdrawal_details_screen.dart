import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:naqde_user/features/withdrawal/controllers/withdrawal_controller.dart';
import 'package:naqde_user/features/withdrawal/domain/models/withdrawal_model.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class WithdrawalDetailsScreen extends StatelessWidget {
  const WithdrawalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'withdrawal_request'.tr,
          isBackButtonExist: true,
        ),
        body: GetBuilder<WithdrawalController>(builder: (ctrl) {
          final method = ctrl.selectedMethod;
          if (method == null) {
            return Center(child: Text('select_withdrawal_method'.tr));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Summary card ───────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  ),
                  child: Column(
                    children: [
                      Text('withdrawal_amount'.tr,
                          style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor)),
                      const SizedBox(height: 6),
                      Text(SdgFormatter.format(ctrl.enteredAmount, isArabic: isAr),
                          style: rubikSemiBold.copyWith(
                              fontSize: 32,
                              color: Theme.of(context).primaryColor)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SummaryCol(label: 'withdrawal_fee'.tr,
                              value: '- ${SdgFormatter.format(ctrl.fee, isArabic: isAr)}',
                              color: Colors.red.shade600, context: context),
                          Container(width: 1, height: 36,
                              color: Theme.of(context).dividerColor),
                          _SummaryCol(label: 'you_will_receive'.tr,
                              value: SdgFormatter.format(ctrl.netAmount, isArabic: isAr),
                              color: Colors.green.shade600, context: context),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── Method + Dynamic Fields ───────────────────────────
                Text('recipient_details'.tr,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Method chip
                      Row(children: [
                        Icon(
                          method.methodName.toLowerCase().contains('bank')
                              ? Icons.account_balance
                              : Icons.phone_android,
                          color: Theme.of(context).primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(method.localizedName(isAr),
                            style: rubikMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.fontSizeDefault)),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      const Divider(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      // Dynamic fields
                      ...method.fields.map((field) => _DynamicField(
                        field: field,
                        controller: ctrl.fieldControllers[field.inputName]!,
                        isAr: isAr,
                        context: context,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── Processing time ────────────────────────────────────
                Row(children: [
                  Icon(Icons.access_time,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 6),
                  Text('${'processing_time'.tr}: ',
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor)),
                  Text('processing_time_value'.tr,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── PIN Entry ─────────────────────────────────────────
                Text('enter_pin'.tr,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: ctrl.pinController,
                  obscureText: true,
                  obscuringCharacter: '●',
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  onChanged: (_) => ctrl.update(),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                    fieldHeight: 56,
                    fieldWidth: 56,
                    activeFillColor: Theme.of(context).cardColor,
                    inactiveFillColor: Theme.of(context).cardColor,
                    selectedFillColor: Theme.of(context).cardColor,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).dividerColor,
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                  enableActiveFill: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ── Submit Button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: ctrl.canSubmit && !ctrl.isSubmitting
                        ? ctrl.submitWithdrawal
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                      ),
                    ),
                    child: ctrl.isSubmitting
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('confirm_and_submit'.tr,
                            style: rubikSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeLarge)),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
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
        }),
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final BuildContext context;
  const _SummaryCol(
      {required this.label, required this.value,
       required this.color, required this.context});
  @override
  Widget build(BuildContext ctx) {
    return Column(children: [
      Text(label,
          style: rubikLight.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor)),
      const SizedBox(height: 4),
      Text(value,
          style: rubikSemiBold.copyWith(
              fontSize: Dimensions.fontSizeDefault, color: color)),
    ]);
  }
}

class _DynamicField extends StatelessWidget {
  final WithdrawalFieldModel field;
  final TextEditingController controller;
  final bool isAr;
  final BuildContext context;
  const _DynamicField({
    required this.field, required this.controller,
    required this.isAr, required this.context,
  });
  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? field.placeholderAr : field.placeholder,
              style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: field.inputType == 'number' || field.inputType == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            onChanged: (_) {},
            decoration: InputDecoration(
              hintText: field.localizedPlaceholder(isAr),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
