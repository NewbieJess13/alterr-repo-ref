import 'dart:convert';
import 'package:alterr/models/post.dart';
import 'package:alterr/services/api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:alterr/controllers/nav.dart';
import 'package:permission_handler/permission_handler.dart';

class Notifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var platformChannelSpecifics;

  Future<void> initializeNotifications() async {
    await Permission.notification.request();
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'notif_sound.caf');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1', 'alterr', 'alterr channel',
        sound: RawResourceAndroidNotificationSound('notif_sound'),
        importance: Importance.max,
        priority: Priority.high);
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    var initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS, android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<dynamic> onSelectNotification(String? payload) async {
    if (payload != null) {
      Map<String, dynamic> notification = jsonDecode(payload);
      switch (notification['type']) {
        case 'post':
          Map<String, dynamic>? response = await ApiService().request(
              'posts/${notification['data']['post']['slug']}', {}, 'GET',
              withToken: true);
          if (response != null) {
            Rx<Post> post = Post.fromJson(response).obs;
          }
          break;

        case 'conversation':
          Get.find<NavController>()
              .openConversation(notification['message'], navigator?.context);
          break;
      }
    }
  }

  notify(String title, String body, Map<String, dynamic> data) async {
    await flutterLocalNotificationsPlugin.show(
        1, title, body, platformChannelSpecifics,
        payload: jsonEncode(data));
  }
}
