// ─────────────────────────────────────────────────────────────────────────────
// Add these constants to lib/util/app_constants.dart
// inside the AppConstants class body
// ─────────────────────────────────────────────────────────────────────────────
//
// // Withdrawal System
// static const String withdrawalMethodsUri = '/api/v1/withdrawal/methods';
// static const String withdrawalLimitsUri  = '/api/v1/withdrawal/limits';
// static const String withdrawalRequestUri = '/api/v1/withdrawal/request';
// static const String withdrawalHistoryUri = '/api/v1/withdrawal/history';
//
// ─────────────────────────────────────────────────────────────────────────────
// Add these routes to lib/helper/route_helper.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// static const String withdrawalAmount  = '/withdrawal-amount';
// static const String withdrawalDetails = '/withdrawal-details';
// static const String withdrawalSuccess = '/withdrawal-success';
// static const String withdrawalHistory = '/withdrawal-history';
//
// static String getWithdrawalAmountRoute()  => withdrawalAmount;
// static String getWithdrawalDetailsRoute() => withdrawalDetails;
// static String getWithdrawalSuccessRoute() => withdrawalSuccess;
// static String getWithdrawalHistoryRoute() => withdrawalHistory;
//
// // In getPages() list:
// GetPage(name: withdrawalAmount,  page: () => const WithdrawalAmountScreen(),  transition: Transition.rightToLeft),
// GetPage(name: withdrawalDetails, page: () => const WithdrawalDetailsScreen(), transition: Transition.rightToLeft),
// GetPage(name: withdrawalSuccess, page: () => const WithdrawalSuccessScreen(), transition: Transition.fadeIn),
// GetPage(name: withdrawalHistory, page: () => const WithdrawalHistoryScreen(), transition: Transition.rightToLeft),
//
// ─────────────────────────────────────────────────────────────────────────────
// Add to lib/helper/get_di.dart (dependency injection)
// ─────────────────────────────────────────────────────────────────────────────
//
// // Withdrawal
// Get.lazyPut(() => WithdrawalRepo(apiClient: Get.find()));
// Get.lazyPut(() => WithdrawalController(withdrawalRepo: Get.find()));
//
// ─────────────────────────────────────────────────────────────────────────────
// Navigation entry points (from home screen or settings)
// ─────────────────────────────────────────────────────────────────────────────
//
// Get.toNamed(RouteHelper.getWithdrawalAmountRoute());   // Start withdrawal flow
// Get.toNamed(RouteHelper.getWithdrawalHistoryRoute());  // View withdrawal history
