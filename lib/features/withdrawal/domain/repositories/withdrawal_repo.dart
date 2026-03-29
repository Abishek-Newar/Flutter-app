import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class WithdrawalRepo extends GetxService {
  final ApiClient apiClient;
  WithdrawalRepo({required this.apiClient});

  /// GET /api/v1/withdrawal/methods
  Future<Response> getMethods() =>
      apiClient.getData(AppConstants.withdrawalMethodsUri);

  /// GET /api/v1/withdrawal/limits
  Future<Response> getLimits() =>
      apiClient.getData(AppConstants.withdrawalLimitsUri);

  /// POST /api/v1/withdrawal/request
  Future<Response> submitRequest(Map<String, dynamic> body) =>
      apiClient.postData(AppConstants.withdrawalRequestUri, body);

  /// GET /api/v1/withdrawal/history?page=N
  Future<Response> getHistory({int page = 1}) =>
      apiClient.getData('${AppConstants.withdrawalHistoryUri}?page=$page');

  /// GET /api/v1/withdrawal/history/{id}
  Future<Response> getDetail(String id) =>
      apiClient.getData('${AppConstants.withdrawalHistoryUri}/$id');
}
