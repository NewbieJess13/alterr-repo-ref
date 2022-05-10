import 'package:alterr/models/conversations.dart';
import 'package:alterr/services/api.dart';
import 'package:get/get.dart';
import 'package:alterr/controllers/auth.dart';
import 'package:flutter/widgets.dart';

class ConversationsController extends GetxController {
  RxList<Rx<Conversations>> conversations = <Rx<Conversations>>[].obs;
  late String? nextPageUrl;
  RxInt newMessage = 0.obs;
  int page = 1;
  late int selectedConversationId;
  ScrollController scrollController = ScrollController();

  getConversations({bool clear = true}) async {
    Map<String, dynamic>? responseData = await ApiService()
        .request('conversations?page=$page', {}, 'GET', withToken: true);
    if (clear) {
      conversations.clear();
    }
    if (responseData != null && responseData['data'] != null) {
      for (Map<String, dynamic> conversation in responseData['data']) {
        conversations.add(Conversations.fromJson(conversation).obs);
      }
      nextPageUrl = responseData['next_page_url'];
    }
    conversations.refresh();
    countUnreadMessages();
  }

  Future deleteConversation() async {
    int selectedIndex = conversations
        .indexWhere((element) => element.value.id == selectedConversationId);
    if (selectedIndex >= 0) {
      conversations.removeAt(selectedIndex);
    }
    await ApiService()
        .request('conversations/leave',
            {'conversation_id': selectedConversationId}, 'PUT',
            withToken: true)
        .then((value) {});
  }

  countUnreadMessages() {
    newMessage.value = 0;
    if (conversations.length > 0) {
      for (Rx<Conversations> conversation in conversations) {
        if (conversation.value.recentMessage?.isSeen == false &&
            conversation.value.recentMessage?.user['username'] !=
                Get.find<AuthController>().user?.username) {
          newMessage.value++;
        }
      }
    }
  }

  Future refreshConversations() async {
    page = 1;
    await getConversations();
  }

  Future loadMoreConversations() async {
    if (nextPageUrl != null) {
      Uri uri = Uri.dataFromString(nextPageUrl!);
      String? olderConversationsPage = uri.queryParameters['page'];
      if (olderConversationsPage != null) {
        page = int.parse(olderConversationsPage);
        await getConversations(clear: false);
      }
    }
  }
}
