import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:naqde_user/features/favorite_number/controllers/fav_number_controller.dart';
import 'package:naqde_user/features/favorite_number/domain/repositories/fav_number_repo.dart';
import 'package:naqde_user/features/forget_pin/domain/reposotories/forget_pin_repo.dart';
import 'package:naqde_user/features/history/controllers/report_dispute_controller.dart';
import 'package:naqde_user/features/history/domain/reposotories/report_dispute_repo.dart';
import 'package:naqde_user/features/home/controllers/banner_controller.dart';
import 'package:naqde_user/features/auth/controllers/create_account_controller.dart';
import 'package:naqde_user/features/onboarding/controllers/on_boarding_controller.dart';
import 'package:naqde_user/features/setting/controllers/edit_profile_controller.dart';
import 'package:naqde_user/features/setting/controllers/faq_controller.dart';
import 'package:naqde_user/features/forget_pin/controllers/forget_pin_controller.dart';
import 'package:naqde_user/features/transaction_money/controllers/bootom_slider_controller.dart';
import 'package:naqde_user/features/add_money/controllers/add_money_controller.dart';
import 'package:naqde_user/features/kyc_verification/controllers/kyc_verify_controller.dart';
import 'package:naqde_user/features/home/controllers/menu_controller.dart';
import 'package:naqde_user/features/notification/controllers/notification_controller.dart';
import 'package:naqde_user/features/camera_verification/controllers/qr_code_scanner_controller.dart';
import 'package:naqde_user/common/controllers/share_controller.dart';
import 'package:naqde_user/features/requested_money/controllers/requested_money_controller.dart';
import 'package:naqde_user/features/camera_verification/controllers/camera_screen_controller.dart';
import 'package:naqde_user/features/home/controllers/home_controller.dart';
import 'package:naqde_user/features/language/controllers/language_controller.dart';
import 'package:naqde_user/features/language/controllers/localization_controller.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/features/auth/controllers/auth_controller.dart';
import 'package:naqde_user/features/transaction_money/controllers/contact_controller.dart';
import 'package:naqde_user/features/transaction_money/controllers/transaction_controller.dart';
import 'package:naqde_user/features/splash/controllers/splash_controller.dart';
import 'package:naqde_user/features/setting/controllers/theme_controller.dart';
import 'package:naqde_user/features/history/controllers/transaction_history_controller.dart';
import 'package:naqde_user/features/transaction_money/domain/reposotories/contact_repo.dart';
import 'package:naqde_user/features/verification/controllers/verification_controller.dart';
import 'package:naqde_user/features/home/controllers/websitelink_controller.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/features/add_money/domain/reposotories/add_money_repo.dart';
import 'package:naqde_user/features/auth/domain/reposotories/auth_repo.dart';
import 'package:naqde_user/features/home/domain/reposotories/banner_repo.dart';
import 'package:naqde_user/features/setting/domain/reposotories/faq_repo.dart';
import 'package:naqde_user/features/notification/domain/reposotories/notification_repo.dart';
import 'package:naqde_user/features/setting/domain/reposotories/profile_repo.dart';
import 'package:naqde_user/features/transaction_money/domain/reposotories/transaction_repo.dart';
import 'package:naqde_user/features/history/domain/reposotories/transaction_history_repo.dart';
import 'package:naqde_user/features/home/domain/reposotories/websitelink_repo.dart';
import 'package:naqde_user/features/splash/domain/reposotories/splash_repo.dart';
import 'package:naqde_user/features/requested_money/domain/reposotories/requested_money_repo.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/common/models/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:unique_identifier/unique_identifier.dart';
import '../features/kyc_verification/domain/reposotories/kyc_verify_repo.dart';
import 'package:naqde_user/features/offline_wallet/controllers/offline_wallet_controller.dart';
import 'package:naqde_user/features/offline_wallet/domain/repositories/offline_wallet_repo.dart';

// ── New Feature Imports ───────────────────────────────────────────────────────
import 'package:naqde_user/features/otp_verification/controllers/otp_verification_controller.dart';
import 'package:naqde_user/features/referral/domain/repositories/referral_repo.dart';
import 'package:naqde_user/features/referral/controllers/referral_controller.dart';
import 'package:naqde_user/features/trust_settlement/domain/repositories/trust_repo.dart';
import 'package:naqde_user/features/trust_settlement/controllers/trust_controller.dart';
import 'package:naqde_user/features/withdrawal/domain/repositories/withdrawal_repo.dart';
import 'package:naqde_user/features/withdrawal/controllers/withdrawal_controller.dart';
import 'package:naqde_user/features/remittance/domain/repositories/remittance_repo.dart';
import 'package:naqde_user/features/remittance/controllers/remittance_controller.dart';


Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  final BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;
  String? uniqueId = await UniqueIdentifier.serial ?? '';

  Get.lazyPut(() => uniqueId);
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => deviceInfo);

  Get.lazyPut(() => ApiClient(
    appBaseUrl: AppConstants.baseUrl,
    sharedPreferences: Get.find(),
    uniqueId: Get.find(),
    deiceInfo: Get.find(),
  ));

  // ── Repositories ────────────────────────────────────────────────────────────
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => TransactionRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ProfileRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => WebsiteLinkRepo(apiClient: Get.find()));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find()));
  Get.lazyPut(() => AddMoneyRepo(apiClient: Get.find()));
  Get.lazyPut(() => FaqRepo(apiClient: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find()));
  Get.lazyPut(() => RequestedMoneyRepo(apiClient: Get.find()));
  Get.lazyPut(() => TransactionHistoryRepo(apiClient: Get.find()));
  Get.lazyPut(() => KycVerifyRepo(apiClient: Get.find()));
  Get.lazyPut(() => ForgetPinRepo(apiClient: Get.find()));
  Get.lazyPut(() => ContactRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => FavNumberRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ReportDisputeRepo(apiClient: Get.find()));
  // New feature repos
  Get.lazyPut(() => ReferralRepo(apiClient: Get.find()));
  Get.lazyPut(() => OfflineWalletRepo(apiClient: Get.find()));
  Get.lazyPut(() => TrustSettlementRepo(apiClient: Get.find()));
  Get.lazyPut(() => WithdrawalRepo(apiClient: Get.find()));   // Withdrawal
  Get.lazyPut(() => RemittanceRepo(apiClient: Get.find()));   // Remittance

  // ── Controllers ─────────────────────────────────────────────────────────────
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.put(LocalizationController(sharedPreferences: Get.find()), permanent: true);
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  Get.lazyPut(() => TransactionMoneyController(transactionRepo: Get.find(), authRepo: Get.find()));
  Get.lazyPut(() => AddMoneyController(addMoneyRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => ProfileController(profileRepo: Get.find()));
  Get.lazyPut(() => FaqController(faqrepo: Get.find()));
  Get.lazyPut(() => BottomSliderController());
  Get.lazyPut(() => MenuItemController());
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => CreateAccountController());
  Get.lazyPut(() => VerificationController());
  Get.lazyPut(() => CameraScreenController());
  Get.lazyPut(() => ForgetPinController(forgetPinRepo: Get.find()));
  Get.lazyPut(() => WebsiteLinkController(websiteLinkRepo: Get.find()));
  Get.lazyPut(() => QrCodeScannerController());
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => TransactionHistoryController(transactionHistoryRepo: Get.find()));
  Get.lazyPut(() => EditProfileController(authRepo: Get.find()));
  Get.lazyPut(() => RequestedMoneyController(requestedMoneyRepo: Get.find()));
  Get.lazyPut(() => ShareController());
  Get.lazyPut(() => KycVerifyController(kycVerifyRepo: Get.find()));
  Get.lazyPut(() => OnBoardingController());
  Get.lazyPut(() => ContactController(contactRepo: Get.find()));
  Get.lazyPut(() => FavNumberController(favNumberRepo: Get.find()));
  Get.lazyPut(() => ReportDisputeController(reportDisputeRepo: Get.find()));
  // New feature controllers
  Get.lazyPut(() => OtpVerificationController(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ReferralController(referralRepo: Get.find()));
  Get.lazyPut(() => OfflineWalletController(repo: Get.find()), fenix: true);
  Get.lazyPut(() => TrustSettlementController(trustRepo: Get.find()));
  Get.lazyPut(() => WithdrawalController(withdrawalRepo: Get.find())); // Withdrawal
  Get.lazyPut(() => RemittanceController(repo: Get.find()));            // Remittance

  // ── Localization ─────────────────────────────────────────────────────────────
  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = json;
  }
  return languages;
}
