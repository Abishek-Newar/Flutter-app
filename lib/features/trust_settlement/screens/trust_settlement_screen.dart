import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/trust_controller.dart';
import '../domain/models/trust_model.dart';
import '../widgets/trust_allocation_bar.dart';
import '../widgets/trust_architecture_cards.dart';
import '../widgets/trust_ledger_table.dart';
import '../widgets/trust_rebalance_button.dart';
import '../widgets/trust_stat_cards.dart';

/// TrustSettlementScreen
///
/// The main admin/operator screen for the CircleCash 80:20
/// Trust & Settlement fund allocation system.
///
/// Navigation — add to route_helper.dart:
/// ```dart
/// static const String trustSettlement = '/trust-settlement';
/// static String getTrustSettlementRoute() => trustSettlement;
///
/// GetPage(
///   name: trustSettlement,
///   page: () => const TrustSettlementScreen(),
///   transition: Transition.fadeIn,
/// ),
/// ```
class TrustSettlementScreen extends StatelessWidget {
  const TrustSettlementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomAppbarWidget(
        title: 'trust_settlement_title'.tr,
        actionWidget: _LanguageToggle(),
      ),
      body: RefreshIndicator(
        onRefresh: () => Get.find<TrustSettlementController>().loadAll(),
        color: const Color(0xFF1A2A6C),
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          children: [
            // Currency badge
            _CurrencyBadge(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Stat cards
            const TrustStatCards(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Allocation bar
            const TrustAllocationBar(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Rebalance button
            const TrustRebalanceButton(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Ledger table
            const TrustLedgerTable(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Architecture overview
            const TrustArchitectureCards(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Footer
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _CurrencyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDBB2D),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded, color: Color(0xFF1A2A6C), size: 18),
            const SizedBox(width: 8),
            Text(
              'trust_currency_badge'.tr,
              style: rubikSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF1A2A6C)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text('trust_footer'.tr,
              style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('trust_licensed'.tr,
              style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () => Get.updateLocale(
          isAr ? const Locale('en', 'US') : const Locale('ar', 'SD'),
        ),
        child: Text(
          isAr ? 'English' : 'العربية',
          style: rubikSemiBold.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}
