import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/bluetooth_mesh_service.dart';
import '../services/offline_transaction_service.dart';
import 'send_payment_screen.dart';

enum BluetoothMode { send, receive }

/// CircleCash — Bluetooth Transfer Screen
/// Bilingual (Arabic/English), SDG currency.
class BluetoothTransferScreen extends StatefulWidget {
  final BluetoothMeshService meshService;
  final OfflineTransactionService txService;
  final BluetoothMode mode;

  const BluetoothTransferScreen({
    super.key,
    required this.meshService,
    required this.txService,
    required this.mode,
  });

  @override
  State<BluetoothTransferScreen> createState() =>
      _BluetoothTransferScreenState();
}

class _BluetoothTransferScreenState extends State<BluetoothTransferScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  List<DiscoveredNode> _nodes = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.8, end: 1.0).animate(_pulseController);
    _startScan();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      final nodes = await widget.meshService.scanForNearbyNodes();
      if (mounted) setState(() => _nodes = nodes);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = OfflineWalletLocalizations.of(context);
    final isSend = widget.mode == BluetoothMode.send;

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(isSend ? l.bluetoothSend : l.bluetoothReceive),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: l.retry,
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Radar Animation ─────────────────────────────────────────
            Container(
              color: Colors.blue.shade700,
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border:
                          Border.all(color: Colors.white38, width: 2),
                    ),
                    child: const Icon(Icons.bluetooth_searching,
                        color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Status ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _isScanning
                    ? l.bluetoothScanning
                    : _nodes.isEmpty
                        ? l.noBluetoothNodes
                        : l.nearbyDevices(_nodes.length),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Node List ───────────────────────────────────────────────
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : _nodes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bluetooth_disabled,
                                  size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _startScan,
                                icon: const Icon(Icons.refresh),
                                label: Text(l.retry),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _nodes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) => _NodeCard(
                            node: _nodes[i],
                            mode: widget.mode,
                            localizations: l,
                            onTap: () => _onNodeSelected(_nodes[i], l),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNodeSelected(DiscoveredNode node, OfflineWalletLocalizations l) {
    if (widget.mode == BluetoothMode.send) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SendPaymentScreen(
            txService: widget.txService,
            prefillRecipientId: node.walletId,
          ),
        ),
      );
    } else {
      // Show receiving UI
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.bluetoothReceive),
          content: Text(l.isArabic
              ? 'في انتظار الدفعة من ${node.nodeId}'
              : 'Waiting for payment from ${node.nodeId}...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
          ],
        ),
      );
    }
  }
}

class _NodeCard extends StatelessWidget {
  final DiscoveredNode node;
  final BluetoothMode mode;
  final OfflineWalletLocalizations localizations;
  final VoidCallback onTap;

  const _NodeCard({
    required this.node,
    required this.mode,
    required this.localizations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = localizations;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.phone_android,
                    color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.nodeId,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${l.isArabic ? "قوة الإشارة" : "Signal"}: ${node.rssi} dBm',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                mode == BluetoothMode.send ? Icons.send : Icons.call_received,
                color: mode == BluetoothMode.send
                    ? const Color(0xFF1976D2)
                    : const Color(0xFF388E3C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

