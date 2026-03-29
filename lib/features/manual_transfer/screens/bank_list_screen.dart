// bank_list_screen.dart — loads banks from /add-money/banks
// Step 1: select bank from server list.
// Step 2: open your banking app and transfer.
// Step 3: → SubmitTransferScreen to confirm + upload receipt.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/features/manual_transfer/screens/submit_transfer_screen.dart';
import 'package:naqde_user/features/manual_transfer/screens/transfer_history_screen.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class BankListScreen extends StatefulWidget {
  const BankListScreen({super.key});

  @override
  State<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends State<BankListScreen> {
  List<Map<String, dynamic>> _banks = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    setState(() { _loading = true; _error = false; });
    try {
      final r = await Get.find<ApiClient>().getData(AppConstants.addMoneyBanksUri);
      if (r.statusCode == 200 && r.body != null) {
        final raw = r.body['data'] ?? r.body['content'] ?? r.body;
        if (raw is List) {
          _banks = raw.cast<Map<String, dynamic>>();
        }
      } else {
        _error = true;
      }
    } catch (_) {
      _error = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ar = Get.locale?.languageCode == 'ar';

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
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
                ? _ErrorView(ar: ar, onRetry: _loadBanks)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _InfoBanner(ar
                          ? 'حوّل إلى أحد الحسابات أدناه، ثم أكّد الدفع برفع الإيصال.'
                          : 'Transfer to one of the accounts below, then confirm by uploading your receipt.'),
                      const SizedBox(height: 20),
                      Text(ar ? 'اختر البنك' : 'Select a Bank',
                        style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: 12),
                      ..._banks.map((bank) => _BankTile(
                        bank: bank,
                        ar: ar,
                        onTap: () => Get.to(() => SubmitTransferScreen(bank: bank)),
                      )),
                      if (_banks.isEmpty)
                        Center(child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(ar ? 'لا توجد بنوك متاحة حالياً' : 'No banks available',
                            style: rubikRegular.copyWith(color: Colors.grey)),
                        )),
                      const SizedBox(height: 24),
                    ]),
                  ),
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  final Map<String, dynamic> bank;
  final bool ar;
  final VoidCallback onTap;
  const _BankTile({required this.bank, required this.ar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bankName    = bank['bank_name']?.toString() ?? '';
    final acctName    = bank['account_name']?.toString() ?? '';
    final acctNumber  = bank['account_number']?.toString() ?? '';
    final instructions = bank['instructions']?.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance,
              color: Theme.of(context).primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bankName, style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: 2),
            Text(acctName, style: rubikRegular.copyWith(fontSize: 12, color: Colors.grey)),
            Text(acctNumber, style: rubikMedium.copyWith(fontSize: 13, letterSpacing: 1.5)),
            if (instructions != null && instructions.isNotEmpty)
              Text(instructions,
                style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey.shade500),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Icon(ar ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool ar;
  final VoidCallback onRetry;
  const _ErrorView({required this.ar, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      Text(ar ? 'فشل تحميل البنوك' : 'Failed to load banks'),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: onRetry,
        child: Text(ar ? 'إعادة المحاولة' : 'Retry')),
    ],
  ));
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);

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
