import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/models/conversations.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/screens/conversation.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

// ignore: must_be_immutable
class ConversationsScreen extends StatelessWidget {
  final ConversationsController controller = Get.put(ConversationsController());
  Widget contentScreen = Container();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return _conversations(context);
  }

  Widget _conversations(context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Messages').build(),
      body: Obx(() => SmartRefresher(
          scrollController: controller.scrollController,
          primary: false,
          onRefresh: () async {
            AssetsAudioPlayer.newPlayer().open(
              Audio("assets/sounds/refresh.mp3"),
            );
            HapticFeedback.mediumImpact();
            await controller.refreshConversations();
            _refreshController.refreshCompleted();
          },
          enablePullDown: true,
          enablePullUp: false,
          onLoading: () async {
            await controller.loadMoreConversations();
            _refreshController.loadComplete();
          },
          controller: _refreshController,
          child: controller.conversations.length == 0
              ? Center(
                  child: Text(
                  'No conversations yet',
                  style: TextStyle(color: Colors.black26, fontSize: 17),
                ))
              : _list())),
    );
  }

  Widget _list() {
    List<Rx<Conversations>> sortedConversations = controller.conversations;
    sortedConversations
        .where((i) => i.value.recentMessage != null)
        .toList()
        .sort((a, b) => b.value.recentMessage!.createdAt
            .compareTo(a.value.recentMessage!.createdAt));
    return ListView.builder(
      itemCount: sortedConversations.length,
      itemBuilder: (context, index) {
        final Conversations conversations = sortedConversations[index].value;

        if (conversations.recentMessage == null) {
          return Container();
        }

        return ChatTile(
          message: conversations,
          isSeen: conversations.recentMessage != null
              ? conversations.recentMessage!.isSeen
              : false,
          onTap: () async {
            Get.find<AuthController>().currentConversationId = conversations.id;
            await Navigator.of(context).push<void>(SwipeablePageRoute(
                builder: (_) => ConversationScreen(
                      conversationID: conversations.id,
                      user: conversations.user,
                    )));
            Get.find<AuthController>().currentConversationId = null;
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            controller.selectedConversationId = conversations.id;
            _showConversationActions(context);
          },
        );
      },
    );
  }

  _showConversationActions(BuildContext context) {
    List<Widget> options = [];
    options = [
      InkWell(
        onTap: () {
          navigator?.pop();
          PlatformAlertDialog(
            title: 'Leave conversation',
            content: 'Are you sure you want to leave from this conversation?',
            actions: [
              PlatformAlertDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () => navigator?.pop(),
              ),
              PlatformAlertDialogAction(
                child: Text(
                  'Leave',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  navigator?.pop();
                  controller.deleteConversation();
                },
              )
            ],
          ).show();
        },
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leave conversation',
                style: TextStyle(fontSize: 17, height: 1),
              ),
              Icon(
                FeatherIcons.logOut,
                size: 20,
              ),
            ],
          ),
        ),
      ),
      // InkWell(
      //   onTap: () => {},
      //   child: Container(
      //     padding: EdgeInsets.all(15.0),
      //     decoration: BoxDecoration(
      //         border: Border(
      //             bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
      //     child: Row(
      //       children: [
      //         Icon(
      //           FeatherIcons.archive,
      //           size: 22,
      //         ),
      //         SizedBox(
      //           width: 12,
      //         ),
      //         Text(
      //           'Archive',
      //           style: TextStyle(fontSize: 17, height: 1),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
      // InkWell(
      //   onTap: () => {},
      //   child: Container(
      //     padding: EdgeInsets.all(15.0),
      //     decoration: BoxDecoration(
      //         border: Border(
      //             bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
      //     child: Row(
      //       children: [
      //         Icon(
      //           FeatherIcons.bellOff,
      //           size: 22,
      //         ),
      //         SizedBox(
      //           width: 12,
      //         ),
      //         Text(
      //           'Mute Notifications',
      //           style: TextStyle(fontSize: 17, height: 1),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    ];

    Widget content = Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options,
      ),
    );
    PlatformBottomsheetModal(
            child: SafeArea(
              top: false,
              child: content,
            ),
            context: context)
        .show();
  }
}

class ChatTile extends StatelessWidget {
  final Conversations message;
  final bool isSeen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const ChatTile(
      {Key? key,
      required this.isSeen,
      required this.onTap,
      required this.message,
      required this.onLongPress})
      : super(key: key);

  String get recentMessageTitle {
    if (message.recentMessage!.message == null ||
        message.recentMessage!.message == '') {
      if (message.recentMessage!.type == 'photo') {
        return 'Sent a photo';
      } else if (message.recentMessage!.type == 'video') {
        return 'Sent a video';
      } else if (message.recentMessage!.type == 'post') {
        return 'Sent an attachment';
      } else if (message.recentMessage!.type == 'gif') {
        return 'GIF';
      }
    } else {
      return message.recentMessage!.message;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = Get.find<AuthController>().user;
    String recentMessage = recentMessageTitle;
    if (message.recentMessage!.deletedAt != null) {
      recentMessage = 'Message deleted';
    }

    if (message.recentMessage!.user['username'] == currentUser?.username) {
      recentMessage = 'You: $recentMessage';
    }
    var fromNow = timeago
        .format(DateTime.parse(message.recentMessage!.createdAt),
            locale: 'en_short')
        .replaceAll('~', '');
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePicture(
              source: message.user.profilePicture,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          message.user.username,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        Spacer(),
                        Text(
                          fromNow,
                          style: TextStyle(fontSize: 15, color: Colors.black45),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      recentMessage,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        height: 1.1,
                        fontWeight: message.recentMessage!.user['username'] ==
                                currentUser?.username
                            ? FontWeight.normal
                            : message.recentMessage!.isSeen == true
                                ? FontWeight.normal
                                : FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
