import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';

/// CircleCash — Offline Balance Card Widget
/// Displays confirmed, pending, and spendable balances in SDG.
/// Full Arabic/English support with RTL layout.
class OfflineBalanceCard extends StatelessWidget {
  final WalletBalance balance;
  final OfflineWalletLocalizations localizations;

  const OfflineBalanceCard({
    super.key,
    required this.balance,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final l = localizations;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: balance.isFrozen
            ? LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (balance.isFrozen ? Colors.grey : const Color(0xFF1976D2))
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -20,
            right: l.isArabic ? null : -20,
            left: l.isArabic ? -20 : null,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: l.isArabic ? null : 40,
            right: l.isArabic ? 40 : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l.isArabic ? 'سيركل كاش' : 'CircleCash',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    if (balance.isFrozen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              l.walletFrozen,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Spendable Balance (main) ────────────────────────────
                Text(
                  l.spendableBalance,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  l.formatCurrency(balance.spendable),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Confirmed + Pending Row ────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _BalanceItem(
                        label: l.confirmedBalance,
                        value: l.formatCurrency(balance.confirmed),
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: _BalanceItem(
                        label: l.pendingBalance,
                        value: l.formatCurrency(balance.pending.abs()),
                        icon: Icons.hourglass_empty,
                        isWarning: balance.pending != 0,
                      ),
                    ),
                  ],
                ),

                if (balance.isFrozen) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.walletFrozenMessage,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                color: isWarning ? Colors.orangeAccent : Colors.white60,
                size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isWarning ? Colors.orangeAccent : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
