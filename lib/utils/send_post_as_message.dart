import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/conversation.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/conversations.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/services/api.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xml_parser/xml_parser.dart';

class SendPostAsMessage {
  final Post post;

  SendPostAsMessage({required this.post});

  showModalBottomSheet(context) async {
    ConversationsController controller = Get.find<ConversationsController>();
    List<XmlNode> parsedCaption = Helpers.parseCaption(post.caption);
    return await PlatformBottomsheetModal(
      context: context,
      child: SafeArea(
        top: false,
        child: Container(
            height: MediaQuery.of(context).size.height * 0.60,
            child: Scaffold(
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Send to',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          InkWell(
                            onTap: () => {navigator?.pop()},
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(7.5)),
                          child: Row(
                            children: [
                              post.type == 'photo' || post.type == 'video'
                                  ? CachedNetworkImage(
                                      imageUrl: post.isSensitive
                                          ? post.preview!
                                          : post.thumbnail!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Color(
                                              int.parse('0xff${post.color}')),
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      errorWidget: (context, error, _) {
                                        return Container(
                                          color: Color(
                                              int.parse('0xff${post.color}')),
                                          height: 40,
                                          width: 40,
                                        );
                                      },
                                    )
                                  : SizedBox.shrink(),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Colors.black),
                                              children: List.generate(
                                                  parsedCaption.length,
                                                  (index) {
                                                if (parsedCaption[index]
                                                    is XmlElement) {
                                                  XmlElement userNode =
                                                      parsedCaption[index]
                                                          as XmlElement;
                                                  return TextSpan(children: [
                                                    WidgetSpan(
                                                      child:
                                                          Transform.translate(
                                                        offset: Offset(0, 1),
                                                        child: Text(
                                                          userNode.text!,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              height: 1.2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Helvetica Neue',
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                    ),
                                                    TextSpan(text: ' '),
                                                  ]);
                                                } else {
                                                  XmlText xmlText =
                                                      parsedCaption[index]
                                                          as XmlText;
                                                  return TextSpan(
                                                      text: xmlText.value,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          height: 1.2,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Helvetica Neue'),
                                                      children: [
                                                        TextSpan(text: ' ')
                                                      ]);
                                                }
                                              }))),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        post.user.username,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black45),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: controller.conversations.length > 0
                          ? ListView.builder(
                              padding: const EdgeInsets.only(top: 2),
                              itemCount: controller.conversations.length,
                              itemBuilder: (context, index) {
                                Conversations conversation =
                                    controller.conversations[index].value;
                                return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15.0),
                                    child: Row(
                                      children: [
                                        conversation.user.profilePicture !=
                                                    null &&
                                                conversation
                                                        .user.profilePicture !=
                                                    ''
                                            ? CachedNetworkImage(
                                                fadeInDuration:
                                                    Duration(seconds: 0),
                                                placeholderFadeInDuration:
                                                    Duration(seconds: 0),
                                                fadeOutDuration:
                                                    Duration(seconds: 0),
                                                imageUrl: conversation
                                                    .user.profilePicture!,
                                                imageBuilder: (context,
                                                        imageProvider) =>
                                                    CircleAvatar(
                                                        radius: 18,
                                                        backgroundImage:
                                                            imageProvider,
                                                        backgroundColor:
                                                            Colors.grey[200]),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    CircleAvatar(
                                                        radius: 18,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/profile-placeholder.png')),
                                                placeholder: (context,
                                                        string) =>
                                                    CircleAvatar(
                                                        radius: 18,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/profile-placeholder.png')),
                                              )
                                            : CircleAvatar(
                                                radius: 18,
                                                backgroundImage: AssetImage(
                                                    'assets/images/profile-placeholder.png')),
                                        const SizedBox(width: 8),
                                        Text(
                                          conversation.user.username,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.5),
                                        ),
                                        Spacer(),
                                        Obx(() => Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          7.5)),
                                              child: GestureDetector(
                                                onTap: conversation.sendText ==
                                                        'Send'
                                                    ? () => _sendAsMessage(
                                                        controller, index, post)
                                                    : null,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 10),
                                                  child: Text(
                                                    controller
                                                        .conversations[index]
                                                        .value
                                                        .sendText,
                                                    style: TextStyle(
                                                        fontSize: 15.5,
                                                        color: conversation
                                                                    .sendText ==
                                                                'Send'
                                                            ? Colors.black
                                                            : Colors.black26,
                                                        height: 1.1),
                                                  ),
                                                ),
                                              ),
                                            ))
                                      ],
                                    ));
                              })
                          : Center(
                              child: Text(
                              'No conversations yet',
                              style: TextStyle(
                                  color: Colors.black26, fontSize: 17),
                            )),
                    )
                  ]),
            )),
      ),
    ).show();
  }

  void _sendAsMessage(
      ConversationsController controller, int index, Post post) async {
    Conversations conversation = controller.conversations[index].value;
    if (conversation.sendText == 'Send') {
      controller.conversations[index].value.sendText = 'Sending';
      controller.conversations[index].refresh();
      Map<String, dynamic> postMessage = {
        'post_slug': post.slug,
        'type': 'post',
        'message': '',
        'conversation_id': conversation.id,
      };
      Map<String, dynamic>? response = await ApiService()
          .request('conversations/messages', postMessage, 'POST',
              withToken: true)
          .catchError((_) {});
      if (response != null) {
        controller.conversations[index].value.sendText = 'Sent';
        controller.conversations[index].refresh();
        controller.conversations[index].value.recentMessage =
            RecentMessage.fromJson(response);
        controller.conversations.refresh();

        ConversationController? conversationController = Get.put(
            ConversationController(),
            tag: 'conversation_${conversation.id}');
        if (conversationController != null) {
          conversationController.conversationID = conversation.id;
          conversationController.messages.add(response);
          conversationController.messages.refresh();
        }

        await Future.delayed(Duration(seconds: 2));
      }

      controller.conversations[index].value.sendText = 'Send';
      controller.conversations[index].refresh();
    }
  }
}
