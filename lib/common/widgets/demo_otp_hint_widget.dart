import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/app_constants.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';

class DemoOtpHintWidget extends StatelessWidget {
  const DemoOtpHintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppConstants.demo ? Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Text(
        'for_demo_1234'.tr,
        style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
      ),
    ) : const SizedBox();
  }
}
