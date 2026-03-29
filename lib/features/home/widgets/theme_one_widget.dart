// theme_one_widget.dart  — DEFINITIVE production version
// Row-1 (4 cards): Send Money | Cash Out | Request Money | Withdraw Money
// Row-2 (3 cards): Send Abroad | Offline Wallet | Refer Friend
// OTP, Remittance, Offline Wallet are all accessible from home.
// Balance bar + Add Money button → Bankak flow.
// No overflow. Full RTL. SDG only (no $).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_showcase_widget.dart';
import 'package:naqde_user/features/home/domain/models/global_key_manager_model.dart';
import 'package:naqde_user/features/manual_transfer/screens/bank_list_screen.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/features/splash/controllers/splash_controller.dart';
import 'package:naqde_user/helper/price_converter_helper.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/helper/transaction_type.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/features/home/widgets/banner_widget.dart';
import 'package:naqde_user/features/transaction_money/screens/transaction_money_screen.dart';

class ThemeOneWidget extends StatelessWidget {
  final GlobalKeyManagerModel keyManager;
  final GlobalKey? lastKey;
  const ThemeOneWidget({super.key, required this.keyManager, this.lastKey});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return GetBuilder<SplashController>(builder: (sc) {
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(children: [

          // ── Blue header + balance card ─────────────────────────────────
          Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
            Positioned(left: 12, right: 12, top: 12, child:
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12, offset: const Offset(0, 4),
                  )],
                ),
                child: Row(children: [
                  // Balance
                  Expanded(child: GetBuilder<ProfileController>(builder: (pc) {
                    return pc.isUserBalanceHide() && !pc.showBalanceButtonTapped
                      ? GestureDetector(
                          onTap: () => pc.updateBalanceButtonTappedStatus(shouldUpdate: true),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.touch_app_outlined, size: 15),
                            const SizedBox(width: 4),
                            Flexible(child: Text('tap_for_balance'.tr,
                              overflow: TextOverflow.ellipsis,
                              style: rubikRegular.copyWith(fontSize: 12))),
                          ]),
                        )
                      : Column(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            PriceConverterHelper.balanceWithSymbol(
                              balance: '${(pc.userInfo?.balance ?? 0).clamp(0, double.infinity)}'),
                            style: rubikSemiBold.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('available_balance'.tr,
                            style: rubikRegular.copyWith(
                              fontSize: 11, color: Theme.of(context).hintColor, height: 1.2)),
                        ]);
                  })),
                  const SizedBox(width: 8),
                  // Add Money → Bankak (only when feature active)
                  if (sc.configModel?.systemFeature?.addMoneyStatus ?? false)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const BankListScreen()),
                        icon: const Icon(Icons.add, size: 15),
                        label: Text('add_money'.tr,
                          style: rubikMedium.copyWith(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ]),

          const SizedBox(height: 10),

          // ── ROW 1 – 4 primary action cards ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(builder: (ctx, box) {
              final w = (box.maxWidth - 24) / 4; // 4 equal cards
              return Row(children: [

                if (sc.configModel?.systemFeature?.sendMoneyStatus ?? false)
                  _Card(w: w, showcaseKey: keyManager.sendMoneyKey,
                    isDone: lastKey == keyManager.sendMoneyKey,
                    icon: Icons.send_rounded, color: const Color(0xFF1976D2),
                    label: 'send_money'.tr,
                    onTap: () => Get.to(() => const TransactionMoneyScreen(
                      fromEdit: false, transactionType: TransactionType.sendMoney))),

                if (sc.configModel?.systemFeature?.cashOutStatus ?? false)
                  _Card(w: w, showcaseKey: keyManager.cashOutKey,
                    isDone: lastKey == keyManager.cashOutKey,
                    icon: Icons.point_of_sale_rounded, color: const Color(0xFF388E3C),
                    label: 'cash_out'.tr,
                    onTap: () => Get.to(() => const TransactionMoneyScreen(
                      fromEdit: false, transactionType: TransactionType.cashOut))),

                if (sc.configModel?.systemFeature?.sendMoneyRequestStatus ?? false)
                  _Card(w: w, showcaseKey: keyManager.requestMoneyKey,
                    isDone: lastKey == keyManager.requestMoneyKey,
                    icon: Icons.request_page_rounded, color: const Color(0xFFE65100),
                    label: 'request_money'.tr,
                    onTap: () => Get.to(() => const TransactionMoneyScreen(
                      fromEdit: false, transactionType: TransactionType.requestMoney))),

                if (sc.configModel?.systemFeature?.withdrawRequestStatus ?? false)
                  _Card(w: w, showcaseKey: keyManager.sendMoneyRequestKey,
                    isDone: lastKey == keyManager.sendMoneyRequestKey,
                    icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF6A1B9A),
                    label: 'withdraw_money'.tr,
                    onTap: () => Get.toNamed(RouteHelper.getWithdrawalAmountRoute())),

              ]);
            }),
          ),

          const SizedBox(height: 8),

          // ── ROW 2 – 3 secondary action cards ──────────────────────────
          // These were previously MISSING from the home page.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(builder: (ctx, box) {
              final w = (box.maxWidth - 16) / 3;
              return Row(children: [

                // Remittance / Send Abroad
                _Card(w: w, h: 90, showcaseKey: keyManager.appbarBalanceKey,
                  isDone: false, icon: Icons.flight_takeoff_rounded,
                  color: const Color(0xFF00838F), label: 'send_abroad'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getRemittanceCorridorRoute())),

                // Offline Wallet
                _Card(w: w, h: 90, showcaseKey: keyManager.cashOutKey,
                  isDone: false, icon: Icons.wifi_off_rounded,
                  color: const Color(0xFF558B2F), label: 'offline_wallet'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getOfflineWalletRoute())),

                // Refer Friend
                _Card(w: w, h: 90, showcaseKey: keyManager.requestMoneyKey,
                  isDone: false, icon: Icons.group_add_rounded,
                  color: const Color(0xFFC62828), label: 'refer_friend'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getReferralRoute())),

              ]);
            }),
          ),

          const SizedBox(height: 10),
          const BannerWidget(),
        ]),
      );
    });
  }
}

// ── Shared card widget ─────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final double w;
  final double h;
  final GlobalKey showcaseKey;
  final bool isDone;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _Card({
    required this.w,
    this.h = 100,
    required this.showcaseKey,
    required this.isDone,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomShowcaseWidget(
          showcaseKey: showcaseKey,
          title: label, subtitle: '', isDone: isDone, padding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8, offset: const Offset(0, 3),
                )],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(label,
                    textAlign: TextAlign.center, maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: rubikRegular.copyWith(fontSize: 10.5, height: 1.25)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
