import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

/// Three architecture info cards: Trust | Settlement | Auto-Rebalance
class TrustArchitectureCards extends StatelessWidget {
  const TrustArchitectureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_rounded, color: Color(0xFF1A2A6C), size: 20),
              const SizedBox(width: 10),
              Text('arch_trust_title'.tr,
                  style: rubikSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: const Color(0xFF1A2A6C))),
            ],
          ),
          const SizedBox(height: 16),
          _ArchCard(
            icon:    Icons.shield_rounded,
            iconBg:  const Color(0xFF1A2A6C),
            title:   'arch_trust_title'.tr,
            desc:    'arch_trust_desc'.tr,
            points:  ['arch_trust_1', 'arch_trust_2', 'arch_trust_3'],
          ),
          const SizedBox(height: 12),
          _ArchCard(
            icon:    Icons.swap_horiz_rounded,
            iconBg:  const Color(0xFF1A2A6C),
            title:   'arch_settle_title'.tr,
            desc:    'arch_settle_desc'.tr,
            points:  ['arch_settle_1', 'arch_settle_2', 'arch_settle_3'],
          ),
          const SizedBox(height: 12),
          _ArchCard(
            icon:    Icons.smart_toy_rounded,
            iconBg:  const Color(0xFF1A2A6C),
            title:   'arch_auto_title'.tr,
            desc:    'arch_auto_desc'.tr,
            points:  ['arch_auto_1', 'arch_auto_2', 'arch_auto_3'],
          ),
        ],
      ),
    );
  }
}

class _ArchCard extends StatelessWidget {
  final IconData icon;
  final Color    iconBg;
  final String   title, desc;
  final List<String> points;

  const _ArchCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.desc,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF1A2A6C))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(desc,
              style: rubikRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.grey.shade600,
                  height: 1.5)),
          const SizedBox(height: 10),
          ...points.map((k) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 14),
                const SizedBox(width: 8),
                Text(k.tr,
                    style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF4B5563))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
