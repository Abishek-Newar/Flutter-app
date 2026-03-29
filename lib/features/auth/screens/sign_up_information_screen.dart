// lib/features/auth/screens/sign_up_information_screen.dart
// FIX: Replaced duplicate First Name + Last Name fields with a SINGLE
//      Full Name (Quad Name) field. lNameController removed entirely.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/common/widgets/custom_dialog_widget.dart';
import 'package:naqde_user/common/widgets/custom_pop_scope_widget.dart';
import 'package:naqde_user/features/setting/controllers/edit_profile_controller.dart';
import 'package:naqde_user/common/models/signup_body_model.dart';
import 'package:naqde_user/helper/dialog_helper.dart';
import 'package:naqde_user/helper/route_helper.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/common/widgets/custom_app_bar_widget.dart';
import 'package:naqde_user/common/widgets/custom_large_widget.dart';
import 'package:naqde_user/features/auth/widgets/gender_field_widget.dart';
import 'package:naqde_user/common/widgets/custom_text_field_widget.dart';
import 'package:naqde_user/common/widgets/text_field_title.dart';
import 'package:naqde_user/util/styles.dart';

class SignUpInformationScreen extends StatefulWidget {
  const SignUpInformationScreen({super.key});

  @override
  State<SignUpInformationScreen> createState() => _SignUpInformationScreenState();
}

class _SignUpInformationScreenState extends State<SignUpInformationScreen> {
  // Single Full Name controller replaces fName + lName
  final TextEditingController fullNameController    = TextEditingController();
  final TextEditingController occupationController  = TextEditingController();
  final TextEditingController emailController       = TextEditingController();
  final GlobalKey<FormState>  formKey               = GlobalKey<FormState>();

  @override
  void dispose() {
    fullNameController.dispose();
    occupationController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Get.find<EditProfileController>().setGender('Male');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return CustomPopScopeWidget(
      isExit: false,
      onPopInvoked: () => _onWillPop(context),
      child: Scaffold(
        appBar: CustomAppbarWidget(
            title: 'information'.tr, onTap: () => _onWillPop(context)),
        body: Column(children: [
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                    // ── Full Name (Quad Name) — single field ──────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeLarge,
                          Dimensions.paddingSizeLarge,
                          Dimensions.paddingSizeLarge,
                          0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextFieldTitle(
                          title: 'full_name'.tr.isEmpty
                              ? (isAr ? 'الاسم الكامل (الاسم الرباعي)' : 'Full Name (Quad Name)')
                              : 'full_name'.tr,
                          requiredMark: true,
                        ),
                        CustomTextFieldWidget(
                          hintText: 'enter_full_name'.tr.isEmpty
                              ? (isAr ? 'أدخل الاسم الكامل (الاسم الرباعي)' : 'Enter Full Name (Quad Name)')
                              : 'enter_full_name'.tr,
                          isShowBorder: true,
                          controller: fullNameController,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                          isAutoFocus: true,
                          onValidate: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'full_name_required'.tr.isEmpty
                                  ? (isAr ? 'يجب إدخال الاسم الكامل' : 'Full name is required')
                                  : 'full_name_required'.tr;
                            }
                            final parts = value.trim().split(' ');
                            if (parts.length < 2) {
                              return isAr
                                  ? 'يرجى إدخال الاسم الكامل (اسمان على الأقل)'
                                  : 'Please enter your full name (at least two names)';
                            }
                            return null;
                          },
                        ),
                      ]),
                    ),

                    // ── Email (optional) ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeLarge, 0,
                          Dimensions.paddingSizeLarge, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextFieldTitle(title: 'email_address'.tr),
                        CustomTextFieldWidget(
                          hintText: 'email_address_hint'.tr,
                          isShowBorder: true,
                          controller: emailController,
                          inputType: TextInputType.emailAddress,
                          onValidate: (email) {
                            if (email != null && email.isNotEmpty) {
                              if (!email.contains('@') || !email.contains('.')) {
                                return 'please_provide_valid_email'.tr;
                              }
                            }
                            return null;
                          },
                        ),
                      ]),
                    ),

                    // ── Occupation (optional) ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeLarge, 0,
                          Dimensions.paddingSizeLarge, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextFieldTitle(title: 'occupation'.tr),
                        CustomTextFieldWidget(
                          hintText: 'select_occupation'.tr,
                          isShowBorder: true,
                          controller: occupationController,
                        ),
                      ]),
                    ),

                    // ── Gender (Male / Female only) ───────────────────────
                    const GenderFieldWidget(),

                  ]),
                ),
              ),
            ),
          ),

          // ── Proceed Button ─────────────────────────────────────────────
          CustomLargeButtonWidget(
            text: 'proceed'.tr,
            onTap: () => _onProceed(context, isAr),
          ),
        ]),
      ),
    );
  }

  void _onProceed(BuildContext context, bool isAr) {
    if (!formKey.currentState!.validate()) return;

    final fullName  = fullNameController.text.trim();
    final parts     = fullName.split(' ');
    // Use first word as fName, rest as lName for backend compatibility
    final fName     = parts.first;
    final lName     = parts.length > 1 ? parts.sublist(1).join(' ') : parts.first;
    final email     = emailController.text.trim();
    final gender    = Get.find<EditProfileController>().gender ?? 'Male';
    final occupation = occupationController.text.trim();

    SignUpBodyModel signUpBody = SignUpBodyModel(
      fName:      fName,
      lName:      lName,
      email:      email.isNotEmpty ? email : null,
      gender:     gender,
      occupation: occupation.isNotEmpty ? occupation : null,
    );

    Get.toNamed(RouteHelper.getPinSetRoute(signUpBody));
  }

  Future<bool> _onWillPop(BuildContext context) async {
    DialogHelper.showAnimatedDialog(
      context,
      CustomDialogWidget(
        icon: Icons.question_mark,
        title: 'are_you_sure'.tr,
        description: 'do_you_want_to_exit_add_money'.tr,
        onTapFalseText: 'no'.tr,
        onTapTrueText: 'yes'.tr,
        onTapFalse: () => Get.back(),
        onTapTrue: () {
          Get.offAllNamed(RouteHelper.getSplashRoute());
        },
        isFailed: true,
      ),
      dismissible: false,
      isFlip: true,
    );
    return false;
  }
}
