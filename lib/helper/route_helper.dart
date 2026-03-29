import 'dart:convert';
import 'package:get/get.dart';
import 'package:naqde_user/features/splash/controllers/splash_controller.dart';
import 'package:naqde_user/common/models/signup_body_model.dart';
import 'package:naqde_user/common/models/contact_model.dart';
import 'package:naqde_user/features/auth/screens/create_account_screen.dart';
import 'package:naqde_user/features/auth/screens/login_screen.dart';
import 'package:naqde_user/features/auth/screens/sign_up_information_screen.dart';
import 'package:naqde_user/features/auth/screens/pin_set_screen.dart';
import 'package:naqde_user/features/camera_verification/screens/camera_screen.dart';
import 'package:naqde_user/features/verification/screens/varification_screen.dart';
import 'package:naqde_user/features/home/screens/nav_bar_screen.dart';
import 'package:naqde_user/features/forget_pin/screens/forget_pin_screen.dart';
import 'package:naqde_user/features/forget_pin/screens/reset_pin_screen.dart';
import 'package:naqde_user/features/history/screens/history_screen.dart';
import 'package:naqde_user/features/home/screens/home_screen.dart';
import 'package:naqde_user/features/language/screens/change_language_screen.dart';
import 'package:naqde_user/features/notification/screens/notification_screen.dart';
import 'package:naqde_user/features/onboarding/screens/on_boarding_sceen.dart';
import 'package:naqde_user/features/setting/screens/profile_screen.dart';
import 'package:naqde_user/features/setting/widgets/change_pin_screen.dart';
import 'package:naqde_user/features/setting/screens/edit_profile_screen.dart';
import 'package:naqde_user/features/setting/widgets/faq_screen.dart';
import 'package:naqde_user/features/setting/screens/html_view_screen.dart';
import 'package:naqde_user/features/setting/screens/qr_code_download_or_share_screen.dart';
import 'package:naqde_user/features/setting/screens/support_screen.dart';
import 'package:naqde_user/features/splash/screens/splash_screen.dart';
import 'package:naqde_user/features/transaction_money/screens/transaction_balance_input_screen.dart';
import 'package:naqde_user/features/transaction_money/screens/transaction_confirmation_screen.dart';
import 'package:naqde_user/features/transaction_money/screens/transaction_money_screen.dart';
import 'package:naqde_user/features/transaction_money/widgets/share_statement_widget.dart';
import 'package:naqde_user/features/splash/screens/welcome_screen.dart';
// ── New Feature Screen Imports ─────────────────────────────────────────────────
import 'package:naqde_user/features/otp_verification/screens/otp_verification_screen.dart';
import 'package:naqde_user/features/referral/screens/referral_screen.dart';
import 'package:naqde_user/features/trust_settlement/screens/trust_settlement_screen.dart';
import 'package:naqde_user/features/manual_transfer/screens/bank_list_screen.dart';
import 'package:naqde_user/features/add_money/screens/bankak_transfer_screen.dart';
import 'package:naqde_user/features/offline_wallet/screens/offline_wallet_screen.dart';
import 'package:naqde_user/features/withdrawal/screens/withdrawal_amount_screen.dart';
import 'package:naqde_user/features/withdrawal/screens/withdrawal_details_screen.dart';
import 'package:naqde_user/features/withdrawal/screens/withdrawal_success_screen.dart';
import 'package:naqde_user/features/withdrawal/screens/withdrawal_history_screen.dart';
// ── Remittance System ──────────────────────────────────────────────────────
import 'package:naqde_user/features/remittance/screens/remittance_corridor_screen.dart';
import 'package:naqde_user/features/remittance/screens/remittance_amount_screen.dart';
import 'package:naqde_user/features/remittance/screens/remittance_recipient_screen.dart';
import 'package:naqde_user/features/remittance/screens/remittance_review_success_screens.dart';
import 'package:naqde_user/features/remittance/screens/remittance_history_screen.dart';

class RouteHelper {
  // ── Core routes ──────────────────────────────────────────────────────────
  static const String splash               = '/splash';
  static const String home                 = '/home';
  static const String navbar               = '/navbar';
  static const String history              = '/history';
  static const String notification         = '/notification';
  static const String themeAndLanguage     = '/themeAndLanguage';
  static const String profile              = '/profile';
  static const String changePinScreen      = '/change_pin_screen';
  static const String verifyOtpScreen      = '/verify_otp_screen';
  static const String noInternetScreen     = '/no_internet_screen';
  static const String sendMoney            = '/send_money';
  static const String choseLoginOrRegScreen = '/chose_login_or_reg';
  static const String createAccountScreen  = '/create_account';
  static const String verifyScreen         = '/verify_account';
  static const String selfieScreen         = '/selfie_screen';
  static const String otherInfoScreen      = '/other_info_screen';
  static const String pinSetScreen         = '/pin_set_screen';
  static const String welcomeScreen        = '/welcome_screen';
  static const String loginScreen          = '/login_screen';
  static const String fPhoneNumberScreen   = '/f_phone_number';
  static const String fVerificationScreen  = '/f_verification_screen';
  static const String resetPassScreen      = '/f_reset_pass_screen';
  static const String qrCodeScannerScreen  = '/qr_code_scanner_screen';
  static const String showWebViewScreen    = '/show_web_view_screen';
  static const String sendMoneyBalanceInput     = '/send_money_balance_input';
  static const String sendMoneyConfirmation     = '/send_money_confirmation';
  static const String cashOut                   = '/cash_out';
  static const String cashOutBalanceInput       = '/cash_out_balance_input';
  static const String cashOutConfirmation       = '/cash_out_confirmation';
  static const String requestMoney              = '/request_money';
  static const String requestMoneyBalanceInput  = '/request_money_balance_input';
  static const String requestMoneyConfirmation  = '/request_money_confirmation';
  static const String choseLanguageScreen       = '/chose_language';
  static const String editProfileScreen         = '/edit_profile';
  static const String shareStatement            = '/share_statement';
  static const String faq                       = '/faq';
  static const String terms                     = '/terms';
  static const String aboutUs                   = '/about_us';
  static const String privacy                   = '/privacy';
  static const String support                   = '/support';
  static const String qrCodeDownloadOrShare     = '/qr_code_download_or_share';

  // ── New Feature Routes ────────────────────────────────────────────────────
  static const String otpVerification      = '/otp-verification';
  static const String referralScreen       = '/referral';
  static const String trustSettlement      = '/trust-settlement';
  static const String addFundsScreen       = '/add-funds';
  static const String bankakTransfer       = '/bankak-transfer';
  static const String offlineWalletScreen  = '/offline-wallet';

  // ── Withdrawal System ─────────────────────────────────────────────────────
  static const String withdrawalAmount     = '/withdrawal-amount';
  static const String withdrawalDetails    = '/withdrawal-details';
  static const String withdrawalSuccess    = '/withdrawal-success';
  static const String withdrawalHistory    = '/withdrawal-history';

  // ── Remittance System ─────────────────────────────────────────────────────
  static const String remittanceCorridor  = '/remittance-corridor';
  static const String remittanceAmount    = '/remittance-amount';
  static const String remittanceRecipient = '/remittance-recipient';
  static const String remittanceReview    = '/remittance-review';
  static const String remittanceSuccess   = '/remittance-success';
  static const String remittanceHistory   = '/remittance-history';

  // ── Route Getters ─────────────────────────────────────────────────────────
  static String getSplashRoute()           => splash;
  static String getHomeRoute()             => home;
  static String getNavbarRoute()           => navbar;
  static String getLoginRoute({String? countryCode, String? phoneNumber, String? password, String? userName}) =>
      '$loginScreen?user-name=${userName ?? ''}&country-code=${countryCode ?? '+249'}&phone-number=${phoneNumber ?? ''}';
  static String getPinSetRoute(SignUpBodyModel signUpBody) {
    String signUpData = base64Url.encode(utf8.encode(jsonEncode(signUpBody.toJson())));
    return '$pinSetScreen?signup=$signUpData';
  }
  static String getRequestMoneyRoute({String? phoneNumber, required bool fromEdit}) =>
      '$requestMoney?phone-number=$phoneNumber&from-edit=${fromEdit ? 'edit-number' : 'home'}';
  static String getForgetPassRoute({required String? countryCode, required String phoneNumber}) =>
      '$fPhoneNumberScreen?country-code=$countryCode&phone-number=$phoneNumber';
  static String getRequestMoneyBalanceInputRoute()                   => requestMoneyBalanceInput;
  static String getRequestMoneyConfirmationRoute({required String inputBalanceText}) =>
      '$requestMoneyConfirmation?input-balance=$inputBalanceText';
  static String getNoInternetRoute()                                 => noInternetScreen;
  static String getChoseLoginRegRoute()                              => choseLoginOrRegScreen;
  static String getSendMoneyRoute({String? phoneNumber, required bool fromEdit}) =>
      '$sendMoney?phone-number=$phoneNumber&from-edit=${fromEdit ? 'edit-number' : 'home'}';
  static String getSendMoneyInputRoute({required String transactionType}) =>
      '$sendMoneyBalanceInput?transaction-type=$transactionType';
  static String getSendMoneyConfirmationRoute({required String inputBalanceText, required String transactionType}) =>
      '$sendMoneyConfirmation?input-balance=$inputBalanceText&transaction-type=$transactionType';
  static String getChoseLanguageRoute()                              => choseLanguageScreen;
  static String getCashOutScreenRoute({String? phoneNumber, required bool fromEdit}) =>
      '$cashOut?phone-number=$phoneNumber&from-edit=${fromEdit ? 'edit-number' : 'home'}';
  static String getCashOutBalanceInputRoute()                        => cashOutBalanceInput;
  static String getFResetPassRoute({String? phoneNumber, String? otp}) =>
      '$resetPassScreen?phone-number=$phoneNumber&otp=$otp';
  static String getEditProfileRoute()                                => editProfileScreen;
  static String getChangePinRoute()                                  => changePinScreen;
  static String getAddMoneyInputRoute()                              => '/add_money_input';
  static String getSupportRoute()                                    => support;
  static String getCashOutConfirmationRoute({required String inputBalanceText}) =>
      '$cashOutConfirmation?input-balance=$inputBalanceText';
  static String getShareStatementRoute({required String amount, required String transactionType, required ContactModel contactModel}) {
    String data = base64Url.encode(utf8.encode(jsonEncode(contactModel.toJson())));
    String transactionType0 = base64Url.encode(utf8.encode(transactionType));
    return '$shareStatement?amount=$amount&transaction-type=$transactionType0&contact=$data';
  }
  static String getQrCodeDownloadOrShareRoute({required String qrCode, required String phoneNumber}) {
    String qrCode0 = base64Url.encode(utf8.encode(qrCode));
    String phoneNumber0 = base64Url.encode(utf8.encode(phoneNumber));
    return '$qrCodeDownloadOrShare?qr-code=$qrCode0&phone-number=$phoneNumber0';
  }
  static String getNavBarRoute() => getNavbarRoute();
  static String getRegistrationRoute() => getChoseLoginRegRoute();
  static String getSelfieRoute({bool fromEditProfile = false}) =>
      '$selfieScreen${fromEditProfile ? '?page=edit-profile' : ''}';
  static String getVerifyRoute({String? phoneNumber}) =>
      getOtpVerificationRoute(phoneNumber: phoneNumber);

  // New feature route getters
  static String getOtpVerificationRoute({String? phoneNumber}) =>
      '$otpVerification${phoneNumber != null ? '?phone=$phoneNumber' : ''}';
  static String getReferralRoute()         => referralScreen;
  static String getTrustSettlementRoute()  => trustSettlement;
  static String getAddFundsRoute()         => addFundsScreen;
  static String getBankakTransferRoute()   => bankakTransfer;
  static String getOfflineWalletRoute()    => offlineWalletScreen;

  // Withdrawal system
  static String getWithdrawalAmountRoute()  => withdrawalAmount;
  static String getWithdrawalDetailsRoute() => withdrawalDetails;
  static String getWithdrawalSuccessRoute() => withdrawalSuccess;
  static String getWithdrawalHistoryRoute() => withdrawalHistory;

  // ── Remittance System ─────────────────────────────────────────────────────
  static String getRemittanceCorridorRoute()  => remittanceCorridor;
  static String getRemittanceAmountRoute()    => remittanceAmount;
  static String getRemittanceRecipientRoute() => remittanceRecipient;
  static String getRemittanceReviewRoute()    => remittanceReview;
  static String getRemittanceSuccessRoute()   => remittanceSuccess;
  static String getRemittanceHistoryRoute()   => remittanceHistory;

  // ── Route Definitions ─────────────────────────────────────────────────────
  static List<GetPage> routes = [
    GetPage(name: splash,       page: () => const SplashScreen()),
    GetPage(name: home,         page: () => const HomeScreen()),
    GetPage(name: navbar,       page: () => NavBarScreen(
      selectedPage: (Get.parameters['selectedPage']?.isNotEmpty ?? false) ? Get.parameters['selectedPage'] : null,
    )),
    GetPage(name: shareStatement, page: () => ShareStatementWidget(
      amount: Get.parameters['amount'], charge: null, trxId: null,
      transactionType: utf8.decode(base64Url.decode(Get.parameters['transaction-type']!.replaceAll(' ', '+'))),
      contactModel: ContactModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['contact']!)))),
    )),
    GetPage(name: history,      page: () => const HistoryScreen()),
    GetPage(name: notification, page: () => const NotificationScreen()),
    GetPage(name: profile,      page: () => const ProfileScreen()),
    GetPage(name: changePinScreen, page: () => const ChangePinScreen()),
    GetPage(name: sendMoney,    page: () => TransactionMoneyScreen(
      phoneNumber: Get.parameters['phone-number'],
      fromEdit: Get.parameters['from-edit'] == 'edit-number',
    )),
    GetPage(name: sendMoneyBalanceInput, page: () => TransactionBalanceInputScreen(
      transactionType: Get.parameters['transaction-type'],
    )),
    GetPage(name: sendMoneyConfirmation, page: () => TransactionConfirmationScreen(
      inputBalance: double.tryParse(Get.parameters['input-balance']!),
      transactionType: Get.parameters['transaction-type'],
    )),
    GetPage(name: choseLoginOrRegScreen, page: () => const CreateAccountScreen()),
    GetPage(name: createAccountScreen,   page: () => const CreateAccountScreen()),
    GetPage(name: verifyScreen, page: () {
      final String? phoneNumber = Uri.decodeComponent(Get.parameters['phone_number']!) != 'null'
          ? Uri.decodeComponent(Get.parameters['phone_number']!) : null;
      return VerificationScreen(phoneNumber: phoneNumber);
    }),
    GetPage(name: selfieScreen,     page: () => CameraScreen(fromEditProfile: Get.parameters['page'] == 'edit-profile')),
    GetPage(name: otherInfoScreen,  page: () => const SignUpInformationScreen()),
    GetPage(name: pinSetScreen,     page: () => PinSetScreen(
      signUpBody: SignUpBodyModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['signup']!)))),
    )),
    GetPage(name: welcomeScreen, page: () => WelcomeScreen(
      countryCode: Get.parameters['country-code']!.replaceAll(' ', '+'),
      phoneNumber: Get.parameters['phone-number'],
      password: Get.parameters['password'],
    )),
    GetPage(name: loginScreen, page: () => LoginScreen(
      userName: Get.parameters['user-name'],
      countryCode: Get.parameters['country-code']!.replaceAll(' ', '+'),
      phoneNumber: Get.parameters['phone-number'],
    )),
    GetPage(name: fPhoneNumberScreen, page: () => ForgetPinScreen(
      countryCode: Get.parameters['country-code']!.replaceAll(' ', '+'),
      phoneNumber: Get.parameters['phone-number'],
    )),
    GetPage(name: resetPassScreen, page: () => ResetPinScreen(
      phoneNumber: Get.parameters['phone-number']!.replaceAll(' ', '+'),
      otp: Get.parameters['otp']!.replaceAll(' ', '+'),
    )),
    GetPage(name: choseLanguageScreen,    page: () => const ChooseLanguageScreen()),
    GetPage(name: editProfileScreen,      page: () => const EditProfileScreen()),
    GetPage(name: faq,     page: () => FaqScreen(title: 'faq'.tr)),
    GetPage(name: terms,   page: () => HtmlViewScreen(title: 'terms'.tr,       url: Get.find<SplashController>().configModel!.termsAndConditions)),
    GetPage(name: aboutUs, page: () => HtmlViewScreen(title: 'about_us'.tr,    url: Get.find<SplashController>().configModel!.aboutUs)),
    GetPage(name: privacy, page: () => HtmlViewScreen(title: 'privacy_policy'.tr, url: Get.find<SplashController>().configModel!.privacyPolicy)),
    GetPage(name: support, page: () => const SupportScreen()),
    GetPage(name: qrCodeDownloadOrShare, page: () => QrCodeDownloadOrShareScreen(
      qrCode: utf8.decode(base64Url.decode(Get.parameters['qr-code']!.replaceAll(' ', '+'))),
      phoneNumber: utf8.decode(base64Url.decode(Get.parameters['phone-number']!.replaceAll(' ', '+'))),
    )),

    // ── New Feature Pages ────────────────────────────────────────────────────
    GetPage(
      name: otpVerification,
      page: () => OtpVerificationScreen(
        phoneNumber: Get.parameters['phone'],
        isForgetPassword: Get.parameters['phone'] != null,
      ),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: referralScreen,
      page: () => const ReferralScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: trustSettlement,
      page: () => const TrustSettlementScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addFundsScreen,
      page: () => const BankListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: bankakTransfer,
      page: () => const BankakTransferScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: offlineWalletScreen,
      page: () => const OfflineWalletScreen(),
      transition: Transition.fadeIn,
    ),
    // ── Withdrawal System ─────────────────────────────────────────────────
    GetPage(
      name: withdrawalAmount,
      page: () => const WithdrawalAmountScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: withdrawalDetails,
      page: () => const WithdrawalDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: withdrawalSuccess,
      page: () => const WithdrawalSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: withdrawalHistory,
      page: () => const WithdrawalHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    // ── Remittance System ─────────────────────────────────────────────────
    GetPage(
      name: remittanceCorridor,
      page: () => const RemittanceCorridorScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: remittanceAmount,
      page: () => const RemittanceAmountScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: remittanceRecipient,
      page: () => const RemittanceRecipientScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: remittanceReview,
      page: () => const RemittanceReviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: remittanceSuccess,
      page: () => const RemittanceSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: remittanceHistory,
      page: () => const RemittanceHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
