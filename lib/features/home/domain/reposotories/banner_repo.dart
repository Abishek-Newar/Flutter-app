import 'package:get/get_connect/http/src/response/response.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class BannerRepo{
  final ApiClient apiClient;

  BannerRepo({required this.apiClient});

  Future<Response> getBannerList() async {
    return await apiClient.getData(AppConstants.customerBanner);
  }
}