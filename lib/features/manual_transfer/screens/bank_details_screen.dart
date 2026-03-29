import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/add_funds_localizations.dart';
import '../models/bank_account.dart';
import '../services/manual_transfer_api.dart';
import 'submit_transfer_screen.dart';

class BankDetailsScreen extends StatelessWidget {
  final BankAccount bank;
  final ManualTransferApi api;
  final Locale locale;
  final VoidCallback? onToggleLanguage;

  const BankDetailsScreen({
    super.key,
    required this.bank,
    required this.api,
    this.locale = const Locale('en'),
    this.onToggleLanguage,
  });

  AddFundsL10n get l => AddFundsL10n(locale);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: l.textDirection,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(
            bank.bankName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: onToggleLanguage,
              child: Text(
                l.toggleLanguage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank info card
                    _buildBankInfoCard(context),
                    const SizedBox(height: 20),

                    // Steps card
                    _buildStepsCard(),
                  ],
                ),
              ),
            ),
            // Sticky bottom button
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with bank icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance,
                      color: Color(0xFF1976D2), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bank.bankName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Detail rows
            _buildDetailRow(context, l.bankName, bank.bankName,
                icon: Icons.account_balance_outlined),
            _buildDetailRow(context, l.accountName, bank.accountName,
                icon: Icons.person_outline, copyable: true),
            _buildDetailRow(context, l.accountNumber, bank.accountNumber,
                icon: Icons.numbers, copyable: true),
            if (bank.iban != null)
              _buildDetailRow(context, l.ibanLabel, bank.iban!,
                  icon: Icons.credit_card, copyable: true),

            const Divider(height: 24),

            // Important instructions
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(
                  l.importantInstructions,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                bank.instructions ??
                    (l.isArabic
                        ? 'أضف معرّف محفظتك في وصف التحويل'
                        : 'Include your Wallet ID in the transfer description'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 0),
              child: Icon(icon, size: 18, color: Colors.grey.shade500),
            ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (copyable)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.copied),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF388E3C),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.steps,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(1, l.step1),
            _buildStep(2, l.step2),
            _buildStep(3, l.step3),
            _buildStep(4, l.step4),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1976D2),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubmitTransferScreen(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l.iHaveTransferred,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
