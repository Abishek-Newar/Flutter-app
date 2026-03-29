import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/nfc_service.dart';
import '../services/offline_transaction_service.dart';

enum NFCMode { read, write }

/// CircleCash — NFC Transfer Screen
/// Bilingual (Arabic/English). Animated tap indicator.
class NFCTransferScreen extends StatefulWidget {
  final NFCService nfcService;
  final OfflineTransactionService txService;
  final NFCMode mode;
  final SignedTransaction? transactionToWrite;

  const NFCTransferScreen({
    super.key,
    required this.nfcService,
    required this.txService,
    required this.mode,
    this.transactionToWrite,
  });

  @override
  State<NFCTransferScreen> createState() => _NFCTransferScreenState();
}

class _NFCTransferScreenState extends State<NFCTransferScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  NFCEventType? _lastEvent;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initNFC();
  }

  @override
  void dispose() {
    _animController.dispose();
    widget.nfcService.stopSession();
    super.dispose();
  }

  Future<void> _initNFC() async {
    final l = OfflineWalletLocalizations.of(context);
    try {
      widget.nfcService.nfcEvents.listen((event) {
        if (!mounted) return;
        setState(() {
          _lastEvent = event.type;
          switch (event.type) {
            case NFCEventType.writeSuccess:
              _statusMessage = l.nfcWriteSuccess;
              break;
            case NFCEventType.transactionReceived:
              _statusMessage = l.nfcTransactionReceived;
              break;
            case NFCEventType.error:
              _statusMessage = event.data?['message'] as String? ?? l.error;
              break;
            default:
              break;
          }
        });

        if (event.type == NFCEventType.writeSuccess ||
            event.type == NFCEventType.transactionReceived) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      });

      if (widget.mode == NFCMode.write && widget.transactionToWrite != null) {
        await widget.nfcService.writeTransaction(widget.transactionToWrite!);
      } else {
        await widget.nfcService.startReading();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = OfflineWalletLocalizations.of(context);
    final isWrite = widget.mode == NFCMode.write;

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF7B1FA2),
        appBar: AppBar(
          title: Text(isWrite ? l.nfcTapToPay : l.nfcReceive),
          centerTitle: true,
          backgroundColor: const Color(0xFF7B1FA2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ── Animated NFC Icon ──────────────────────────────────────
            AnimatedBuilder(
              animation: _animController,
              builder: (_, child) => Transform.scale(
                scale: _scaleAnim.value,
                child: Opacity(opacity: _opacityAnim.value, child: child),
              ),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white38, width: 3),
                ),
                child: const Icon(Icons.nfc, color: Colors.white, size: 80),
              ),
            ),

            const SizedBox(height: 32),

            // ── Instructions ───────────────────────────────────────────
            Text(
              l.holdNearDevice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l.isArabic
                    ? (isWrite
                        ? 'ضع هاتفك بجانب هاتف المستلم لإتمام الدفعة'
                        : 'ضع هاتفك بجانب هاتف المُرسل لاستقبال الدفعة')
                    : (isWrite
                        ? 'Place your phone near the recipient\'s device to complete the payment'
                        : 'Place your phone near the sender\'s device to receive the payment'),
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // ── Status ─────────────────────────────────────────────────
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lastEvent == NFCEventType.error
                      ? Colors.red.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lastEvent == NFCEventType.error
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastEvent == NFCEventType.error
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // ── Cancel ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l.cancel,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
