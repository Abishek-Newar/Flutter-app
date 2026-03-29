// bank_list_screen.dart  — self-contained, no required ctor params.
// Step 1: copy account details (Bankak hardcoded).
// Step 2: open Bankak app.
// Step 3: → SubmitTransferScreen to enter Transaction Number.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/features/manual_transfer/screens/submit_transfer_screen.dart';
import 'package:naqde_user/features/manual_transfer/screens/transfer_history_screen.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class BankListScreen extends StatelessWidget {
  const BankListScreen({super.key});

  static const _acct   = '8078274';
  static const _holder = 'عبدالقادر محمد أبوعيد';

  @override
  Widget build(BuildContext context) {
    final ar = Get.locale?.languageCode == 'ar';
    final bankName = ar ? 'بنك الخرطوم (بنكك)' : 'Bank of Khartoum (Bankak)';

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppbarWidget(
          title: 'add_money'.tr,
          isBackButtonExist: true,
          menuWidget: TextButton(
            onPressed: () => Get.to(() => const TransferHistoryScreen()),
            child: Text(ar ? 'السجل' : 'History',
              style: TextStyle(color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Info banner ────────────────────────────────────────────
            _InfoBanner(ar ? 'حوّل إلى الحساب أدناه عبر تطبيق بنكك، ثم أكّد الدفع.' :
              'Transfer to the account below via the Bankak app, then confirm your payment.'),

            const SizedBox(height: 20),
            _StepRow(1, ar ? 'الخطوة 1: نسخ تفاصيل الحساب' : 'Step 1: Copy Account Details'),
            const SizedBox(height: 12),

            // ── Bank card ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06),
                  blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(children: [
                _InfoRow(Icons.account_balance, ar ? 'البنك' : 'Bank', bankName),
                Divider(height: 18, color: Colors.grey.shade200),
                _InfoRow(Icons.person_outline, ar ? 'اسم صاحب الحساب' : 'Account Holder', _holder),
                Divider(height: 18, color: Colors.grey.shade200),
                Row(children: [
                  Icon(Icons.credit_card, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ar ? 'رقم الحساب' : 'Account Number',
                      style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey)),
                    Text(_acct, style: rubikSemiBold.copyWith(fontSize: 22, letterSpacing: 2.5)),
                  ])),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _acct));
                      Get.snackbar('', ar ? 'تم نسخ رقم الحساب!' : 'Account number copied!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white, duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(12));
                    },
                    icon: const Icon(Icons.copy, size: 15),
                    label: Text(ar ? 'نسخ' : 'Copy',
                      style: rubikMedium.copyWith(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  ),
                ]),
              ]),
            ),

            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _LimitBadge(ar ? 'الحد الأدنى: ج.س 5,000' : 'Min: SDG 5,000', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _LimitBadge(ar ? 'الحد الأقصى: ج.س 500,000' : 'Max: SDG 500,000', Colors.orange)),
            ]),

            const SizedBox(height: 22),
            _StepRow(2, ar ? 'الخطوة 2: التحويل في تطبيق بنكك' : 'Step 2: Transfer in Bankak App'),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Get.snackbar(
                  ar ? 'افتح تطبيق بنكك' : 'Open Bankak App',
                  ar ? 'انسخ رقم الحساب وأكمل التحويل في تطبيق بنكك'
                     : 'Copy the account number and complete the transfer in Bankak',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(ar ? 'افتح تطبيق بنكك' : 'Open Bankak App',
                  style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),

            const SizedBox(height: 22),
            _StepRow(3, ar ? 'الخطوة 3: تأكيد الدفع هنا' : 'Step 3: Confirm Payment Here'),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const SubmitTransferScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(ar ? 'تأكيد الدفع' : 'Confirm Payment',
                  style: rubikMedium.copyWith(fontSize: 15)),
              ),
            ),

            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int n; final String label;
  const _StepRow(this.n, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 26, height: 26,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('$n', style: rubikSemiBold.copyWith(color: Colors.white, fontSize: 12))),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: rubikMedium.copyWith(fontSize: 13))),
  ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 18, color: Theme.of(context).primaryColor),
    const SizedBox(width: 8),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey)),
      Text(value,  style: rubikMedium.copyWith(fontSize: 13)),
    ]),
  ]);
}

class _LimitBadge extends StatelessWidget {
  final String t; final Color c;
  const _LimitBadge(this.t, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: c.withValues(alpha: .1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: c.withValues(alpha: .4))),
    child: Text(t, textAlign: TextAlign.center,
      style: rubikRegular.copyWith(fontSize: 11, color: c)),
  );
}

class _InfoBanner extends StatelessWidget {
  final String text; const _InfoBanner(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .2))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: rubikRegular.copyWith(fontSize: 13))),
    ]),
  );
}
