import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/trust_controller.dart';
import '../domain/models/trust_model.dart';

/// Row of three stat cards: Trust (80%) | Settlement (20%) | Total
/// Mirrors the HTML stat-grid. Uses shimmer while loading.
class TrustStatCards extends StatelessWidget {
  const TrustStatCards({super.key});

  static const _trustGreen      = Color(0xFF059669);
  static const _trustGreenLight = Color(0xFFD1FAE5);
  static const _settlePurple     = Color(0xFF7C3AED);
  static const _settlePurpleLight = Color(0xFFEDE9FE);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrustSettlementController>(
      builder: (ctrl) {
        if (ctrl.isLoading || ctrl.balances == null) {
          return _buildShimmer();
        }
        final b = ctrl.balances!;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(
                  icon:       Icons.shield_rounded,
                  iconBg:     _trustGreenLight,
                  iconColor:  _trustGreen,
                  badgeText:  'trust_badge'.tr,
                  badgeBg:    _trustGreenLight,
                  badgeColor: _trustGreen,
                  value:      TrustBalanceModel.formatSdg(b.trustBalance),
                  label:      'trust_safeguarded'.tr,
                  progress:   b.trustRatio,
                  progressColor: _trustGreen,
                  statusText: 'trust_compliant'.tr,
                  statusOk:   b.isCompliant,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  icon:       Icons.swap_horiz_rounded,
                  iconBg:     _settlePurpleLight,
                  iconColor:  _settlePurple,
                  badgeText:  'settlement_badge'.tr,
                  badgeBg:    _settlePurpleLight,
                  badgeColor: _settlePurple,
                  value:      TrustBalanceModel.formatSdg(b.settlementBalance),
                  label:      'settlement_liquidity'.tr,
                  progress:   b.settlementRatio,
                  progressColor: _settlePurple,
                  statusText: 'settlement_active'.tr,
                  statusOk:   true,
                )),
              ],
            ),
            const SizedBox(height: 12),
            _TotalCard(balance: b),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _shimmerBox(140)),
          const SizedBox(width: 12),
          Expanded(child: _shimmerBox(140)),
        ]),
        const SizedBox(height: 12),
        _shimmerBox(80),
      ],
    );
  }

  Widget _shimmerBox(double h) => Container(
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

// ─── Individual stat card ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData iconData;
  final Color    iconBg, iconColor;
  final String   badgeText;
  final Color    badgeBg, badgeColor;
  final String   value, label;
  final double   progress;
  final Color    progressColor;
  final String   statusText;
  final bool     statusOk;

  const _StatCard({
    required IconData icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
    required this.value,
    required this.label,
    required this.progress,
    required this.progressColor,
    required this.statusText,
    required this.statusOk,
  })  : iconData = icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: progressColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(badgeText,
                    style: rubikSemiBold.copyWith(fontSize: 10, color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: rubikSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSemiLarge,
                  color: const Color(0xFF1A2A6C)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label,
              style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(statusOk ? Icons.check_circle_rounded : Icons.warning_rounded,
                  size: 14,
                  color: statusOk ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              const SizedBox(width: 5),
              Text(statusText,
                  style: rubikSemiBold.copyWith(
                    fontSize: 11,
                    color: statusOk ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Total card (full-width, dark) ───────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final TrustBalanceModel balance;
  const _TotalCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2A6C), Color(0xFF233A9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF1A2A6C).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TrustBalanceModel.formatSdg(balance.totalBalance),
                    style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSemiLarge, color: Colors.white)),
                const SizedBox(height: 4),
                Text('total_deposits'.tr,
                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white70)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('total_badge'.tr,
                    style: rubikSemiBold.copyWith(fontSize: 11, color: Colors.white)),
              ),
              const SizedBox(height: 6),
              Text('${balance.totalTransactions} txns',
                  style: rubikRegular.copyWith(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
