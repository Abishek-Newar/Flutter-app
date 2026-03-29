import 'package:naqde_user/features/add_money/domain/reposotories/add_money_repo.dart';
import 'package:get/get.dart';

class AddMoneyController extends GetxController implements GetxService {
  final AddMoneyRepo addMoneyRepo;
  AddMoneyController({required this.addMoneyRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _paymentMethod;
  String? get paymentMethod => _paymentMethod;

  void setPaymentMethod(String? method, {isUpdate = true}) {
    _paymentMethod = method;
    if (isUpdate) {
      update();
    }
  }
}
