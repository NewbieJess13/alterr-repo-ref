import 'package:alterr/services/api.dart';
import 'package:get/get.dart';
import 'package:alterr/models/post.dart';

class PostUnlockController extends GetxController {
  RxString cardNumber = ''.obs;
  RxString expiredDate = ''.obs;
  RxString cvv = ''.obs;
  RxString cardHolderName = ''.obs;
  RxBool isCvvFocused = false.obs;
  RxBool loading = false.obs;
  RxInt barias = 0.obs;
  RxBool unlocking = false.obs;

  getBarias() async {
    loading.value = true;
    Map<String, dynamic> response =
        await ApiService().request('auth/barias', {}, 'GET', withToken: true);
    barias.value = response['barias'];
    loading.value = false;
  }

  Future unlockPost(Rx<Post> post) async {
    unlocking.value = true;
    Map<String, dynamic>? response = await ApiService().request(
        'posts/${post.value.slug}/unlock', {}, 'POST',
        withToken: true);
    if (response != null) {
      post.value.thumbnail = response['thumbnail'];
      post.value.source = response['source'];
      post.value.unlocked = response['unlocked'];
      post.refresh();
      if (post.value.unlocked == true) {
        navigator?.pop();
      }
    }
    unlocking.value = false;
  }
}
