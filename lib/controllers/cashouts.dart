import 'package:alterr/services/api.dart';
import 'package:get/get.dart';

class CashoutsController extends GetxController {
  RxMap<String, dynamic> bankDetails = RxMap<String, dynamic>(
      {'bank_name': '', 'account_number': '', 'account_name': ''});
  RxMap<String, dynamic> cashouts =
      RxMap<String, dynamic>({'cashouts': [], 'balance': 0});

  RxString amount = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCashouts();
  }

  Future saveBank() async {
    await ApiService()
        .request('auth/bank', bankDetails, 'POST', withToken: true);
  }

  getCashouts() async {
    Map<String, dynamic> response =
        await ApiService().request('auth/cashouts', {}, 'GET', withToken: true);
    cashouts['cashouts'] = response['cashouts'];
    cashouts['balance'] = response['balance'];
  }

  cashout() {
    ApiService().request('auth/cashouts',
        {'amount': double.parse(amount.value).toString()}, 'POST',
        withToken: true);
  }

  @override
  void onClose() {
    super.onClose();
    bankDetails.value = {
      'bank_name': '',
      'account_number': '',
      'account_name': ''
    };
    amount.value = '';
  }
}
