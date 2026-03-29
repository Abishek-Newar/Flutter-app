import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/referral_controller.dart';
import '../domain/models/referral_model.dart';

/// Horizontal stats strip — "250K+ Happy Users / 1.5M+ SDG Earned / 45K+ Active Referrals"
/// Data is loaded from the API; shows defaults while loading.
class ReferralStatsRow extends StatelessWidget {
  const ReferralStatsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(
      builder: (ctrl) {
        final stats = ctrl.stats;

        final users      = stats != null ? ReferralStatsModel.formatStat(stats.happyUsers)     : '250K+';
        final earned     = stats != null ? ReferralStatsModel.formatStat(stats.totalEarned)    : '1.5M+';
        final referrals  = stats != null ? ReferralStatsModel.formatStat(stats.activeReferrals) : '45K+';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 1.5,
                  style: BorderStyle.solid),
            ),
          ),
          child: Row(
            children: [
              _StatCell(number: users,     label: 'referral_stat_users'.tr),
              _Divider(),
              _StatCell(number: earned,    label: 'referral_stat_earned'.tr),
              _Divider(),
              _StatCell(number: referrals, label: 'referral_stat_referrals'.tr),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String number;
  final String label;
  const _StatCell({Key? key, required this.number, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: rubikSemiBold.copyWith(
              fontSize: 22,
              color: primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: rubikRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE5E7EB),
    );
  }
}
