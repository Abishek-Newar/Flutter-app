import 'package:get/get_connect/http/src/response/response.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class NotificationRepo{
  final ApiClient apiClient;

  NotificationRepo({required this.apiClient});

  Future<Response> getNotificationList(int offset) async {
    return await apiClient.getData('${AppConstants.notificationUri}?limit=10&offset=$offset');
  }
}