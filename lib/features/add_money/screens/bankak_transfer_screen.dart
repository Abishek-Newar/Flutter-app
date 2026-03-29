// lib/features/add_money/screens/bankak_transfer_screen.dart
//
// Replaces generic add money web screen with a clear Bankak step-by-step flow.
// Hardcoded bank details:
//   Bank: بنك الخرطوم (Bankak)
//   Account holder: عبدالقادر محمد أبوعيد
//   Account number: 8078274

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_button_widget.dart';
import 'package:naqde_user/features/manual_transfer/screens/submit_transfer_screen.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class BankakTransferScreen extends StatelessWidget {
  const BankakTransferScreen({super.key});

  static const String _accountNumber  = '8078274';
  static const String _accountHolder  = 'عبدالقادر محمد أبوعيد';
  static const String _bankNameEn     = 'Bank of Khartoum (Bankak)';
  static const String _bankNameAr     = 'بنك الخرطوم (بنكك)';

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final bankName = isAr ? _bankNameAr : _bankNameEn;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppbarWidget(title: 'add_money'.tr, isBackButtonExist: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Info banner ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                isAr
                    ? 'حوّل إلى الحساب أدناه باستخدام تطبيق بنكك ثم أكّد الدفع هنا.'
                    : 'Transfer to the account below using the Bankak app, then confirm your payment here.',
                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
            ),

            const SizedBox(height: 24),

            // ── Step 1 ─────────────────────────────────────────────────
            _StepHeader(step: 1, label: 'add_money_step_1'.tr.isEmpty
                ? (isAr ? 'الخطوة 1: نسخ تفاصيل الحساب' : 'Step 1: Copy Account Details')
                : 'add_money_step_1'.tr),

            const SizedBox(height: 12),

            // Bank details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8, offset: const Offset(0, 2),
                )],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                _DetailRow(
                  label: isAr ? 'البنك' : 'Bank',
                  value: bankName,
                  icon: Icons.account_balance,
                ),
                const Divider(height: 20),
                _DetailRow(
                  label: isAr ? 'اسم صاحب الحساب' : 'Account Holder',
                  value: _accountHolder,
                  icon: Icons.person_outline,
                ),
                const Divider(height: 20),

                // Account number + copy button
                Row(children: [
                  Icon(Icons.credit_card, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      isAr ? 'رقم الحساب' : 'Account Number',
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor),
                    ),
                    Text(
                      _accountNumber,
                      style: rubikSemiBold.copyWith(fontSize: 20, letterSpacing: 2),
                    ),
                  ])),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _accountNumber));
                      Get.snackbar(
                        '',
                        'account_number_copied'.tr.isEmpty
                            ? (isAr ? 'تم نسخ رقم الحساب!' : 'Account number copied!')
                            : 'account_number_copied'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(12),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(
                      'copy_account_number'.tr.isEmpty
                          ? (isAr ? 'نسخ' : 'Copy')
                          : 'copy_account_number'.tr,
                      style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ]),

              ]),
            ),

            const SizedBox(height: 24),

            // ── Step 2 ─────────────────────────────────────────────────
            _StepHeader(step: 2, label: 'add_money_step_2'.tr.isEmpty
                ? (isAr ? 'الخطوة 2: التحويل في تطبيق بنكك' : 'Step 2: Transfer in Bankak App')
                : 'add_money_step_2'.tr),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Opens Bankak deep link if installed, otherwise shows store link
                  // url_launcher.launchUrl(Uri.parse('bankak://transfer'));
                  Get.snackbar(
                    isAr ? 'افتح تطبيق بنكك' : 'Open Bankak App',
                    isAr
                        ? 'افتح تطبيق بنكك وأكمل التحويل إلى رقم الحساب أعلاه.'
                        : 'Open the Bankak app and complete the transfer to the account above.',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  'open_bankak_app'.tr.isEmpty
                      ? (isAr ? 'افتح تطبيق بنكك' : 'Open Bankak App')
                      : 'open_bankak_app'.tr,
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Limits reminder ────────────────────────────────────────
            Row(children: [
              Expanded(child: _LimitChip(
                label: 'min_add_money'.tr.isEmpty
                    ? (isAr ? 'الحد الأدنى: ج.س 5,000' : 'Min: SDG 5,000')
                    : 'min_add_money'.tr,
                color: Colors.green,
              )),
              const SizedBox(width: 8),
              Expanded(child: _LimitChip(
                label: 'max_add_money'.tr.isEmpty
                    ? (isAr ? 'الحد الأقصى: ج.س 500,000' : 'Max: SDG 500,000')
                    : 'max_add_money'.tr,
                color: Colors.orange,
              )),
            ]),

            const SizedBox(height: 32),

            // ── Step 3 — Confirm ───────────────────────────────────────
            _StepHeader(step: 3, label: 'add_money_step_3'.tr.isEmpty
                ? (isAr ? 'الخطوة 3: تأكيد الدفع' : 'Step 3: Confirm Payment Here')
                : 'add_money_step_3'.tr),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: CustomButtonWidget(
                buttonText: 'confirm_payment'.tr.isEmpty
                    ? (isAr ? 'تأكيد الدفع' : 'Confirm Payment')
                    : 'confirm_payment'.tr,
                onTap: () => Get.to(() => const SubmitTransferScreen()),
                borderRadius: 10,
              ),
            ),

            const SizedBox(height: 24),

          ]),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final String label;
  const _StepHeader({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text('$step',
            style: rubikSemiBold.copyWith(color: Colors.white, fontSize: 14)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label,
          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault))),
    ]);
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor)),
        Text(value, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
      ]),
    ]);
  }
}

class _LimitChip extends StatelessWidget {
  final String label;
  final Color color;
  const _LimitChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
    );
  }
}
