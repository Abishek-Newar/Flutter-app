import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class OfflineWalletRepo extends GetxService {
  final ApiClient apiClient;
  OfflineWalletRepo({required this.apiClient});

  /// POST /api/v1/offline-wallet/generate-token
  /// body: { amount, channel (nfc/qr/bluetooth), device_id }
  /// Returns a pre-auth token valid for 24 h.
  Future<Response> generateToken({
    required double amount,
    required String channel,
    required String deviceId,
  }) =>
      apiClient.postData(AppConstants.offlineGenerateTokenUri, {
        'amount': amount,
        'channel': channel,
        'device_id': deviceId,
      });

  /// POST /api/v1/offline-wallet/sync
  /// body: { transactions: [ { token, recipient_identifier, amount, channel,
  ///                           signed_payload, offline_created_at }, ... ] }
  /// Batch-syncs 1–50 offline transactions.
  Future<Response> syncTransactions(List<Map<String, dynamic>> transactions) =>
      apiClient.postData(
        AppConstants.offlineWalletSyncUri,
        {'transactions': transactions},
      );

  /// GET /api/v1/offline-wallet/pending-sync
  /// Returns items that have been queued but not yet settled.
  Future<Response> getPendingSync() =>
      apiClient.getData(AppConstants.offlinePendingSyncUri);

  /// GET /api/v1/offline-wallet/tokens
  /// Returns all active (unspent, unexpired) tokens for this user.
  Future<Response> getActiveTokens() =>
      apiClient.getData(AppConstants.offlineTokensUri);
}
