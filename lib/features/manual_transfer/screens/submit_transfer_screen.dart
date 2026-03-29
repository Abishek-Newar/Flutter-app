// submit_transfer_screen.dart
// FIELD NAME: "Transaction Number" (not "Reference Number").
// Posts to /api/v1/manual-transfer/submit with field "transaction_number".
// SDG currency, bilingual EN/AR, full backend connectivity.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_button_widget.dart';
import 'package:naqde_user/common/widgets/custom_dialog_widget.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import 'package:naqde_user/helper/dialog_helper.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class SubmitTransferScreen extends StatefulWidget {
  const SubmitTransferScreen({super.key});
  @override State<SubmitTransferScreen> createState() => _S();
}

class _S extends State<SubmitTransferScreen> {
  final _form   = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _txNo   = TextEditingController();   // transaction_number field
  File?  _receipt;
  bool   _busy = false;

  @override
  void dispose() { _amount.dispose(); _txNo.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ar = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppbarWidget(
          title: ar ? 'تأكيد الدفع' : 'Confirm Payment',
          isBackButtonExist: true),
        body: Form(
          key: _form,
          child: Column(children: [
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Amount ─────────────────────────────────────────────
                _Lbl(ar ? 'المبلغ المحوَّل (ج.س)' : 'Transferred Amount (SDG)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: _dec(context,
                    hint: ar ? 'مثال: 10,000' : 'e.g. 10000',
                    icon: Icons.attach_money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return ar ? 'أدخل المبلغ' : 'Enter amount';
                    final n = double.tryParse(v);
                    if (n == null || n < 5000) return ar ? 'الحد الأدنى ج.س 5,000' : 'Min SDG 5,000';
                    if (n > 500000) return ar ? 'الحد الأقصى ج.س 500,000' : 'Max SDG 500,000';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Transaction Number (NOT "Reference Number") ─────────
                _Lbl(ar ? 'رقم المعاملة (Transaction Number)' : 'Transaction Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _txNo,
                  decoration: _dec(context,
                    hint: ar
                        ? 'رقم المعاملة من تطبيق بنكك'
                        : 'Transaction number from Bankak app',
                    icon: Icons.receipt_long),
                  validator: (v) => v == null || v.isEmpty
                      ? (ar ? 'رقم المعاملة مطلوب' : 'Transaction number required')
                      : null,
                ),

                const SizedBox(height: 18),

                // ── Receipt (optional) ──────────────────────────────────
                _Lbl(ar ? 'صورة الإيصال (اختياري)' : 'Receipt Screenshot (Optional)'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pick,
                  child: Container(
                    height: 100, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: .3))),
                    child: _receipt != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(10),
                            child: Image.file(_receipt!, fit: BoxFit.cover))
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.upload_file, size: 30,
                              color: Theme.of(context).primaryColor.withValues(alpha: .5)),
                            const SizedBox(height: 6),
                            Text(ar ? 'اضغط لرفع الإيصال' : 'Tap to upload receipt',
                              style: rubikRegular.copyWith(
                                color: Theme.of(context).hintColor, fontSize: 12)),
                          ]),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Notice ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      ar ? 'سيتم التحقق خلال 24 ساعة. لن يُضاف رصيد دون التحقق.'
                         : 'We will verify within 24 hours and credit your balance.',
                      style: rubikRegular.copyWith(fontSize: 11, color: Colors.amber.shade900))),
                  ]),
                ),
              ]),
            )),

            // ── Submit ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(width: double.infinity, height: 52,
                child: CustomButtonWidget(
                  buttonText: _busy
                      ? (ar ? 'جارٍ الإرسال...' : 'Submitting...')
                      : (ar ? 'إرسال طلب الإيداع' : 'Submit Deposit Request'),
                  onTap: _busy ? null : () => _submit(ar),
                  borderRadius: 10)),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _dec(BuildContext ctx, {required String hint, required IconData icon}) =>
    InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20),
      filled: true, fillColor: Theme.of(ctx).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14));

  Future<void> _pick() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (p != null) setState(() => _receipt = File(p.path));
  }

  Future<void> _submit(bool ar) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final resp = await Get.find<ApiClient>().postData(
        AppConstants.manualTransferSubmitUri,
        {
          'amount':             _amount.text.trim(),
          'transaction_number': _txNo.text.trim(),  // ← correct field name
          'bank':               'bankak',
        },
      );
      final ok = resp.statusCode == 200 || resp.statusCode == 201;
      if (ok) {
        Get.find<ProfileController>().getProfileData(reload: true);
        if (mounted) {
          DialogHelper.showAnimatedDialog(
            Get.context!,
            CustomDialogWidget(
              icon: Icons.check_circle,
              title: ar ? 'تم إرسال الطلب' : 'Request Submitted',
              description: ar
                  ? 'سنتحقق من التحويل خلال 24 ساعة وسيتم إضافة الرصيد تلقائياً.'
                  : 'We will verify within 24 hours and credit your wallet automatically.',
              isSingleButton: true,
              onTapFalseText: 'okay'.tr,
              onTapFalse: () { Get.back(); Get.back(); Get.back(); }),
            dismissible: false, isFlip: true);
        }
      } else {
        final msg = resp.body is Map ? (resp.body['message'] ?? '') : '';
        showCustomSnackBarHelper(
          msg.toString().isNotEmpty
              ? msg : (ar ? 'فشل الإرسال. حاول مرة أخرى.' : 'Submission failed. Please try again.'),
          isError: true);
      }
    } catch (_) {
      showCustomSnackBarHelper(
        ar ? 'خطأ في الاتصال' : 'Connection error. Please try again.',
        isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Lbl extends StatelessWidget {
  final String t; const _Lbl(this.t);
  @override
  Widget build(BuildContext context) =>
    Text(t, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault));
}
