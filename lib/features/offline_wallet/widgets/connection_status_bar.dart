import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';

/// CircleCash — Connection Status Bar
/// Shows live status of Internet, Bluetooth, NFC, and Mesh in Arabic/English.
class ConnectionStatusBar extends StatelessWidget {
  final OfflineWalletLocalizations localizations;

  const ConnectionStatusBar({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final l = localizations;

    // In production, stream from connectivity services.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatusDot(label: l.internet, active: true, icon: Icons.wifi),
          _Divider(),
          _StatusDot(label: l.bluetooth, active: true, icon: Icons.bluetooth),
          _Divider(),
          _StatusDot(label: l.nfc, active: true, icon: Icons.nfc),
          _Divider(),
          _StatusDot(label: l.mesh, active: false, icon: Icons.hub_outlined),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;

  const _StatusDot(
      {required this.label, required this.active, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF388E3C) : Colors.grey.shade400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 24, color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}
