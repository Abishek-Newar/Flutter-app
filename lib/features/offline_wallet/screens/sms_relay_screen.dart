import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/offline_transaction_service.dart';

/// CircleCash — SMS Relay Screen
/// For sending offline transactions via SMS when no internet/Bluetooth.
/// Bilingual (Arabic/English), SDG currency.
class SMSRelayScreen extends StatefulWidget {
  final OfflineTransactionService txService;

  const SMSRelayScreen({super.key, required this.txService});

  @override
  State<SMSRelayScreen> createState() => _SMSRelayScreenState();
}

class _SMSRelayScreenState extends State<SMSRelayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isLoading = false;
  int _chunksTotal = 0;
  int _chunksSent = 0;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = OfflineWalletLocalizations.of(context);

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(l.smsRelay),
          centerTitle: true,
          backgroundColor: Colors.green.shade700,
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
                      // ── Info Banner ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l.isArabic
                                    ? 'سيتم إرسال المعاملة عبر رسائل SMS مشفرة إلى المستلم. يتطلب ذلك خدمة SMS نشطة فقط.'
                                    : 'The transaction will be sent as encrypted SMS to the recipient. Only requires an active SMS service.',
                                style: TextStyle(
                                    color: Colors.green.shade800, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Recipient Wallet ───────────────────────────
                      _Label(l.recipientWalletId),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _recipientController,
                        decoration: InputDecoration(
                          hintText: l.isArabic
                              ? 'معرف محفظة المستلم'
                              : 'Recipient wallet ID',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l.requiredField : null,
                      ),

                      const SizedBox(height: 16),

                      // ── Phone Number ───────────────────────────────
                      _Label(l.recipientPhone),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                        ],
                        decoration: InputDecoration(
                          hintText: l.isArabic
                              ? '+249xxxxxxxxx'
                              : '+249xxxxxxxxx (Sudan)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l.requiredField;
                          if (v.length < 10) {
                            return l.isArabic
                                ? 'رقم الهاتف غير صالح'
                                : 'Invalid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Amount ─────────────────────────────────────
                      _Label('${l.amount} (${l.currencyCode})'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        decoration: InputDecoration(
                          hintText: l.amountHint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: l.currencyCode,
                          suffixStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l.requiredField;
                          final a = double.tryParse(v);
                          if (a == null || a <= 0) return l.invalidAmount;
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── PIN ────────────────────────────────────────
                      _Label(l.pin),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: l.enterPin,
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l.requiredField : null,
                      ),

                      const SizedBox(height: 20),

                      // ── Chunk Progress ─────────────────────────────
                      if (_isLoading && _chunksTotal > 0) ...[
                        LinearProgressIndicator(
                          value: _chunksSent / _chunksTotal,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.smsChunkProgress(_chunksSent, _chunksTotal),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Send Button ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: const Icon(Icons.sms),
                    label: Text(
                      _isLoading ? l.smsSending : l.smsRelay,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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

    setState(() {
      _isLoading = true;
      _chunksTotal = 0;
      _chunksSent = 0;
    });

    final l = OfflineWalletLocalizations.of(context);

    try {
      final result = await widget.txService.createPayment(
        recipientWalletId: _recipientController.text.trim(),
        amount: double.parse(_amountController.text),
        pin: _pinController.text,
        useSMS: true,
        smsRecipientPhone: _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? l.smsDelivered : result.message),
            backgroundColor:
                result.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (result.success) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      );
}
