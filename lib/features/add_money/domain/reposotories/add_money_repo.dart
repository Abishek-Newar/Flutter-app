import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class AddMoneyRepo {
  final ApiClient apiClient;
  AddMoneyRepo({required this.apiClient});

  /// GET /api/v1/add-money/banks
  /// Returns list of available banks with account details.
  Future<Response> getBanks() =>
      apiClient.getData(AppConstants.addMoneyBanksUri);

  /// POST /api/v1/add-money/initiate
  /// Starts a transfer request. Returns a reference on success.
  Future<Response> initiateTransfer({
    required String bank,
    required double amount,
    required String senderName,
    required String senderAccount,
  }) =>
      apiClient.postData(AppConstants.addMoneyInitiateUri, {
        'bank': bank,
        'amount': amount,
        'sender_name': senderName,
        'sender_account': senderAccount,
      });

  /// POST /api/v1/add-money/upload-receipt
  /// Multipart upload: reference + receipt file (jpg/png/pdf, max 5 MB).
  Future<Response> uploadReceipt({
    required String reference,
    required File receipt,
  }) =>
      apiClient.postMultipartData(
        AppConstants.addMoneyReceiptUri,
        {'reference': reference},
        [MultipartBody('receipt', receipt)],
      );

  /// GET /api/v1/add-money/history?page=N
  Future<Response> getHistory({int page = 1}) =>
      apiClient.getData('${AppConstants.addMoneyHistoryUri}?page=$page');

  /// GET /api/v1/add-money/{reference}
  Future<Response> getTransferStatus(String reference) =>
      apiClient.getData('${AppConstants.addMoneyDetailUri}/$reference');
}
