import 'package:naqde_user/common/models/language_model.dart';
import 'images.dart';

class AppConstants {
  static const String appName = 'نقْدي';
  static const String baseUrl = 'https://circlecash.net';
  static const bool demo = false;
  static const double appVersion = 4.8;

  // ── Core Auth ─────────────────────────────────────────────────────────────
  static const String customerPhoneCheckUri        = '/api/v1/customer/auth/check-phone';
  static const String customerPhoneVerifyUri       = '/api/v1/customer/auth/verify-phone';
  static const String customerRegistrationUri      = '/api/v1/customer/auth/register';
  static const String customerUpdateProfile        = '/api/v1/customer/update-profile';
  static const String customerLoginUri             = '/api/v1/customer/auth/login';
  static const String customerLogoutUri            = '/api/v1/customer/logout';
  static const String customerForgetPassOtpUri     = '/api/v1/customer/auth/forgot-password';
  static const String customerForgetPassVerification = '/api/v1/customer/auth/verify-token';
  static const String customerForgetPassReset      = '/api/v1/customer/auth/reset-password';
  static const String customerLinkedWebsite        = '/api/v1/customer/linked-website';
  static const String customerBanner               = '/api/v1/customer/get-banner';
  static const String customerTransactionHistory   = '/api/v1/customer/transaction-history';
  static const String customerTransactionHistoryDownload = '/api/v1/customer/transaction/download-pdf';
  static const String customerPurposeUrl           = '/api/v1/customer/get-purpose';
  static const String configUri                    = '/api/v1/config';
  static const String imageConfigUrlApiNeed        = '/storage/app/public/purpose/';
  static const String customerProfileInfo          = '/api/v1/customer/get-customer';
  static const String customerCheckOtp             = '/api/v1/customer/check-otp';
  static const String customerVerifyOtp            = '/api/v1/customer/verify-otp';
  static const String customerChangePin            = '/api/v1/customer/change-pin';
  static const String customerUpdateTwoFactor      = '/api/v1/customer/update-two-factor';
  static const String customerSendMoney            = '/api/v1/customer/send-money';
  static const String customerRequestMoney         = '/api/v1/customer/request-money';
  static const String customerCashOut              = '/api/v1/customer/cash-out';
  static const String customerPinVerify            = '/api/v1/customer/verify-pin';
  static const String customerAddMoney             = '/api/v1/customer/add-money';
  static const String faqUri                       = '/api/v1/faq';
  static const String faqCategoryUri               = '/api/v1/faq/category';
  static const String notificationUri              = '/api/v1/customer/get-notification';
  static const String requestedMoneyUri            = '/api/v1/customer/get-requested-money';
  static const String acceptedRequestedMoneyUri    = '/api/v1/customer/request-money/approve';
  static const String deniedRequestedMoneyUri      = '/api/v1/customer/request-money/deny';
  static const String tokenUri                     = '/api/v1/customer/update-fcm-token';
  static const String checkCustomerUri             = '/api/v1/check-customer';
  static const String checkAgentUri                = '/api/v1/check-agent';
  static const String wonRequestedMoney            = '/api/v1/customer/get-own-requested-money';
  static const String customerRemove               = '/api/v1/customer/remove-account';
  static const String updateKycInformation         = '/api/v1/customer/update-kyc-information';
  static const String withdrawMethodList           = '/api/v1/customer/withdrawal-methods';
  static const String withdrawRequest              = '/api/v1/customer/withdraw';
  static const String getWithdrawalRequest         = '/api/v1/customer/withdrawal-requests';

  // ── Favourite Number ──────────────────────────────────────────────────────
  static const String addFavouriteNumber           = '/api/v1/customer/favourite-number/store';
  static const String updateFavouriteNumber        = '/api/v1/customer/favourite-number/update';
  static const String deleteFavouriteNumber        = '/api/v1/customer/favourite-number/delete';
  static const String getFavouriteNumberList       = '/api/v1/customer/favourite-number/list';

  // ── Report / Dispute ──────────────────────────────────────────────────────
  static const String reportReasonList             = '/api/v1/customer/dispute/reason/list';
  static const String createReportDispute          = '/api/v1/customer/dispute/create';

  // ── Add Funds / Manual Transfer ───────────────────────────────────────────
  static const String manualTransferBanksUri       = '/api/v1/manual-transfer/banks';
  static const String manualTransferSubmitUri      = '/api/v1/manual-transfer/submit';
  static const String manualTransferHistoryUri     = '/api/v1/manual-transfer/my-requests';
  static const String manualTransferStatusUri      = '/api/v1/manual-transfer/requests';
  static const String remittanceHistoryUri  = '/api/v1/remittance/history';
  static const String referFriendUri            = '/api/v1/referral/stats';

  // ── OTP Verification ──────────────────────────────────────────────────────
  static const String otpSendUri                   = '/api/v1/otp/send';
  static const String otpVerifyUri                 = '/api/v1/otp/verify';
  static const String otpResendUri                 = '/api/v1/otp/resend';
  static const String otpAgentRequestUri           = '/api/v1/otp/agent-request';

  // ── Referral Program ──────────────────────────────────────────────────────
  static const String referralValidateUri          = '/api/v1/referral/validate';
  static const String referralApplyUri             = '/api/v1/referral/apply';
  static const String referralStatsUri             = '/api/v1/referral/stats';

  // ── Trust & Settlement ────────────────────────────────────────────────────
  static const String trustBalancesUri             = '/api/v1/trust/balances';
  static const String trustLedgerUri               = '/api/v1/trust/ledger';
  static const String trustRebalanceUri            = '/api/v1/trust/rebalance';

  // ── Offline Wallet / Sync ─────────────────────────────────────────────────
  static const String offlineSyncUri               = '/api/v1/offline/sync';
  static const String offlineValidateUri           = '/api/v1/offline/validate';
  static const String offlineStatusUri             = '/api/v1/offline/status';

  // ── Shared Preference Keys ────────────────────────────────────────────────
  static const String theme                        = 'theme';
  static const String token                        = 'token';
  static const String customerCountryCode          = 'customer_country_code';
  static const String languageCode                 = 'language_code';
  static const String topic                        = 'notify';
  static const String sendMoneySuggestList         = 'send_money_suggest';
  static const String requestMoneySuggestList      = 'request_money_suggest';
  static const String recentAgentList              = 'recent_agent_list';

  // ── Transaction Type Constants ────────────────────────────────────────────
  static const String pending                      = 'pending';
  static const String approved                     = 'approved';
  static const String denied                       = 'denied';
  static const String cashIn                       = 'cash_in';
  static const String cashOut                      = 'cash_out';
  static const String sendMoney                    = 'send_money';
  static const String receivedMoney                = 'received_money';
  static const String adminCharge                  = 'admin_charge';
  static const String addMoney                     = 'add_money';
  static const String withdraw                     = 'withdraw';
  static const String payment                      = 'payment';
  static const String deductDisputedMoney          = 'deducted_dispute_money';
  static const String addDisputedMoney             = 'added_dispute_money';

  // ── App Feature Flags ─────────────────────────────────────────────────────
  static const String biometricAuth                = 'biometric_auth';
  static const String biometricPin                 = 'biometric';
  static const String hideUserBalance              = 'hide_balance';
  static const String contactPermission            = '';
  static const String userData                     = 'user';
  static const String showTourWidget               = 'show_tour';
  static const String showWelcomeBottomSheet       = 'welcome_bottom_sheet';
  static const String favNumberListKey             = 'favourite_number_list';
  static const String contactPermissionDeniedStatus = 'contact_permission_denied_status';

  // ── App Themes ────────────────────────────────────────────────────────────
  static const String all                          = 'all';
  static const String users                        = 'customers';
  static const String theme1                       = 'theme_1';
  static const String theme2                       = 'theme_2';
  static const String theme3                       = 'theme_3';

  // ── UI Config ─────────────────────────────────────────────────────────────
  static const String sdgCurrencyCode  = 'SDG';
  static const String sdgCurrencySymbol = 'ج.س';
  static const bool   sdgPositionLeft   = true;

  static const int balanceInputLen                 = 10;
  static const int balanceHideDurationInSecond     = 3;
  static const int dynamicDecimalPoint             = 2;

  // ── Languages ─────────────────────────────────────────────────────────────
  // Only English and Arabic — Arabic is the default (index 0)
  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.arabic,  languageName: 'Arabic',  countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
  ];

  static const List<String> transactionTypeList = ['both', 'credit', 'debit'];
  static const List<String> filterDateRangeList = [
    'this_week', 'last_7_days', 'last_15_days', 'this_month',
    'last_30_days', 'last_60_days', 'this_year', 'last_year', 'custom',
  ];

  static const List<String> allowedImageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
  static const int defaultImageQuality = 80;

  // ── Withdrawal System ─────────────────────────────────────────────────────
  static const String withdrawalMethodsUri = '/api/v1/withdrawal/methods';
  static const String withdrawalLimitsUri  = '/api/v1/withdrawal/limits';
  static const String withdrawalRequestUri = '/api/v1/withdrawal/request';
  static const String withdrawalHistoryUri = '/api/v1/withdrawal/history';

  // ── Remittance System ─────────────────────────────────────────────────────
  // Blueprint endpoints: getQuote / precheck / sendMoney
  static const String remittanceQuoteUri    = '/api/v1/remittance/quote';
  static const String remittancePrecheckUri = '/api/v1/remittance/precheck';
  static const String remittanceSendUri     = '/api/v1/remittance/send';
}
