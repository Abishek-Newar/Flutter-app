// remittance_corridor_screen.dart  —  Step 0: choose destination & payout
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';
import 'package:naqde_user/features/remittance/domain/models/remittance_model.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class RemittanceCorridorScreen extends StatelessWidget {
  const RemittanceCorridorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'send_abroad'.tr,
          isBackButtonExist: true,
          menuWidget: GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getRemittanceHistoryRoute()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.history_rounded,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          final popular = RemitCorridor.all.where((c) => c.popular).toList();
          final others  = RemitCorridor.all.where((c) => !c.popular).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Hero banner ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.70),
                    ],
                    begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    end:   isAr ? Alignment.centerLeft  : Alignment.centerRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSizeDefault),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('remit_from_sudan'.tr,
                      style: rubikLight.copyWith(
                          color: Colors.white70,
                          fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: 4),
                  Text('international_transfer'.tr,
                      style: rubikSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeSemiLarge)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.verified_outlined,
                        color: Colors.white60, size: 14),
                    const SizedBox(width: 6),
                    Text('remit_cbos_compliant'.tr,
                        style: rubikLight.copyWith(
                            color: Colors.white60,
                            fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Popular corridors (horizontal scroll) ──────────────
              Text('remit_popular_corridors'.tr,
                  style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popular.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _CorridorChip(
                    corridor: popular[i],
                    selected: ctrl.corridor?.code == popular[i].code,
                    onTap: () => ctrl.selectCorridor(popular[i]),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── All countries list ─────────────────────────────────
              Text('remit_select_country'.tr,
                  style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...others.map((c) => _CountryTile(
                corridor: c,
                isAr: isAr,
                selected: ctrl.corridor?.code == c.code,
                onTap: () => ctrl.selectCorridor(c),
              )),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Payout method chips (after selection) ──────────────
              if (ctrl.corridorSelected) ...[
                Text('remit_payout_method'.tr,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Wrap(
                  spacing: 10, runSpacing: 8,
                  children: ctrl.corridor!.methods.map((m) {
                    final sel = ctrl.payout == m;
                    return GestureDetector(
                      onTap: () => ctrl.selectPayout(m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusSizeOverLarge),
                          border: Border.all(
                            color: sel
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(m.i18nKey.tr,
                            style: rubikMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: sel
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],

              // ── Continue button ────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: ctrl.corridorSelected
                      ? () {
                          ctrl.goStep(1);
                          Get.toNamed(RouteHelper.getRemittanceAmountRoute());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius:
                        BorderRadius.circular(Dimensions.radiusSizeSmall)),
                  ),
                  child: Text('remit_get_rate'.tr,
                      style: rubikSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeLarge)),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

// ── Reusable chips ────────────────────────────────────────────────────────────

class _CorridorChip extends StatelessWidget {
  final RemitCorridor corridor;
  final bool selected;
  final VoidCallback onTap;
  const _CorridorChip(
      {required this.corridor, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 82,
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).primaryColor.withOpacity(0.10)
            : Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(corridor.flag, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(corridor.currency,
            style: rubikMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: selected
                    ? Theme.of(context).primaryColor
                    : null)),
      ]),
    ),
  );
}

class _CountryTile extends StatelessWidget {
  final RemitCorridor corridor;
  final bool isAr, selected;
  final VoidCallback onTap;
  const _CountryTile({
    required this.corridor, required this.isAr,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).primaryColor.withOpacity(0.08)
            : Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(children: [
        Text(corridor.flag, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(corridor.localizedName(isAr),
                style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: selected
                        ? Theme.of(context).primaryColor
                        : null)),
            Text(corridor.currency,
                style: rubikLight.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
          ],
        )),
        if (selected)
          Icon(Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor, size: 20),
      ]),
    ),
  );
}
