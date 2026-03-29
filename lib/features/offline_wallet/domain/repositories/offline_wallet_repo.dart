// lib/features/offline_wallet/domain/repositories/offline_wallet_repo.dart

import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class OfflineWalletRepo extends GetxService {
  final ApiClient apiClient;
  OfflineWalletRepo({required this.apiClient});

  /// GET /api/v1/offline/status
  Future<Response> getStatus() =>
      apiClient.getData(AppConstants.offlineStatusUri);

  /// POST /api/v1/offline/sync
  /// body: { transactions: [ {...}, ... ] }
  Future<Response> syncTransactions(List<Map<String, dynamic>> transactions) =>
      apiClient.postData(
        AppConstants.offlineSyncUri,
        {'transactions': transactions},
      );

  /// POST /api/v1/offline/validate
  /// body: { signed_payload: "..." }
  Future<Response> validatePayment(String signedPayload) =>
      apiClient.postData(
        AppConstants.offlineValidateUri,
        {'signed_payload': signedPayload},
      );
}
