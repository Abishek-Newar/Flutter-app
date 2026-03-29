import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/trust_controller.dart';
import '../domain/models/trust_model.dart';

/// Rebalance button + result message card.
/// Admin-facing: triggers POST /trust/rebalance.
class TrustRebalanceButton extends StatelessWidget {
  const TrustRebalanceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrustSettlementController>(
      builder: (ctrl) => Column(
        children: [
          // Error/success message
          if (ctrl.showError || ctrl.showSuccess)
            _MessageBanner(isError: ctrl.showError,
                text: ctrl.showError ? ctrl.errorMessage! : ctrl.successMessage!),

          // Last rebalance result card
          if (ctrl.lastRebalance != null)
            _RebalanceResultCard(result: ctrl.lastRebalance!),

          // Rebalance button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: ctrl.isRebalancing ? null : ctrl.triggerRebalance,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1A2A6C), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: ctrl.isRebalancing
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A2A6C)))
                  : const Icon(Icons.sync_rounded, color: Color(0xFF1A2A6C), size: 20),
              label: Text(
                ctrl.isRebalancing ? 'Rebalancing…' : 'Simulate Daily Rebalance',
                style: rubikSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF1A2A6C)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RebalanceResultCard extends StatelessWidget {
  final RebalanceResultModel result;
  const _RebalanceResultCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!result.rebalanced) return const SizedBox.shrink();
    final isAr = Get.locale?.languageCode == 'ar';
    final dirText = result.direction == TrustAccountType.trust
        ? (isAr ? 'إلى حساب الثقة' : 'To Trust Account')
        : (isAr ? 'إلى حساب التسوية' : 'To Settlement Account');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
              const SizedBox(width: 8),
              Text('trust_rebalance_success'.tr,
                  style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF065F46))),
            ],
          ),
          const SizedBox(height: 6),
          Text('${isAr ? "مبلغ التحويل" : "Transfer"}: ${TrustBalanceModel.formatSdg(result.transferAmount)} $dirText',
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF065F46))),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final bool isError;
  final String text;
  const _MessageBanner({Key? key, required this.isError, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg     = isError ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    final border = isError ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0);
    final color  = isError ? const Color(0xFF991B1B) : const Color(0xFF065F46);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: color))),
        ],
      ),
    );
  }
}
