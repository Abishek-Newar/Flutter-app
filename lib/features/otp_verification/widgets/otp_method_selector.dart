import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../domain/models/otp_model.dart';
import '../controllers/otp_verification_controller.dart';

/// 2×2 grid of verification method cards.
/// Each card shows an icon, bilingual name, and description.
/// Tapping a card calls [OtpVerificationController.selectMethod].
class OtpMethodSelector extends StatelessWidget {
  const OtpMethodSelector({super.key});

  static const _methods = OtpMethod.values;

  static const _icons = {
    OtpMethod.sms: Icons.sms_outlined,
    OtpMethod.whatsapp: Icons.chat_outlined,   // Use font_awesome_flutter for fa-whatsapp if available
    OtpMethod.email: Icons.email_outlined,
    OtpMethod.push: Icons.notifications_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.shield_outlined,
                color: Theme.of(context).colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'otp_choose_method'.tr,
              style: rubikSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // 2x2 grid
        GetBuilder<OtpVerificationController>(
          builder: (ctrl) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: _methods.map((method) {
              final isSelected = ctrl.selectedMethod == method;
              final name = isAr ? method.labelAr() : method.labelEn();
              final desc = isAr ? method.descAr() : method.descEn();

              return _MethodCard(
                method: method,
                icon: _icons[method]!,
                name: name,
                desc: desc,
                isSelected: isSelected,
                onTap: () => ctrl.selectMethod(method),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final OtpMethod method;
  final IconData icon;
  final String name;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.method,
    required this.icon,
    required this.name,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$name. $desc',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.07)
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Stack(
            children: [
              // Top highlight bar
              if (isSelected)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                  ),
                ),

              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        icon,
                        size: 26,
                        color: isSelected ? primary : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall + 1,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall - 1,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
