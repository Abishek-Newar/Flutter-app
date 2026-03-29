import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/offline_transaction_service.dart';

/// CircleCash — Send Payment Screen
/// Bilingual (Arabic/English), SDG currency, multi-modal transmission.
class SendPaymentScreen extends StatefulWidget {
  final OfflineTransactionService txService;
  final String? prefillRecipientId;

  const SendPaymentScreen({
    super.key,
    required this.txService,
    this.prefillRecipientId,
  });

  @override
  State<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends State<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _pinController = TextEditingController();

  TransmissionMethod _selectedMethod = TransmissionMethod.online;
  bool _isLoading = false;
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillRecipientId != null) {
      _recipientController.text = widget.prefillRecipientId!;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = OfflineWalletLocalizations.of(context);
    final isRTL = l.isArabic;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(l.sendPayment),
          centerTitle: true,
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Balance Available ──────────────────────────
                      StreamBuilder<WalletBalance>(
                        stream: widget.txService.balanceStream,
                        builder: (ctx, snap) {
                          final spendable = snap.data?.spendable ?? 0;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet,
                                    color: Color(0xFF1976D2), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  '${l.spendableBalance}: ${l.formatCurrency(spendable)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Recipient ──────────────────────────────────
                      _SectionLabel(label: l.recipientWalletId),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _recipientController,
                        decoration: InputDecoration(
                          hintText: isRTL
                              ? 'معرف محفظة المستلم'
                              : 'e.g. CC-1234567890ABCDEF',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.person_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            onPressed: _scanQRForRecipient,
                            tooltip: l.scanQR,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l.requiredField;
                          if (v.trim() == widget.txService.currentWalletId) {
                            return l.selfTransferError;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Amount ─────────────────────────────────────
                      _SectionLabel(label: '${l.amount} (${l.currencyCode})'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          hintText: l.amountHint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.attach_money, size: 20),
                          suffixText: l.currencyCode,
                          suffixStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l.requiredField;
                          final amount = double.tryParse(v);
                          if (amount == null || amount <= 0) {
                            return l.invalidAmount;
                          }
                          if (amount < 1) return l.minimumAmount(1);
                          if (amount > 5000) return l.maximumAmount(5000);
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Note (optional) ────────────────────────────
                      _SectionLabel(label: l.note),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          hintText: isRTL ? 'ملاحظة اختيارية' : 'Optional note',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.note_alt_outlined, size: 20),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Transmission Method ────────────────────────
                      _SectionLabel(label: l.transmissionMethod),
                      const SizedBox(height: 8),
                      _TransmissionSelector(
                        selected: _selectedMethod,
                        localizations: l,
                        onChanged: (m) => setState(() => _selectedMethod = m),
                      ),

                      const SizedBox(height: 24),

                      // ── PIN ────────────────────────────────────────
                      _SectionLabel(label: l.pin),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pinController,
                        obscureText: !_pinVisible,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: l.enterPin,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          counterText: '',
                          suffixIcon: IconButton(
                            icon: Icon(_pinVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _pinVisible = !_pinVisible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l.requiredField;
                          if (v.length < 4) {
                            return isRTL ? 'رمز PIN قصير جداً' : 'PIN too short';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Send Button ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l.sendPayment,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final l = OfflineWalletLocalizations.of(context);

    try {
      final result = await widget.txService.createPayment(
        recipientWalletId: _recipientController.text.trim(),
        amount: double.parse(_amountController.text),
        pin: _pinController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        useBluetooth: _selectedMethod == TransmissionMethod.bluetooth,
        useNFC: _selectedMethod == TransmissionMethod.nfc,
      );

      if (mounted) {
        _showResultDialog(result, l);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultDialog(TransactionResult result, OfflineWalletLocalizations l) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(result.success ? l.success : l.error),
            ],
          ),
          content: Text(result.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                if (result.success) Navigator.pop(context); // screen
              },
              child: Text(l.done),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQRForRecipient() {
    // Navigate to QR scanner and populate recipient
  }
}

// ── Transmission Method Selector ──────────────────────────────────────────────

class _TransmissionSelector extends StatelessWidget {
  final TransmissionMethod selected;
  final OfflineWalletLocalizations localizations;
  final ValueChanged<TransmissionMethod> onChanged;

  const _TransmissionSelector({
    required this.selected,
    required this.localizations,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = localizations;
    final methods = [
      (TransmissionMethod.online, l.sendOnline, Icons.wifi, const Color(0xFF1976D2)),
      (TransmissionMethod.bluetooth, l.sendBluetooth, Icons.bluetooth, Colors.blue.shade700),
      (TransmissionMethod.nfc, l.sendNFC, Icons.nfc, Colors.purple),
      (TransmissionMethod.sms, l.sendSMS, Icons.sms, Colors.green.shade700),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((m) {
        final isSelected = selected == m.$1;
        return GestureDetector(
          onTap: () => onChanged(m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? m.$4.withValues(alpha: 0.12) : Colors.white,
              border: Border.all(
                color: isSelected ? m.$4 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(m.$3,
                    color: isSelected ? m.$4 : Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(
                  m.$2,
                  style: TextStyle(
                    color: isSelected ? m.$4 : Colors.grey.shade700,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}
