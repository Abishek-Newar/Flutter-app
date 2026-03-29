import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

/// TrustSettlementRepo
///
/// Follows the same pattern as AddMoneyRepo, ManualTransferRepo, etc.
/// Register in get_di.dart:
///   Get.lazyPut(() => TrustSettlementRepo(apiClient: Get.find()));
class TrustSettlementRepo extends GetxService {
  final ApiClient apiClient;
  TrustSettlementRepo({required this.apiClient});

  /// GET /api/v1/trust/balances
  /// Returns current Trust + Settlement balances and compliance status.
  Future<Response> getBalances() =>
      apiClient.getData(AppConstants.trustBalancesUri);

  /// GET /api/v1/trust/ledger?page={page}&type={type}
  /// Paginated ledger entries. type = 'all' | 'deposit' | 'withdrawal' | 'rebalance'
  Future<Response> getLedger({int page = 1, String type = 'all'}) =>
      apiClient.getData(
        '${AppConstants.trustLedgerUri}?page=$page&type=$type',
      );

  /// POST /api/v1/trust/rebalance
  /// Trigger an immediate rebalance (admin only).
  Future<Response> triggerRebalance() =>
      apiClient.postData(AppConstants.trustRebalanceUri, {});
}
