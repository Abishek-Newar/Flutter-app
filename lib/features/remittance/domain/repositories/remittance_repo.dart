// remittance_repo.dart
// Adapts blueprint RemittanceService (getQuote / precheck / sendMoney)
// to the project's ApiClient GetxService pattern.

import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class RemittanceRepo extends GetxService {
  final ApiClient apiClient;
  RemittanceRepo({required this.apiClient});

  // Blueprint: getQuote()
  Future<Response> getQuote(Map<String, dynamic> body) =>
      apiClient.postData(AppConstants.remittanceQuoteUri, body);

  // Blueprint: sendMoney() step 1 — fraud pre-check
  Future<Response> precheck(Map<String, dynamic> body) =>
      apiClient.postData(AppConstants.remittancePrecheckUri, body);

  // Blueprint: sendMoney() step 2 — submit transfer
  Future<Response> send(Map<String, dynamic> body) =>
      apiClient.postData(AppConstants.remittanceSendUri, body);

  // Transfer history (paginated)
  Future<Response> getHistory({int page = 1}) =>
      apiClient.getData('${AppConstants.remittanceHistoryUri}?page=$page');

  // Single transfer detail
  Future<Response> getDetail(String id) =>
      apiClient.getData('${AppConstants.remittanceHistoryUri}/$id');
}
