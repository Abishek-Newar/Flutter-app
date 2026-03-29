// remittance_history_screen.dart  —  paginated transfer history
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';
import 'package:naqde_user/features/remittance/domain/models/remittance_model.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class RemittanceHistoryScreen extends StatefulWidget {
  const RemittanceHistoryScreen({super.key});
  @override
  State<RemittanceHistoryScreen> createState() =>
      _RemittanceHistoryScreenState();
}

class _RemittanceHistoryScreenState extends State<RemittanceHistoryScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Get.find<RemittanceController>().loadHistory(refresh: true));
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        Get.find<RemittanceController>().loadHistory();
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
            title: 'remit_history'.tr, isBackButtonExist: true),
        body: GetBuilder<RemittanceController>(builder: (ctrl) {
          // Shimmer while loading first page
          if (ctrl.historyLoading && ctrl.history.isEmpty) {
            return _shimmer(context);
          }
          if (ctrl.history.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flight_takeoff_rounded,
                    size: 64, color: Theme.of(context).hintColor),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('remit_no_history'.tr,
                    style: rubikRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault)),
              ],
            ));
          }
          return RefreshIndicator(
            onRefresh: () => ctrl.loadHistory(refresh: true),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount:
                  ctrl.history.length + (ctrl.hasMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (_, i) {
                if (i == ctrl.history.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return _HistoryCard(
                    item: ctrl.history[i], isAr: isAr);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _shimmer(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
    itemCount: 6,
    separatorBuilder: (_, __) =>
        const SizedBox(height: Dimensions.paddingSizeSmall),
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: Theme.of(context).dividerColor,
      highlightColor: Theme.of(context).cardColor,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              BorderRadius.circular(Dimensions.radiusSizeSmall),
        ),
      ),
    ),
  );
}

// ── Card ──────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final RemittanceHistoryItem item;
  final bool isAr;
  const _HistoryCard({required this.item, required this.isAr});

  Color _statusColor(BuildContext context) {
    switch (item.status) {
      case RemittanceStatus.completed:  return Colors.green.shade600;
      case RemittanceStatus.failed:
      case RemittanceStatus.cancelled:  return Colors.red.shade600;
      case RemittanceStatus.processing: return Colors.blue.shade600;
      case RemittanceStatus.refunded:   return Colors.purple.shade600;
      default:                          return Colors.orange.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color    = _statusColor(context);
    final corridor = RemitCorridor.byCode(item.destinationCountry);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              if (corridor != null)
                Text(corridor.flag,
                    style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: isAr
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(item.recipientName,
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  Text(
                    '${item.destinationCountry}  ·  '
                    '${item.payoutMethod.replaceAll('_', ' ')}',
                    style: rubikLight.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ]),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(
                    Dimensions.radiusSizeExtraSmall),
              ),
              child: Text(item.status.i18nKey.tr,
                  style: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: color)),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        const Divider(height: 1),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(RemitFormatter.sdg(item.sendAmount, isAr: isAr),
                    style: rubikSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge)),
                Text(
                  '→  ${item.receiveAmount.toStringAsFixed(2)} ${item.toCurrency}',
                  style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.green.shade600),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(_fmtDate(item.createdAt, isAr),
                    style: rubikLight.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor)),
                Text(item.reference,
                    style: rubikLight.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor)),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  String _fmtDate(DateTime dt, bool isAr) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return isAr ? '${dt.year}/$m/$d' : '$d/$m/${dt.year}';
  }
}
