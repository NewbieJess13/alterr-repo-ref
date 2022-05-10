import 'package:alterr/services/api.dart';
import 'package:get/get.dart';
import 'package:alterr/models/notification.dart';

class NotificationController extends GetxController {
  RxList<Rx<Notification>> notifications = <Rx<Notification>>[].obs;
  String? nextPageUrl;
  int page = 1;
  RxBool loading = true.obs;
  Rx<bool> detailsPage = false.obs;
  RxInt toReadNotifs = 0.obs;

  getNotifications({bool clear = true}) async {
    Map<String, dynamic>? response = await ApiService()
        .request('notifications?page=$page', {}, "GET", withToken: true);

    if (clear) {
      toReadNotifs.value = 0;
      notifications.clear();
    }
    if (response != null && response['data'].length > 0) {
      List<Rx<Notification>> notificationList = [];

      for (Map<String, dynamic> notification in response['data']) {
        notificationList.add(Notification.fromJson(notification).obs);
      }
      toReadNotifs.refresh();
      notifications.addAll(notificationList);
      notifications.refresh();
      nextPageUrl = response['next_page_url'];
      updateToReadNotifs();
    }
    loading.value = false;
    loading.refresh();
  }

  updateToReadNotifs() {
    toReadNotifs.value = 0;
    notifications.forEach((Rx<Notification> notification) {
      if (notification.value.hasRead == false) {
        toReadNotifs++;
      }
    });
    toReadNotifs.refresh();
  }

  Future refreshNotifications() async {
    page = 1;
    await getNotifications();
  }

  Future nextPageNotifications() async {
    if (nextPageUrl != null) {
      Uri uri = Uri.dataFromString(nextPageUrl!);
      String? nextPage = uri.queryParameters['page'];
      if (nextPage != null) {
        page = int.parse(nextPage);
        await getNotifications(clear: false);
      }
    }
  }

  updateStatus(int id) async {
    int index = notifications.indexWhere((element) => element.value.id == id);
    notifications[index].value.hasRead = true;
    await ApiService().request('notifications/$id', {}, "PUT", withToken: true);
    updateToReadNotifs();
    notifications.refresh();
  }
}
