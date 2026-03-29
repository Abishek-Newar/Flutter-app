import 'package:naqde_user/features/setting/domain/models/profile_model.dart';
import 'package:naqde_user/features/setting/controllers/profile_screen_controller.dart';
import 'package:naqde_user/features/camera_verification/controllers/camera_screen_controller.dart';
import 'package:naqde_user/data/api/api_checker.dart';
import 'package:naqde_user/data/api/api_client.dart';
import 'package:naqde_user/common/models/response_model.dart';
import 'package:naqde_user/features/auth/domain/reposotories/auth_repo.dart';
import 'package:naqde_user/helper/custom_snackbar_helper.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController implements GetxService{
  final AuthRepo authRepo;
  EditProfileController({required this.authRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _image ;
  String? get image => _image;
  void setImage(String image){
    _image = image;
  }

  ///gender
  String? _gender;
  String? get gender => _gender;

  void setGender(String select, {bool isUpdate = true}){
    _gender = select;

    if(isUpdate){
      update();
    }
  }

  ///occupation
  String? _occupation ;
  String? get occupation => _occupation;

  Future<bool> updateProfileData(ProfileModel editProfileBody,List<MultipartBody> multipartBody) async{
    _isLoading = true;
    bool emailValidation = true;
    bool isSuccess = false;
    update();
    Map<String, String> allProfileInfo = {
      'f_name': editProfileBody.fName ?? '',
      'l_name': editProfileBody.lName ?? '',
      'gender': editProfileBody.gender ?? '',
      'occupation': editProfileBody.occupation ?? '',
      '_method': 'put',
    };
    if(editProfileBody.email != '') {
      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(editProfileBody.email!);

      if(emailValid){
        allProfileInfo.addAll({'email': editProfileBody.email ?? ''});
      }else{
        emailValidation = emailValid;
      }
    }

    if(!emailValidation) {
      showCustomSnackBarHelper('please_provide_valid_email'.tr);
      _isLoading = false;
      update();
    }else {
      Response response = await authRepo.updateProfile(allProfileInfo, multipartBody);
      ResponseModel responseModel;
      if (response.statusCode == 200) {
        responseModel = ResponseModel(true, response.body['message']);
        isSuccess = true;
        if(Get.find<CameraScreenController>().getImage != null) {
          Get.find<CameraScreenController>().removeImage();
        }
        Get.find<ProfileController>().getProfileData(reload: true, isUpdate: true);
        Get.back();
        showCustomSnackBarHelper(responseModel.message, isError: false);
      }
      else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }
    return isSuccess;
  }
}