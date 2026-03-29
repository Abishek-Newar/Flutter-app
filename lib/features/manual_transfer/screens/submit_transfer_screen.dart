// submit_transfer_screen.dart
// Two-step flow:
//   1. POST /add-money/initiate  → { bank, amount, sender_name, sender_account }
//   2. POST /add-money/upload-receipt (multipart) → { reference, receipt }
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
  final Map<String, dynamic> bank;
  const SubmitTransferScreen({super.key, required this.bank});

  @override
  State<SubmitTransferScreen> createState() => _S();
}

class _S extends State<SubmitTransferScreen> {
  final _form        = GlobalKey<FormState>();
  final _amount      = TextEditingController();
  final _senderName  = TextEditingController();
  final _senderAcct  = TextEditingController();
  File? _receipt;
  bool  _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _senderName.dispose();
    _senderAcct.dispose();
    super.dispose();
  }

  String get _bankName => widget.bank['bank_name']?.toString() ?? '';

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

                // ── Selected bank (read-only) ──────────────────────────────
                _Lbl(ar ? 'البنك المحدد' : 'Selected Bank'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300)),
                  child: Row(children: [
                    Icon(Icons.account_balance,
                      size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(_bankName, style: rubikMedium.copyWith(fontSize: 14)),
                  ]),
                ),

                const SizedBox(height: 18),

                // ── Amount ────────────────────────────────────────────────
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
                    if (n == null || n <= 0) return ar ? 'مبلغ غير صالح' : 'Invalid amount';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Sender name ───────────────────────────────────────────
                _Lbl(ar ? 'اسم المرسل' : 'Sender Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _senderName,
                  textCapitalization: TextCapitalization.words,
                  decoration: _dec(context,
                    hint: ar ? 'الاسم كما يظهر في البنك' : 'Name as shown in your bank',
                    icon: Icons.person_outline),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (ar ? 'اسم المرسل مطلوب' : 'Sender name required')
                      : null,
                ),

                const SizedBox(height: 18),

                // ── Sender account ─────────────────────────────────────────
                _Lbl(ar ? 'رقم حساب المرسل' : 'Sender Account Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _senderAcct,
                  keyboardType: TextInputType.number,
                  decoration: _dec(context,
                    hint: ar ? 'رقم الحساب الذي حوّلت منه' : 'Account you transferred from',
                    icon: Icons.credit_card),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (ar ? 'رقم الحساب مطلوب' : 'Account number required')
                      : null,
                ),

                const SizedBox(height: 18),

                // ── Receipt upload ─────────────────────────────────────────
                _Lbl(ar ? 'إيصال التحويل' : 'Transfer Receipt'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickReceipt,
                  child: Container(
                    height: 110, width: double.infinity,
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
                            const SizedBox(height: 2),
                            Text(ar ? 'jpg/png/pdf — 5MB كحد أقصى' : 'jpg/png/pdf — max 5 MB',
                              style: rubikRegular.copyWith(
                                color: Colors.grey.shade400, fontSize: 11)),
                          ]),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Notice ────────────────────────────────────────────────
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
                      style: rubikRegular.copyWith(
                        fontSize: 11, color: Colors.amber.shade900))),
                  ]),
                ),
              ]),
            )),

            // ── Submit ───────────────────────────────────────────────────
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

  Future<void> _pickReceipt() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null && mounted) setState(() => _receipt = File(p.path));
  }

  Future<void> _submit(bool ar) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      // Step 1 — initiate transfer
      final initResp = await Get.find<ApiClient>().postData(
        AppConstants.addMoneyInitiateUri,
        {
          'bank':           _bankName,
          'amount':         double.parse(_amount.text.trim()),
          'sender_name':    _senderName.text.trim(),
          'sender_account': _senderAcct.text.trim(),
        },
      );

      final initOk = initResp.statusCode == 200 || initResp.statusCode == 201;
      if (!initOk) {
        final msg = initResp.body is Map ? (initResp.body['message'] ?? '') : '';
        showCustomSnackBarHelper(
          msg.toString().isNotEmpty
              ? msg : (ar ? 'فشل بدء الطلب. حاول مرة أخرى.' : 'Failed to initiate. Please try again.'),
          isError: true);
        return;
      }

      final reference = (initResp.body['data']?['reference'] ??
                         initResp.body['reference'])?.toString() ?? '';

      // Step 2 — upload receipt (if provided)
      if (_receipt != null && reference.isNotEmpty) {
        final uploadResp = await Get.find<ApiClient>().postMultipartData(
          AppConstants.addMoneyReceiptUri,
          {'reference': reference},
          [MultipartBody('receipt', _receipt!)],
        );
        if (uploadResp.statusCode != 200 && uploadResp.statusCode != 201) {
          // Non-fatal: initiation succeeded, receipt upload failed
          showCustomSnackBarHelper(
            ar ? 'تم إرسال الطلب لكن فشل رفع الإيصال. يمكنك إعادة المحاولة لاحقاً.'
               : 'Request sent but receipt upload failed. You can retry later.',
            isError: false);
        }
      }

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
  final String t;
  const _Lbl(this.t);
  @override
  Widget build(BuildContext context) =>
    Text(t, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault));
}
