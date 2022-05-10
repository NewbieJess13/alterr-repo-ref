import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/feed.dart';
import 'package:alterr/controllers/profile.dart';
import 'package:alterr/controllers/search.dart';
import 'package:get/get.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:flutter/material.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/conversation.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:alterr/controllers/auth.dart';

class NavController extends GetxController {
  RxInt screenIndex = 0.obs;
  List<String> pageKeys = [
    'Feed',
    'Search',
    'Empty',
    'Conversations',
    'Profile'
  ];
  Map<String, GlobalKey<NavigatorState>> navigatorKeys = {
    'Feed': GlobalKey<NavigatorState>(),
    'Search': GlobalKey<NavigatorState>(),
    'Empty': GlobalKey<NavigatorState>(),
    'Conversations': GlobalKey<NavigatorState>(),
    'Profile': GlobalKey<NavigatorState>(),
  };
  RxString currentPage = 'Feed'.obs;

  selectTab(key, index) {
    if (key == currentPage.value && navigatorKeys[key]?.currentState != null) {
      if (navigatorKeys[key]?.currentState?.canPop() == false) {
        switch (key) {
          case 'Feed':
            Get.find<FeedController>().scrollController.animateTo(0,
                duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
            break;

          case 'Search':
            Get.find<SearchController>().scrollController.animateTo(0,
                duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
            break;

          case 'Conversations':
            Get.find<ConversationsController>().scrollController.animateTo(0,
                duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
            break;

          case 'Profile':
            Get.find<ProfileController>(
                    tag: 'profile_${Get.find<AuthController>().user?.id}')
                .scrollController
                .animateTo(0,
                    duration: Duration(milliseconds: 350),
                    curve: Curves.easeInOut);
            break;
        }
      }
      navigatorKeys[key]
          ?.currentState
          ?.popUntil((route) => route.isFirst); // For android back button
    } else {
      currentPage.value = pageKeys[index];
      screenIndex.value = index;
      currentPage.refresh();
      screenIndex.refresh();
    }
  }

  openConversation(conversation, context) async {
    Get.find<AuthController>().currentConversationId =
        conversation['conversation_id'];
    await Navigator.of(context).push<void>(SwipeablePageRoute(
        builder: (_) => ConversationScreen(
              conversationID: conversation['conversation_id'],
              user: User.fromJson(conversation['user']),
            )));
    Get.find<AuthController>().currentConversationId = null;
  }
}
