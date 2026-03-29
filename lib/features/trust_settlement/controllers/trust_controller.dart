import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import '../domain/models/trust_model.dart';
import '../domain/repositories/trust_repo.dart';

/// TrustSettlementController
///
/// Manages the Trust & Settlement dashboard state.
/// Register in get_di.dart:
///   Get.lazyPut(() => TrustSettlementController(trustRepo: Get.find()));
class TrustSettlementController extends GetxController implements GetxService {
  final TrustSettlementRepo trustRepo;
  TrustSettlementController({required this.trustRepo});

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading       = false;
  bool _isRebalancing   = false;
  bool _ledgerLoading   = false;

  TrustBalanceModel?       _balances;
  List<TrustTransactionModel> _ledgerEntries = [];
  RebalanceResultModel?    _lastRebalance;

  String  _ledgerFilter  = 'all';
  int     _ledgerPage    = 1;
  bool    _hasMorePages  = true;

  String? _errorMessage;
  String? _successMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading     => _isLoading;
  bool get isRebalancing => _isRebalancing;
  bool get ledgerLoading => _ledgerLoading;

  TrustBalanceModel?           get balances      => _balances;
  List<TrustTransactionModel>  get ledgerEntries => _ledgerEntries;
  RebalanceResultModel?        get lastRebalance => _lastRebalance;

  String get ledgerFilter => _ledgerFilter;
  bool   get hasMorePages => _hasMorePages;

  String? get errorMessage   => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showError         => _errorMessage != null;
  bool get showSuccess       => _successMessage != null;

  // ── Init ─────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadBalances(), loadLedger(reset: true)]);
  }

  // ── Balances ─────────────────────────────────────────────────────────────

  Future<void> loadBalances() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await trustRepo.getBalances();
      if (response.statusCode == 200 && response.body != null) {
        _balances = TrustBalanceModel.fromJson(
          response.body['data'] as Map<String, dynamic>,
        );
      } else {
        ApiChecker.checkApi(response);
        _errorMessage = 'trust_error_load'.tr;
      }
    } catch (_) {
      _errorMessage = 'trust_error_load'.tr;
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ── Ledger ────────────────────────────────────────────────────────────────

  Future<void> loadLedger({bool reset = false}) async {
    if (reset) {
      _ledgerPage   = 1;
      _hasMorePages = true;
      _ledgerEntries = [];
    }

    if (!_hasMorePages) return;

    _ledgerLoading = true;
    update();

    try {
      final response = await trustRepo.getLedger(
        page: _ledgerPage,
        type: _ledgerFilter,
      );
      if (response.statusCode == 200 && response.body != null) {
        final data  = response.body['data'] as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>)
            .map((e) => TrustTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (reset) {
          _ledgerEntries = items;
        } else {
          _ledgerEntries.addAll(items);
        }

        _hasMorePages = data['next_page_url'] != null;
        _ledgerPage++;
      }
    } catch (_) {
      // Non-fatal: show what we have
    } finally {
      _ledgerLoading = false;
      update();
    }
  }

  Future<void> loadMoreLedger() => loadLedger(reset: false);

  void setFilter(String filter) {
    _ledgerFilter = filter;
    loadLedger(reset: true);
  }

  // ── Rebalance ─────────────────────────────────────────────────────────────

  Future<void> triggerRebalance() async {
    _isRebalancing = true;
    _errorMessage  = null;
    _successMessage = null;
    update();

    try {
      final response = await trustRepo.triggerRebalance();
      if (response.statusCode == 200 && response.body != null) {
        _lastRebalance = RebalanceResultModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        final msg = Get.locale?.languageCode == 'ar'
            ? _lastRebalance!.messageAr
            : _lastRebalance!.messageEn;
        _successMessage = msg;
        // Refresh balances to reflect new state
        await loadBalances();
        await loadLedger(reset: true);
      } else {
        ApiChecker.checkApi(response);
        _errorMessage = 'trust_error_load'.tr;
      }
    } catch (_) {
      _errorMessage = 'trust_error_load'.tr;
    } finally {
      _isRebalancing = false;
      update();
    }
  }

  // ── Message helpers ───────────────────────────────────────────────────────
  void clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
    update();
  }

  // ── Allocation preview (no API call) ─────────────────────────────────────
  Map<String, double>? previewAllocation(double amount, bool isDeposit) {
    if (amount <= 0) return null;
    return TrustBalanceModel.split(amount, isDeposit: isDeposit);
  }
}
