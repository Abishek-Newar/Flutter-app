// lib/features/auth/widgets/gender_field_widget.dart
// CHANGE: Removed "Other" gender option. Only Male and Female remain.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/features/setting/controllers/edit_profile_controller.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/images.dart';
import 'gender_card_widget.dart';

class GenderFieldWidget extends StatelessWidget {
  final bool fromEditProfile;
  const GenderFieldWidget({super.key, this.fromEditProfile = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (controller) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: Dimensions.paddingSizeExtraLarge,
          left: fromEditProfile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
          right: fromEditProfile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
          bottom: Dimensions.paddingSizeDefault,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('select_your_gender'.tr,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            // Male
            Expanded(child: GenderCardWidget(
              icon: Images.male,
              text: 'male'.tr,
              color: controller.gender?.toLowerCase() == 'male'
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              onTap: () => controller.setGender('Male'),
            )),

            const SizedBox(width: Dimensions.paddingSizeLarge),

            // Female
            Expanded(child: GenderCardWidget(
              icon: Images.female,
              text: 'female'.tr,
              color: controller.gender?.toLowerCase() == 'female'
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              onTap: () => controller.setGender('Female'),
            )),

            // "Other" REMOVED as per design requirements

          ]),
        ]),
      );
    });
  }
}
