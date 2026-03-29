import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:naqde_user/features/withdrawal/controllers/withdrawal_controller.dart';
import 'package:naqde_user/features/withdrawal/domain/models/withdrawal_model.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});
  @override
  State<WithdrawalHistoryScreen> createState() => _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<WithdrawalController>().loadHistory(refresh: true);
    });
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      Get.find<WithdrawalController>().loadHistory();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'withdrawal_history'.tr, isBackButtonExist: true),
        body: GetBuilder<WithdrawalController>(builder: (ctrl) {
          if (ctrl.isLoading && ctrl.history.isEmpty) {
            return _shimmer(context);
          }
          if (ctrl.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Theme.of(context).hintColor),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text('no_withdrawal_history'.tr,
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ctrl.loadHistory(refresh: true),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: ctrl.history.length + (ctrl.hasMoreHistory ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (ctx, i) {
                if (i == ctrl.history.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return _HistoryCard(item: ctrl.history[i], isAr: isAr);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _shimmer(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: 6,
      separatorBuilder: (_, _) =>
          const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Theme.of(context).dividerColor,
        highlightColor: Theme.of(context).cardColor,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WithdrawalHistoryItem item;
  final bool isAr;
  const _HistoryCard({required this.item, required this.isAr});

  Color _statusColor(BuildContext ctx) {
    switch (item.status) {
      case WithdrawalStatus.completed: return Colors.green.shade600;
      case WithdrawalStatus.rejected:
      case WithdrawalStatus.cancelled: return Colors.red.shade600;
      case WithdrawalStatus.approved:
      case WithdrawalStatus.processing: return Colors.blue.shade600;
      default:                          return Colors.orange.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Amount + method
              Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(SdgFormatter.format(item.amount, isArabic: isAr),
                      style: rubikSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeSemiLarge)),
                  const SizedBox(height: 2),
                  Text(item.localizedMethodName(isAr),
                      style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).hintColor)),
                ],
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
                ),
                child: Text(item.status.labelKey.tr,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: color)),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          const Divider(height: 1),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reference + date
              Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text('${isAr ? 'المرجع' : 'Ref'}: ${item.referenceNumber}',
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                  Text(_formatDate(item.createdAt, isAr),
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                ],
              ),
              // Net amount
              Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(isAr ? 'صافي الاستلام' : 'Net received',
                      style: rubikLight.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                  Text(SdgFormatter.format(item.netAmount, isArabic: isAr),
                      style: rubikMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ],
          ),
          // Rejection reason
          if (item.status == WithdrawalStatus.rejected &&
              item.rejectionReason != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusSizeExtraSmall),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 14, color: Colors.red.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.localizedRejectionReason(isAr) ?? '',
                    style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.red.shade700),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt, bool isAr) {
    final day   = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year  = dt.year;
    final hour  = dt.hour.toString().padLeft(2, '0');
    final min   = dt.minute.toString().padLeft(2, '0');
    return isAr
        ? '$year/$month/$day، $hour:$min'
        : '$day/$month/$year  $hour:$min';
  }
}
