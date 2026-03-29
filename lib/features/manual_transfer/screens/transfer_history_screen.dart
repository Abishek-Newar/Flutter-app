// transfer_history_screen.dart — stable, no required ctor params
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});
  @override State<TransferHistoryScreen> createState() => _S();
}

class _S extends State<TransferHistoryScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _error   = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final r = await Get.find<ApiClient>().getData(AppConstants.addMoneyHistoryUri);
      if (r.statusCode == 200) {
        _items = (r.body is Map
            ? (r.body['content'] ?? r.body['data'] ?? [])
            : (r.body ?? [])) as List<dynamic>;
      } else { _error = true; }
    } catch (_) { _error = true; }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ar = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppbarWidget(
          title: ar ? 'سجل التحويلات' : 'Transfer History',
          isBackButtonExist: true),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(ar ? 'فشل التحميل' : 'Failed to load'),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load,
                        child: Text(ar ? 'إعادة المحاولة' : 'Retry')),
                  ]))
                : _items.isEmpty
                    ? Center(child: Text(ar ? 'لا توجد تحويلات بعد' : 'No transfers yet',
                        style: rubikRegular.copyWith(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _Tile(
                            item: _items[i] as Map<String, dynamic>, ar: ar),
                        )),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Map<String, dynamic> item; final bool ar;
  const _Tile({required this.item, required this.ar});

  Color get _color {
    switch ((item['status'] ?? '').toString().toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default:         return Colors.orange;
    }
  }

  String get _statusLabel {
    final s = (item['status'] ?? 'pending').toString().toLowerCase();
    if (ar) {
      if (s == 'approved') return 'مقبول';
      if (s == 'rejected') return 'مرفوض';
      return 'في انتظار التحقق';
    }
    if (s == 'approved') return 'Approved';
    if (s == 'rejected') return 'Rejected';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1.5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _color.withValues(alpha: .12),
        child: Icon(Icons.account_balance, color: _color, size: 20)),
      title: Text(
        '${ar ? "ج.س" : "SDG"} ${item["amount"] ?? "—"}',
        style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((item['transaction_number'] ?? item['reference_number']) != null)
          Text(
            '${ar ? "رقم المعاملة" : "TX"}: ${item["transaction_number"] ?? item["reference_number"]}',
            style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey)),
        Text(item['created_at']?.toString().substring(0, 10) ?? '',
          style: rubikRegular.copyWith(fontSize: 11, color: Colors.grey)),
      ]),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withValues(alpha: .4))),
        child: Text(_statusLabel,
          style: rubikMedium.copyWith(color: _color, fontSize: 11))),
    ),
  );
}
