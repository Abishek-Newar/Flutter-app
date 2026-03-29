import 'package:get/get.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/util/app_constants.dart';

class ReferralRepo extends GetxService {
  final ApiClient apiClient;
  ReferralRepo({required this.apiClient});

  /// GET /api/v1/referral/my-code
  /// Gets or creates the user's own referral code + share link + bonus amounts + stats.
  Future<Response> getMyCode() =>
      apiClient.getData(AppConstants.referralMyCodeUri);

  /// GET /api/v1/referral/stats
  /// Stats only: total_referrals, qualified, rewarded, total_earned_sdg.
  Future<Response> getStats() =>
      apiClient.getData(AppConstants.referralStatsUri);

  /// GET /api/v1/referral/list?page=N
  /// Paginated list of referred users (20/page).
  Future<Response> getReferralList({int page = 1}) =>
      apiClient.getData('${AppConstants.referralListUri}?page=$page');

  /// POST /api/v1/referral/apply
  /// body: { code }
  /// Errors on self-referral, invalid code, or duplicate.
  Future<Response> applyCode(String code) =>
      apiClient.postData(AppConstants.referralApplyUri, {
        'code': code.toUpperCase().trim(),
      });
}
