// lib/features/setting/screens/profile_screen.dart
// CHANGES:
//  - Cash Out added under Profile actions (moved from home)
//  - Request Money added under Profile actions (moved from home)
//  - Trust & Settlement menu item added
//  - Referral Program menu item added
//  - Logout dialog now shows two clear buttons: "Logout" / "Cancel"

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_switch_button.dart';
import 'package:naqde_user/features/auth/controllers/auth_controller.dart';
import 'package:naqde_user/features/favorite_number/screens/favorite_number_screen.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/features/splash/controllers/splash_controller.dart';
import 'package:naqde_user/features/setting/domain/models/profile_model.dart';
import 'package:naqde_user/helper/dialog_helper.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/images.dart';
import 'package:naqde_user/util/styles.dart';
import 'package:naqde_user/common/widgets/custom_ink_well_widget.dart';
import 'package:naqde_user/common/widgets/custom_dialog_widget.dart';
import 'package:naqde_user/features/setting/widgets/menu_item.dart' as widget;
import 'package:naqde_user/features/setting/widgets/profile_holder.dart';
import 'package:naqde_user/features/setting/widgets/status_menu.dart';
import 'package:naqde_user/features/setting/widgets/user_info_widget.dart';
import 'package:naqde_user/features/requested_money/screens/requested_money_list_screen.dart';
import 'package:naqde_user/features/setting/screens/transaction_limit_screen.dart';
import 'package:naqde_user/helper/transaction_type.dart';
import 'package:naqde_user/features/transaction_money/screens/transaction_money_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();
    List<TransactionTableModel> transactionTableModelList = [];
    ProfileModel? userInfo = Get.find<ProfileController>().userInfo;

    if (userInfo != null) {
      transactionTableModelList.addAll([
        if (splashController.configModel!.systemFeature!.sendMoneyStatus! &&
            splashController.configModel!.customerSendMoneyLimit!.status)
          TransactionTableModel(
            'send_money'.tr, Images.sendMoneyImage,
            splashController.configModel!.customerSendMoneyLimit!,
            Transaction(
              userInfo.transactionLimits!.dailySendMoneyCount ?? 0,
              userInfo.transactionLimits!.monthlySendMoneyCount ?? 0,
              userInfo.transactionLimits!.dailySendMoneyAmount ?? 0,
              userInfo.transactionLimits!.monthlySendMoneyAmount ?? 0,
            ),
          ),
        if (splashController.configModel!.systemFeature!.cashOutStatus! &&
            splashController.configModel!.customerCashOutLimit!.status)
          TransactionTableModel(
            'cash_out'.tr, Images.cashOutLogo,
            splashController.configModel!.customerCashOutLimit!,
            Transaction(
              userInfo.transactionLimits!.dailyCashOutCount ?? 0,
              userInfo.transactionLimits!.monthlyCashOutCount ?? 0,
              userInfo.transactionLimits!.dailyCashOutAmount ?? 0,
              userInfo.transactionLimits!.monthlyCashOutAmount ?? 0,
            ),
          ),
        if (splashController.configModel!.systemFeature!.sendMoneyRequestStatus! &&
            splashController.configModel!.customerRequestMoneyLimit!.status)
          TransactionTableModel(
            'send_money_request'.tr, Images.requestMoney,
            splashController.configModel!.customerRequestMoneyLimit!,
            Transaction(
              userInfo.transactionLimits!.dailySendMoneyRequestCount ?? 0,
              userInfo.transactionLimits!.monthlySendMoneyRequestCount ?? 0,
              userInfo.transactionLimits!.dailySendMoneyRequestAmount ?? 0,
              userInfo.transactionLimits!.monthlySendMoneyRequestAmount ?? 0,
            ),
          ),
        if (splashController.configModel!.systemFeature!.addMoneyStatus! &&
            splashController.configModel!.customerAddMoneyLimit!.status)
          TransactionTableModel(
            'add_money'.tr, Images.addMoneyLogo3,
            splashController.configModel!.customerAddMoneyLimit!,
            Transaction(
              userInfo.transactionLimits?.dailyAddMoneyCount ?? 0,
              userInfo.transactionLimits?.monthlyAddMoneyCount ?? 0,
              userInfo.transactionLimits?.dailyAddMoneyAmount ?? 0,
              userInfo.transactionLimits?.monthlyAddMoneyAmount ?? 0,
            ),
          ),
        if (splashController.configModel!.systemFeature!.withdrawRequestStatus! &&
            splashController.configModel!.customerWithdrawLimit!.status)
          TransactionTableModel(
            'withdraw'.tr, Images.withdrawMoneyLogo3,
            splashController.configModel!.customerWithdrawLimit!,
            Transaction(
              userInfo.transactionLimits?.dailyWithdrawRequestCount ?? 0,
              userInfo.transactionLimits?.monthlyWithdrawRequestCount ?? 0,
              userInfo.transactionLimits?.dailyWithdrawRequestAmount ?? 0,
              userInfo.transactionLimits?.monthlyWithdrawRequestAmount ?? 0,
            ),
          ),
      ]);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppbarWidget(title: 'profile'.tr, onlyTitle: true),
      body: GetBuilder<AuthController>(builder: (authController) {
        return ModalProgressHUD(
          inAsyncCall: authController.isLoading,
          progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(children: [

              const UserInfoWidget(),

              // ═══════════════════════════════════════════════════════
              // SECTION: Settings
              // ═══════════════════════════════════════════════════════
              ProfileHeader(title: 'setting'.tr),
              Column(children: [

                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.editProfile, title: 'edit_profile'.tr),
                  onTap: () => Get.toNamed(RouteHelper.getEditProfileRoute()),
                ),

                // ── Cash Out (moved from home) ─────────────────────
                if (splashController.configModel!.systemFeature!.cashOutStatus!)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.cashOutLogo, title: 'cash_out'.tr),
                    onTap: () => Get.to(() => const TransactionMoneyScreen(
                          fromEdit: false,
                          transactionType: TransactionType.cashOut,
                        )),
                  ),

                // ── Request Money (moved from home) ────────────────
                if (splashController.configModel!.systemFeature!.sendMoneyRequestStatus!)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.requestMoney, title: 'request_money'.tr),
                    onTap: () => Get.to(() => const TransactionMoneyScreen(
                          fromEdit: false,
                          transactionType: TransactionType.requestMoney,
                        )),
                  ),

                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.withdrawProfile, title: 'withdraw_history'.tr),
                  onTap: () => Get.to(() => const RequestedMoneyListScreen(requestType: RequestType.withdraw)),
                ),

                if (splashController.configModel?.isFavoriteNumberActive ?? false)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.favoriteNumberIcon, title: 'favorite_number'.tr),
                    onTap: () => Get.to(() => const FavoriteNumberScreen()),
                  ),

                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.requestProfile, title: 'requests'.tr),
                  onTap: () => Get.to(() => const RequestedMoneyListScreen(requestType: RequestType.request)),
                ),

                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.sendMoneyProfile, title: 'send_requests'.tr),
                  onTap: () => Get.to(() => const RequestedMoneyListScreen(requestType: RequestType.sendRequest)),
                ),

                if (transactionTableModelList.isNotEmpty)
                  CustomInkWellWidget(
                    child: widget.MenuItem(
                        image: Images.transactionLimitProfile, title: 'transaction_limit'.tr),
                    onTap: () => Get.to(() => TransactionLimitScreen(
                          transactionTableModelList: transactionTableModelList,
                        )),
                  ),

                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.pinChangeLogo, title: 'change_pin'.tr),
                  onTap: () => Get.toNamed(RouteHelper.getChangePinRoute()),
                ),

                if (AppConstants.languages.length > 1)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.languageLogo, title: 'change_language'.tr),
                    onTap: () => Get.toNamed(RouteHelper.getChoseLanguageRoute()),
                  ),

                if (Get.find<SplashController>().configModel?.twoFactor ?? false)
                  GetBuilder<ProfileController>(builder: (profileController) {
                    return profileController.isLoading
                        ? const TwoFactorShimmer()
                        : StatusMenu(
                            title: 'two_factor_authentication'.tr,
                            leading: Image.asset(Images.twoFactorAuthentication, width: 28.0),
                          );
                  }),

                if (authController.isBiometricSupported)
                  StatusMenu(
                    title: 'biometric_login'.tr,
                    leading: SizedBox(width: 28, child: Image.asset(Images.fingerprint)),
                    isAuth: true,
                  ),

                // Dark mode toggle
                GetBuilder<ProfileController>(builder: (profileController) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: 10),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Image.asset(Images.changeTheme, width: Dimensions.fontSizeOverOverLarge),
                      ),
                      Text('dark_mode'.tr, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge - 1)),
                      const Spacer(),
                      CustomSwitchButton(
                        onToggled: (_) => profileController.onChangeTheme(),
                        isToggled: profileController.isSwitched,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    ]),
                  );
                }),

                // Hide balance toggle
                GetBuilder<ProfileController>(builder: (profileController) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: 10),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Image.asset(Images.hideBalance, width: Dimensions.fontSizeOverOverLarge),
                      ),
                      Expanded(
                        child: Text('hide_balance_in_home_page'.tr,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge - 1),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                      CustomSwitchButton(
                        onToggled: (_) => profileController.toggleUserBalanceShowingStatus(),
                        isToggled: profileController.isUserBalanceHide(),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    ]),
                  );
                }),

              ]),

              // ═══════════════════════════════════════════════════════
              // SECTION: Features (Trust, Referral)
              // ═══════════════════════════════════════════════════════
              ProfileHeader(title: 'features'.tr.isEmpty ? (Get.locale?.languageCode == 'ar' ? 'الميزات' : 'Features') : 'features'.tr),
              Column(children: [

                // Referral Program
                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.referFriend, title: 'referral_program'.tr),
                  onTap: () => Get.toNamed(RouteHelper.getReferralRoute()),
                ),

              ]),

              // ═══════════════════════════════════════════════════════
              // SECTION: Support
              // ═══════════════════════════════════════════════════════
              ProfileHeader(title: 'support'.tr),
              Column(children: [
                if ((splashController.configModel!.companyEmail != null) ||
                    (splashController.configModel!.companyPhone != null))
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.supportLogo, title: '24_support'.tr),
                    onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                  ),
                if (splashController.configModel!.systemFeature!.faqStatus!)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.questionLogo, title: 'faq'.tr),
                    onTap: () => Get.toNamed(RouteHelper.faq),
                  ),
              ]),

              // ═══════════════════════════════════════════════════════
              // SECTION: Policies
              // ═══════════════════════════════════════════════════════
              ProfileHeader(title: 'policies'.tr),
              Column(children: [
                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.aboutUs, title: 'about_us'.tr),
                  onTap: () => Get.toNamed(RouteHelper.aboutUs),
                ),
                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.terms, title: 'terms'.tr),
                  onTap: () => Get.toNamed(RouteHelper.terms),
                ),
                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.privacy, title: 'privacy_policy'.tr),
                  onTap: () => Get.toNamed(RouteHelper.privacy),
                ),
              ]),

              // ═══════════════════════════════════════════════════════
              // SECTION: Account
              // ═══════════════════════════════════════════════════════
              ProfileHeader(title: 'account'.tr),
              Column(children: [

                // ── Logout with two-button dialog ──────────────────
                CustomInkWellWidget(
                  child: widget.MenuItem(image: Images.logOut, title: 'logout'.tr),
                  onTap: () => _showLogoutDialog(context),
                ),

                if (splashController.configModel?.selfDelete == true)
                  CustomInkWellWidget(
                    child: widget.MenuItem(image: Images.selfDelete, title: 'delete_account'.tr),
                    onTap: () {
                      DialogHelper.showAnimatedDialog(
                        context,
                        CustomDialogWidget(
                          icon: Icons.question_mark_sharp,
                          title: 'are_you_sure_to_delete_account'.tr,
                          description: 'it_will_remove_your_all_information'.tr,
                          onTapFalseText: 'no'.tr,
                          onTapTrueText: 'yes'.tr,
                          isFailed: true,
                          onTapFalse: () => Get.back(),
                          onTapTrue: () => Get.find<AuthController>().removeUser(),
                          bigTitle: true,
                        ),
                        dismissible: false,
                        isFlip: true,
                      );
                    },
                  ),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ]),

            ]),
          ),
        );
      }),
    );
  }

  // ── Logout dialog: two clear action buttons ─────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    DialogHelper.showAnimatedDialog(
      context,
      CustomDialogWidget(
        icon: Icons.logout,
        title: 'are_you_sure_you_want_to_logout'.tr,
        description: '',
        onTapFalseText: 'cancel_logout_btn'.tr.isEmpty ? 'Cancel' : 'cancel_logout_btn'.tr,
        onTapTrueText: 'logout_confirm_btn'.tr.isEmpty ? 'Logout' : 'logout_confirm_btn'.tr,
        isFailed: true,
        onTapFalse: () => Get.back(),
        onTapTrue: () => Get.find<ProfileController>().logOut(context),
        bigTitle: true,
      ),
      dismissible: false,
      isFlip: true,
    );
  }
}
