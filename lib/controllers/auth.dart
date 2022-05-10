import 'dart:async';
import 'dart:convert';
import 'package:alterr/controllers/conversation.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/post_unlock.dart';
import 'package:alterr/controllers/nav.dart';
import 'package:alterr/controllers/notification.dart';
import 'package:alterr/models/conversations.dart';
import 'package:alterr/services/notifier.dart';
import 'package:alterr/services/pusher.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/services/api.dart';
import 'package:alterr/screens/topup.dart';
import 'package:alterr/services/localstorage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alterr/models/post.dart';

class AuthController extends GetxController {
  User? user;
  RxBool loading = true.obs;
  RxBool loginLoading = false.obs;
  bool hasInternet = false;
  RxBool showPassword = false.obs;
  PusherClient? pusher;
  late String userChannel;
  late int? currentConversationId;
  RxBool profileDetailsPage = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final navController = Get.put(NavController());
  Rx<String?> profilePicture = ''.obs;
  RxBool authenticated = false.obs;

  final notifier = Notifier();
  @override
  void onInit() {
    super.onInit();
    getAuth();
  }

  Future login(Map<String, String?> loginData) async {
    loginLoading.value = true;
    Map<String, dynamic>? response =
        await ApiService().request('auth/login', loginData, 'POST');
    if (response != null) {
      String token = response['access_token'];
      await LocalStorage.saveUserTokenSharedPref(token);
      await getAuth();

      emailController.clear();
      passwordController.clear();
    }
    loginLoading.value = false;
  }

  Future signOut() async {
    authenticated.value = false;
    user = null;
    await ApiService().request('auth/logout', {}, 'POST', withToken: true);
    await LocalStorage.clearSharedPrefKey(LocalStorage.tokenKey);
    await pusher?.unsubscribe(userChannel);
    await pusher?.disconnect();
    navController.selectTab('Feed', 0);
    DefaultCacheManager().emptyCache();
  }

  getAuth() async {
    dynamic response =
        await ApiService().request('auth/profile', {}, 'GET', withToken: true);
    if (response == null) {
      user = null;
    } else {
      user = User.fromJson(response);
      if (user?.profilePicture != null) {
        profilePicture.value = user?.profilePicture;
      }
      authenticated.value = true;
      Get.put(ConversationsController()).getConversations();
      Get.put(NotificationController()).getNotifications();
      await notifier.initializeNotifications();

      String keys = jsonEncode(user?.apiKeys);

      LocalStorage.saveKeysSharedPref(keys);

      pusher = await Pusher.init();
      userChannel = 'private-users.${user?.id}';
      await pusher?.unsubscribe(userChannel);
      Channel channel = pusher!.subscribe(userChannel);

      channel.bind('TopupEvent', (event) {
        final TopupController? topupController = Get.put(TopupController());
        if (topupController != null) {
          if (event != null && event.data!.isNotEmpty) {
            Map<String?, dynamic> data = jsonDecode(event.data!);
            if (data['qonversion_user_id'] ==
                topupController.qonversionUserID) {
              topupController.success();
            }
          }
        }
      });

      channel.bind('NewMessageEvent', (event) {
        if (event != null && event.data!.isNotEmpty) {
          Map<String, dynamic> data = json.decode(event.data!);
          ConversationsController conversationsController =
              Get.find<ConversationsController>();
          List<Rx<Conversations>> conversations =
              conversationsController.conversations;

          Rx<Conversations> controllerConversation = conversations[
              conversations.indexWhere((element) =>
                  element.value.id == data['message']['conversation_id'])];
          controllerConversation.value.recentMessage =
              RecentMessage.fromJson(data['message']);
          conversationsController.conversations.refresh();

          try {
            ConversationController? controller =
                Get.find<ConversationController>(
                    tag: 'conversation_${data['message']['conversation_id']}');
            controller.messages.add(data['message']);
            controller.messages.refresh();
          } catch (_) {}
          if (currentConversationId != data['message']['conversation_id']) {
            Get.find<ConversationsController>().newMessage++; // to fix
            // check user's notification settings
            if (Get.find<AuthController>().currentConversationId !=
                data['message']['conversation_id']) {
              notifier.notify(
                  'New message',
                  '${data['message']['user']['username']} has sent you a message.',
                  data);
            }
          }
        }
      });

      initFCM();
    }

    loading.value = false;
  }

  clearUserCache() async {
    await DefaultCacheManager().removeFile('alter_profile_key');
  }

  initFCM() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      ApiService().request('auth/firebase_token', {token: token}, 'PUT');
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('initialMessage');
      goToContentFromNotification(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage');
      if (message.data['type'] != 'conversation') {
        switch (message.data['type']) {
          case 'post_like':
            if (user?.settings?.postLike == '1') {
              notifier.notify(message.notification!.title!,
                  message.notification!.body!, message.data);
            }
            break;
          case 'post_comment':
            if (user?.settings?.postComment == '1') {
              notifier.notify(message.notification!.title!,
                  message.notification!.body!, message.data);
            }
            break;
          case 'post_unlock':
            if (user?.settings?.postUnlock == '1') {
              notifier.notify(message.notification!.title!,
                  message.notification!.body!, message.data);
            }
            break;
          case 'comment_like':
            if (user?.settings?.commentLike == '1') {
              notifier.notify(message.notification!.title!,
                  message.notification!.body!, message.data);
            }
            break;
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp');
      goToContentFromNotification(message);
    });
  }

  goToContentFromNotification(RemoteMessage message) async {
    switch (message.data['type']) {
      case 'post':
        Map<String, dynamic>? response = await ApiService().request(
            'posts/${message.data['data']['post']['slug']}', {}, 'GET',
            withToken: true);
        if (response != null) {
          Rx<Post> post = Post.fromJson(response).obs;
        }
        break;

      case 'conversation':
        Get.find<NavController>()
            .openConversation(message.data['data'], navigator!.context);

        break;
    }
  }
}
