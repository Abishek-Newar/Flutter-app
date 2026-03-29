// lib/features/offline_wallet/screens/offline_wallet_screen.dart
// Fixed: GetX only (no flutter_bloc), uses .tr for bilingual, SDG currency

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/features/offline_wallet/controllers/offline_wallet_controller.dart';
import '../domain/models/offline_wallet_models.dart';
import '../widgets/offline_balance_card.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/transaction_list_widget.dart';
import '../l10n/offline_wallet_localizations.dart';
import 'send_payment_screen.dart';
import 'bluetooth_transfer_screen.dart';
import 'nfc_transfer_screen.dart';
import 'sms_relay_screen.dart';
import 'transaction_history_screen.dart' as ow_history;

class OfflineWalletScreen extends StatefulWidget {
  const OfflineWalletScreen({super.key});
  @override
  State<OfflineWalletScreen> createState() => _OfflineWalletScreenState();
}

class _OfflineWalletScreenState extends State<OfflineWalletScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<OfflineWalletController>();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final l = OfflineWalletLocalizations(isAr ? const Locale('ar') : const Locale('en'));

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: CustomAppbarWidget(
          title: 'offline_wallet'.tr.isEmpty ? (isAr ? 'المحفظة غير المتصلة' : 'Offline Wallet') : 'offline_wallet'.tr,
          isBackButtonExist: true,
          menuWidget: GetBuilder<OfflineWalletController>(builder: (ctrl) {
            if (ctrl.pendingSyncCount == 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: ctrl.syncNow,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  ctrl.isSyncing
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('${ctrl.pendingSyncCount}',
                      style: rubikMedium.copyWith(color: Colors.white, fontSize: 13)),
                ]),
              ),
            );
          }),
        ),
        body: GetBuilder<OfflineWalletController>(builder: (ctrl) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async { ctrl.syncNow(); },
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: Column(children: [

                // ── Balance Card ─────────────────────────────────────────
                StreamBuilder<WalletBalance>(
                  stream: ctrl.txService.balanceStream,
                  initialData: WalletBalance.empty(),
                  builder: (_, snap) => OfflineBalanceCard(
                    balance: snap.data ?? WalletBalance.empty(),
                    localizations: l,
                  ),
                ),

                // ── Quick Actions ────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8, offset: const Offset(0, 2),
                    )],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _ActionBtn(
                      icon: Icons.qr_code_scanner,
                      label: isAr ? 'مسح QR' : 'Scan QR',
                      color: const Color(0xFF1976D2),
                      onTap: () => Get.to(() => SendPaymentScreen(txService: ctrl.txService)),
                    ),
                    _ActionBtn(
                      icon: Icons.qr_code,
                      label: isAr ? 'عرض QR' : 'My QR',
                      color: const Color(0xFF1976D2),
                      onTap: () => _showMyQr(context, isAr),
                    ),
                    _ActionBtn(
                      icon: Icons.bluetooth,
                      label: isAr ? 'بلوتوث' : 'Bluetooth',
                      color: Colors.blue.shade700,
                      onTap: () => Get.to(() => BluetoothTransferScreen(
                        meshService: ctrl.meshService,
                        txService: ctrl.txService,
                        mode: BluetoothMode.send,
                      )),
                    ),
                    _ActionBtn(
                      icon: Icons.nfc,
                      label: 'NFC',
                      color: Colors.purple,
                      onTap: () => ctrl.isNfcAvailable
                          ? Get.to(() => NFCTransferScreen(
                                nfcService: ctrl.nfcService,
                                txService: ctrl.txService,
                                mode: NFCMode.write,
                              ))
                          : Get.snackbar(
                              '',
                              isAr ? 'NFC غير متاح على هذا الجهاز' : 'NFC not available on this device',
                              snackPosition: SnackPosition.BOTTOM,
                            ),
                    ),
                    _ActionBtn(
                      icon: Icons.sms,
                      label: 'SMS',
                      color: Colors.green.shade700,
                      onTap: () => Get.to(() => SMSRelayScreen(txService: ctrl.txService)),
                    ),
                  ]),
                ),

                // ── Connection Status ────────────────────────────────────
                ConnectionStatusBar(localizations: l),

                const SizedBox(height: 8),

                // ── History header ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(isAr ? 'المعاملات الأخيرة' : 'Recent Transactions',
                        style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    TextButton(
                      onPressed: () => Get.to(() =>
                          ow_history.TransactionHistoryScreen(txService: ctrl.txService)),
                      child: Text(isAr ? 'عرض الكل' : 'View All',
                          style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ]),
                ),
              ])),

              // ── Transaction list ────────────────────────────────────────
              SliverFillRemaining(
                child: StreamBuilder<List<OfflineTransaction>>(
                  stream: ctrl.txService.recentTransactionsStream,
                  initialData: const [],
                  builder: (_, snap) => TransactionListWidget(
                    transactions: snap.data ?? [],
                    localizations: l,
                    emptyMessage: isAr ? 'لا توجد معاملات بعد' : 'No transactions yet',
                  ),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }

  void _showMyQr(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAr ? 'رمز QR الخاص بي' : 'My QR Code'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.qr_code, size: 120, color: Colors.black87),
          const SizedBox(height: 12),
          Text(
            isAr ? 'اطلب من المُرسل مسح هذا الرمز' : 'Ask the sender to scan this code',
            textAlign: TextAlign.center,
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
        ]),
        actions: [TextButton(
          onPressed: () => Get.back(),
          child: Text(isAr ? 'إغلاق' : 'Close'),
        )],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(width: 56, child: Column(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: rubikRegular.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
    );
  }
}
