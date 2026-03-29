import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

/// Referral API repository.
/// Follows the exact same pattern as AuthRepo, AddMoneyRepo, etc.
/// Register in get_di.dart:
///   Get.lazyPut(() => ReferralRepo(apiClient: Get.find()));
class ReferralRepo extends GetxService {
  final ApiClient apiClient;
  ReferralRepo({required this.apiClient});

  /// Validate a referral code — returns code details if valid.
  /// POST /api/v1/referral/validate
  Future<Response> validateCode(String code) async {
    return apiClient.postData(
      AppConstants.referralValidateUri,
      {'code': code.toUpperCase().trim()},
    );
  }

  /// Apply a referral code to the current registration session.
  /// POST /api/v1/referral/apply
  Future<Response> applyCode(String code) async {
    return apiClient.postData(
      AppConstants.referralApplyUri,
      {'code': code.toUpperCase().trim()},
    );
  }

  /// Fetch global referral program statistics.
  /// GET /api/v1/referral/stats
  Future<Response> getStats() async {
    return apiClient.getData(AppConstants.referralStatsUri);
  }
}
