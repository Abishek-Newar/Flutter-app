import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/trust_controller.dart';
import '../domain/models/trust_model.dart';

/// Scrollable ledger table showing recent trust/settlement transactions.
/// Supports infinite-scroll pagination and filter tabs.
class TrustLedgerTable extends StatelessWidget {
  const TrustLedgerTable({super.key});

  static const _filters = ['all', 'deposit', 'withdrawal', 'rebalance'];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrustSettlementController>(
      builder: (ctrl) {
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
              // Title + filter tabs
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFF1A2A6C), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('ledger_title'.tr,
                        style: rubikSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: const Color(0xFF1A2A6C))),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) => _FilterChip(
                    label: _filterLabel(f),
                    isActive: ctrl.ledgerFilter == f,
                    onTap: () => ctrl.setFilter(f),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Table header
              _TableHeader(),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Rows
              if (ctrl.ledgerLoading && ctrl.ledgerEntries.isEmpty)
                _LoadingPlaceholder()
              else if (ctrl.ledgerEntries.isEmpty)
                _EmptyPlaceholder()
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctrl.ledgerEntries.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (_, i) => _LedgerRow(tx: ctrl.ledgerEntries[i]),
                ),
                if (ctrl.hasMorePages) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: ctrl.ledgerLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : TextButton.icon(
                            onPressed: ctrl.loadMoreLedger,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            label: Text('Load more',
                                style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  String _filterLabel(String f) {
    switch (f) {
      case 'deposit':    return 'ledger_type_deposit'.tr;
      case 'withdrawal': return 'ledger_type_withdrawal'.tr;
      case 'rebalance':  return 'ledger_type_rebalance'.tr;
      default:           return 'All';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool   isActive;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A2A6C) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: rubikSemiBold.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cols = [
      'ledger_col_time'.tr,
      'ledger_col_type'.tr,
      'ledger_col_amount'.tr,
      'ledger_col_account'.tr,
      'ledger_col_status'.tr,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: cols.map((c) => Expanded(
          child: Text(c.toUpperCase(),
              style: rubikSemiBold.copyWith(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.4)),
        )).toList(),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final TrustTransactionModel tx;
  const _LedgerRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    final timeStr    = '${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Time
          Expanded(child: Text(timeStr,
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade700))),

          // Type badge
          Expanded(child: _TypeBadge(tx.type)),

          // Amount
          Expanded(
            child: Text(
              (isPositive ? '+' : '') + TrustBalanceModel.formatSdg(tx.amount),
              style: rubikSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              textDirection: TextDirection.ltr,
            ),
          ),

          // Account split
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountBadge(label: 'Trust', amount: tx.trustAmount, color: const Color(0xFF059669), bg: const Color(0xFFD1FAE5)),
                const SizedBox(height: 4),
                _AccountBadge(label: 'Settle', amount: tx.settlementAmount, color: const Color(0xFF7C3AED), bg: const Color(0xFFEDE9FE)),
              ],
            ),
          ),

          // Status
          Expanded(child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 14),
              const SizedBox(width: 4),
              Text('ledger_status_completed'.tr,
                  style: rubikRegular.copyWith(fontSize: 10, color: const Color(0xFF10B981))),
            ],
          )),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final LedgerTxType type;
  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    Color color, bg;
    String label;
    switch (type) {
      case LedgerTxType.withdrawal:
        color = const Color(0xFF991B1B); bg = const Color(0xFFFEE2E2);
        label = 'ledger_type_withdrawal'.tr;
        break;
      case LedgerTxType.rebalance:
        color = const Color(0xFF1E40AF); bg = const Color(0xFFDBEAFE);
        label = 'ledger_type_rebalance'.tr;
        break;
      default:
        color = const Color(0xFF065F46); bg = const Color(0xFFD1FAE5);
        label = 'ledger_type_deposit'.tr;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: rubikSemiBold.copyWith(fontSize: 10, color: color)),
    );
  }
}

class _AccountBadge extends StatelessWidget {
  final String label;
  final double amount;
  final Color  color, bg;
  const _AccountBadge({required this.label, required this.amount, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$label: ${TrustBalanceModel.formatSdg(amount)}',
        style: rubikSemiBold.copyWith(fontSize: 9, color: color),
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('ledger_empty'.tr,
                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: List.generate(5, (i) => Expanded(
            child: Container(
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
