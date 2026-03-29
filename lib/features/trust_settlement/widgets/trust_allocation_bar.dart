import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/trust_controller.dart';
import '../domain/models/trust_model.dart';

/// Visual 80:20 allocation bar — mirrors the HTML allocation-chart.
/// Uses actual ratios from the API, not hardcoded percentages.
class TrustAllocationBar extends StatelessWidget {
  const TrustAllocationBar({Key? key}) : super(key: key);

  static const _trustGreen  = Color(0xFF059669);
  static const _trustGreen2 = Color(0xFF047857);
  static const _purple      = Color(0xFF7C3AED);
  static const _purple2     = Color(0xFF6D28D9);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrustSettlementController>(
      builder: (ctrl) {
        final trustRatio = ctrl.balances?.trustRatio ?? 0.8;
        final settlementRatio = ctrl.balances?.settlementRatio ?? 0.2;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, color: Color(0xFF1A2A6C), size: 20),
                  const SizedBox(width: 10),
                  Text('allocation_title'.tr,
                      style: rubikSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: const Color(0xFF1A2A6C))),
                ],
              ),
              const SizedBox(height: 20),

              // Allocation bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      // Trust segment
                      Flexible(
                        flex: (trustRatio * 100).round(),
                        child: _Segment(
                          gradient: const LinearGradient(
                              colors: [_trustGreen, _trustGreen2]),
                          label: '${(trustRatio * 100).round()}%',
                        ),
                      ),
                      // Settlement segment
                      Flexible(
                        flex: (settlementRatio * 100).round(),
                        child: _Segment(
                          gradient: const LinearGradient(
                              colors: [_purple, _purple2]),
                          label: '${(settlementRatio * 100).round()}%',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Legend
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  _LegendDot(color: _trustGreen,  text: 'legend_trust'.tr),
                  _LegendDot(color: _purple,       text: 'legend_settlement'.tr),
                ],
              ),

              // Compliance note (shows warning if out of balance)
              if (ctrl.balances != null && !ctrl.balances!.isCompliant)
                _ComplianceWarning(),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final Gradient gradient;
  final String label;
  const _Segment({Key? key, required this.gradient, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: Text(label,
          style: rubikSemiBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(text, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ],
    );
  }
}

class _ComplianceWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        border: Border.all(color: const Color(0xFFFBBF24)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ratio outside 80:20 target — rebalancing recommended',
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline allocation preview card shown when user types an amount
class TrustAllocationPreview extends StatelessWidget {
  final double amount;
  final bool isDeposit;
  const TrustAllocationPreview({
    Key? key,
    required this.amount,
    required this.isDeposit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();

    final split = TrustBalanceModel.split(amount, isDeposit: isDeposit);
    final trustAmt      = split['trust']!;
    final settlementAmt = split['settlement']!;
    final totalAmt      = split['total']!;
    final isPositive    = totalAmt >= 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(amount),
        width: double.infinity,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('allocation_title'.tr,
                style: rubikSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF1A2A6C))),
            const SizedBox(height: 14),
            _PreviewRow(
              icon:  Icons.shield_rounded,
              color: const Color(0xFF059669),
              label: 'trust_account_pct'.tr,
              value: TrustBalanceModel.formatSdg(trustAmt),
              positive: isPositive,
            ),
            const Divider(height: 1),
            _PreviewRow(
              icon:  Icons.swap_horiz_rounded,
              color: const Color(0xFF7C3AED),
              label: 'settlement_account_pct'.tr,
              value: TrustBalanceModel.formatSdg(settlementAmt),
              positive: isPositive,
            ),
            const Divider(height: 1),
            _PreviewRow(
              icon:  Icons.calculate_rounded,
              color: const Color(0xFF1A2A6C),
              label: 'Total',
              value: TrustBalanceModel.formatSdg(totalAmt),
              positive: isPositive,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label, value;
  final bool     positive, isBold;

  const _PreviewRow({
    Key? key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.positive,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueColor = positive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final style = isBold
        ? rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: valueColor)
        : rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: valueColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF4B5563))),
          ),
          Text(value, style: style, textDirection: TextDirection.ltr),
        ],
      ),
    );
  }
}
