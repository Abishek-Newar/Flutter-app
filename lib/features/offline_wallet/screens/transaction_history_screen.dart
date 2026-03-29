import '../domain/models/offline_wallet_models.dart';
import 'package:flutter/material.dart';
import '../l10n/offline_wallet_localizations.dart';
import '../services/offline_transaction_service.dart';
import '../widgets/transaction_list_widget.dart';

/// CircleCash — Transaction History Screen
/// Full bilingual Arabic/English with filter tabs.
class TransactionHistoryScreen extends StatefulWidget {
  final OfflineTransactionService txService;

  const TransactionHistoryScreen({super.key, required this.txService});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OfflineTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final all = await widget.txService.getTransactionHistory(limit: 100);
      setState(() => _transactions = all);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<OfflineTransaction> _filtered(TransactionStatus? status) {
    if (status == null) return _transactions;
    return _transactions.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = OfflineWalletLocalizations.of(context);

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(l.transactionHistory),
          centerTitle: true,
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadHistory,
              tooltip: l.retry,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            isScrollable: true,
            tabs: [
              Tab(text: l.isArabic ? 'الكل' : 'All'),
              Tab(text: l.statusLabel('CONFIRMED')),
              Tab(text: l.statusLabel('PENDING')),
              Tab(text: l.statusLabel('DISPUTED')),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHistory,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    TransactionListWidget(
                      transactions: _filtered(null),
                      localizations: l,
                      emptyMessage: l.noTransactions,
                    ),
                    TransactionListWidget(
                      transactions: _filtered(TransactionStatus.confirmed),
                      localizations: l,
                      emptyMessage: l.noTransactions,
                    ),
                    TransactionListWidget(
                      transactions: _filtered(TransactionStatus.pending),
                      localizations: l,
                      emptyMessage: l.noTransactions,
                    ),
                    TransactionListWidget(
                      transactions: _filtered(TransactionStatus.disputed),
                      localizations: l,
                      emptyMessage: l.noTransactions,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
