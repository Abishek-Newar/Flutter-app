import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/offline_transaction_service.dart';

/// CircleCash — Transaction List Widget
/// Bilingual (Arabic/English), SDG currency, color-coded status badges.
class TransactionListWidget extends StatelessWidget {
  final List<OfflineTransaction> transactions;
  final OfflineWalletLocalizations localizations;
  final String emptyMessage;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.localizations,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _TransactionCard(tx: transactions[i], l: localizations),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final OfflineTransaction tx;
  final OfflineWalletLocalizations l;

  const _TransactionCard({required this.tx, required this.l});

  Color get _statusColor {
    switch (tx.status) {
      case TransactionStatus.confirmed: return const Color(0xFF388E3C);
      case TransactionStatus.pending:   return Colors.orange;
      case TransactionStatus.rejected:  return Colors.red;
      case TransactionStatus.disputed:  return Colors.deepOrange;
      case TransactionStatus.relayed:   return Colors.blue;
    }
  }

  IconData get _statusIcon {
    switch (tx.status) {
      case TransactionStatus.confirmed: return Icons.check_circle;
      case TransactionStatus.pending:   return Icons.hourglass_empty;
      case TransactionStatus.rejected:  return Icons.cancel;
      case TransactionStatus.disputed:  return Icons.gavel;
      case TransactionStatus.relayed:   return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOut = tx.isOutgoing;
    final amountColor = isOut ? Colors.red.shade700 : const Color(0xFF388E3C);
    final amountSign = isOut ? '- ' : '+ ';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),

            const SizedBox(width: 12),

            // ── Details ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOut ? l.sent : l.received,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '$amountSign${l.formatCurrency(tx.amount)}',
                        style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _shortWalletId(
                            isOut ? tx.receiverWalletId : tx.senderWalletId),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      Text(
                        l.timeAgo(tx.timestamp),
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _StatusChip(
                      label: l.statusLabel(tx.status.name.toUpperCase()),
                      color: _statusColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortWalletId(String? id) {
    if (id == null) return '—';
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
