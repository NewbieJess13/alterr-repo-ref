import 'dart:convert';
import 'dart:io';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/conversation.dart';
import 'package:alterr/forks/giphy_picker/lib/src/model/client/gif.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/utils/gif_picker.dart';
import 'package:alterr/utils/mediapicker.dart';
import 'package:alterr/utils/message_modal.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart' as VC;
import 'package:alterr/utils/camera.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationID;
  final User user;
  ConversationScreen(
      {Key? key, required this.conversationID, required this.user})
      : super(key: key);

  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  final FocusNode messageFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  RefreshController _refreshController = RefreshController();
  late ConversationController controller;
  late AuthController authController;
  Widget contentScreen = Container();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ConversationController(),
        tag: 'conversation_${widget.conversationID}');
    controller.conversationID = widget.conversationID;
    controller.getConversation();
    authController = Get.find<AuthController>();
    authController.currentConversationId = widget.conversationID;
  }

  @override
  void dispose() {
    scrollController.dispose();
    messageFocusNode.dispose();
    _refreshController.dispose();
    controller.page = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _conversationScreen(context);
  }

  _conversationScreen(BuildContext context) {
    final User? currentUser = authController.user;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          padding: EdgeInsets.only(left: 5, right: 15, bottom: 5.0),
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    splashRadius: 15.0,
                    color: Colors.black87,
                    icon: Transform.translate(
                      offset: Offset(0, -1),
                      child: Icon(FeatherIcons.arrowLeft),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => {
                        Navigator.of(context).push<void>(SwipeablePageRoute(
                            builder: (_) => ProfileScreen(
                                  user: widget.user,
                                  leading: true,
                                )))
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.user.profilePicture != null &&
                                    widget.user.profilePicture != ''
                                ? CachedNetworkImage(
                                    fadeInDuration: Duration(seconds: 0),
                                    placeholderFadeInDuration:
                                        Duration(seconds: 0),
                                    fadeOutDuration: Duration(seconds: 0),
                                    imageUrl: widget.user.profilePicture!,
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                            radius: 18,
                                            backgroundImage: imageProvider,
                                            backgroundColor: Colors.grey[200]),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                            radius: 18,
                                            backgroundImage: AssetImage(
                                                'assets/images/profile-placeholder.png')),
                                    placeholder: (context, string) => CircleAvatar(
                                        radius: 18,
                                        backgroundImage: AssetImage(
                                            'assets/images/profile-placeholder.png')),
                                  )
                                : CircleAvatar(
                                    radius: 18,
                                    backgroundImage: AssetImage(
                                        'assets/images/profile-placeholder.png')),
                            const SizedBox(height: 5),
                            Text(widget.user.username,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ]),
                    ))
              ],
            ),
          ),
        ),
      ),
      body: Container(child: Obx(() {
        return controller.loading.value == true
            ? Center(
                child: PlatformSpinner(
                  width: 20,
                  height: 20,
                ),
              )
            : controller.messages.length == 0
                ? Center(
                    child: Text('No messages yet',
                        style: TextStyle(color: Colors.black26, fontSize: 17)))
                : Scrollbar(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: false,
                        enablePullUp: true,
                        onLoading: () async {
                          await controller.loadOlderMessages();
                          _refreshController.loadComplete();
                        },
                        child: ListView.builder(
                            reverse: true,
                            controller: scrollController,
                            itemCount: controller.messages.length,
                            itemBuilder: (context, index) {
                              final reversedIndex =
                                  controller.messages.length - 1 - index;
                              final Map<String, dynamic> message =
                                  controller.messages[reversedIndex];
                              bool nextSenderIsMe = false;
                              bool previousSenderIsMe = false;
                              bool lastMessage = false;
                              int nextIndex = reversedIndex + 1;
                              int previousIndex = reversedIndex - 1;
                              if (nextIndex < controller.messages.length) {
                                nextSenderIsMe = controller.messages[nextIndex]
                                        ['user_id'] ==
                                    currentUser?.id;
                              } else {
                                lastMessage = true;
                              }

                              if (previousIndex >= 0) {
                                previousSenderIsMe = controller
                                        .messages[previousIndex]['user_id'] ==
                                    currentUser?.id;
                              }
                              return Container(
                                padding: EdgeInsets.only(
                                    top: reversedIndex == 0 ? 15.0 : 0),
                                child: ChatBubble(
                                  controller: controller,
                                  authController: authController,
                                  message: message,
                                  isMe: message['user_id'] == currentUser?.id,
                                  nextSenderIsMe: nextSenderIsMe,
                                  lastMessage: lastMessage,
                                  previousSenderIsMe: previousSenderIsMe,
                                  goToPostMessage: message['type'] == 'post'
                                      ? () {
                                          Rx<Post> post =
                                              Post.fromJson(message['post'])
                                                  .obs;
                                          Navigator.of(context)
                                              .push<void>(SwipeablePageRoute(
                                                  builder: (_) => PostScreen(
                                                        post: post,
                                                      )));
                                        }
                                      : null,
                                ),
                              );
                            }),
                      ),
                    ),
                  );
      })),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          elevation: 0,
          child: GestureDetector(
            onTap: () => {messageFocusNode.requestFocus()},
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.05)))),
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black12.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              cursorColor: Colors.black,
                              cursorWidth: 1,
                              controller: controller.message,
                              textInputAction: TextInputAction.send,
                              onEditingComplete: () {
                                messageFocusNode.requestFocus();
                                controller.sendMessage(scrollController);
                                controller.messageData['message'] = '';
                                controller.message.clear();
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.all(15.0),
                                hintText: 'Write your message..',
                                hintStyle: TextStyle(
                                    fontSize: 16, color: Colors.black26),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                              ),
                              autofocus: true,
                              focusNode: messageFocusNode,
                              onChanged: (value) => {
                                controller.messageData['message'] =
                                    value.toString().trim()
                              },
                            ),
                            Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    if (controller
                                            .messageData['message'].length >
                                        0) {
                                      controller.sendMessage(scrollController);
                                      controller.messageData['message'] = '';
                                      controller.message.clear();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0,
                                            color: Colors.transparent)),
                                    height: 48,
                                    width: 35,
                                    child: Transform.rotate(
                                      angle: 44.8,
                                      child: Icon(
                                        FeatherIcons.send,
                                        size: 20,
                                        color: controller.messageData['message']
                                                    .length >
                                                0
                                            ? Theme.of(context).primaryColor
                                            : Colors.black26,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 7.5),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                customBorder: CircleBorder(),
                                onTap: () {
                                  pickCamera();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(0, -1),
                                    child: Icon(
                                      FeatherIcons.camera,
                                      color: Theme.of(context).primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 7.5,
                            ),
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                customBorder: CircleBorder(),
                                onTap: () async {
                                  AssetEntity? asset =
                                      await Mediapicker.pick(context);
                                  if (asset != null) {
                                    sendAssetMessage(asset);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(0, -1),
                                    child: Icon(
                                      FeatherIcons.image,
                                      color: Theme.of(context).primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 7.5,
                            ),
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                customBorder: CircleBorder(),
                                onTap: () async {
                                  GiphyGif? selectedGif =
                                      await GifPicker.pick(context);
                                  if (selectedGif != null) {
                                    sendGif(selectedGif);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Transform.scale(
                                    scale: 2,
                                    child: Icon(
                                      Icons.gif_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  pickCamera() async {
    PickedFile? pickedFile = await Camera.pick();

    if (pickedFile != null) {
      String? mimeStr = lookupMimeType(pickedFile.path);
      String fileType = mimeStr!.split('/')[0];
      fileType = fileType == 'image' ? 'photo' : fileType;

      if (fileType == 'video') {
        List durationParts =
            pickedFile.duration.toString().substring(2, 7).split(':');
        Duration totalDuration = Duration(
          minutes: int.parse(durationParts[0]),
          seconds: int.parse(durationParts[1]),
        );
        if (totalDuration.inMinutes > 3) {
          PlatformAlertDialog(
            title: 'Error',
            content: 'Your selected video exceeds the 3 minutes duration.',
            actions: [
              PlatformAlertDialogAction(
                child: Text('OK'),
                isDefaultAction: true,
                onPressed: () => navigator?.pop(),
              )
            ],
          ).show();
          return;
        }
      }

      controller.messageData['type'] = fileType;
      controller.messageData['source'] = pickedFile.path;

      if (fileType == 'photo') {
        Directory tempDir = await getTemporaryDirectory();
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        String thumbnailTmpPath = '${tempDir.path}/$timestamp-thumbnail.jpg';
        File? messageThumbnail = await FlutterImageCompress.compressAndGetFile(
            pickedFile.path, thumbnailTmpPath,
            autoCorrectionAngle: true,
            quality: 25,
            minWidth: 750,
            keepExif: true);
        controller.messageData['thumbnail'] = messageThumbnail?.path;
      } else if (fileType == 'video') {
        File messageThumbnail = await VC.VideoCompress.getFileThumbnail(
          pickedFile.path,
          quality: 75,
        );
        controller.messageData['thumbnail'] = messageThumbnail.path;
        controller.messageData['metadata']['duration'] =
            pickedFile.duration.toString().substring(2, 7);
      }
      controller.sendMessage(scrollController);
    }
  }

  sendGif(GiphyGif gif) {
    controller.messageData.value = {
      "thumbnail": gif.images?.fixedHeightSmall?.url,
      "source": gif.images?.original?.url,
      "preview": gif.images?.downsizedStill?.url,
      "type": 'gif',
      "message": '',
    };
    controller.sendMessage(scrollController);
  }

  sendAssetMessage(asset) async {
    if (asset != null) {
      File pickedFile = await asset.file;
      if (asset.type != AssetType.video && asset.type != AssetType.image) {
        return;
      }

      if (asset.type == AssetType.video) {
        List durationParts =
            asset.videoDuration.toString().substring(2, 7).split(':');

        Duration totalDuration = Duration(
          minutes: int.parse(durationParts[0]),
          seconds: int.parse(durationParts[1]),
        );
        if (totalDuration.inMinutes > 3) {
          PlatformAlertDialog(
            title: 'Error',
            content: 'Your selected video exceeds the 3 minutes duration.',
            actions: [
              PlatformAlertDialogAction(
                child: Text('OK'),
                isDefaultAction: true,
                onPressed: () => navigator?.pop(),
              )
            ],
          ).show();
          return;
        }
      }

      if (asset.type == AssetType.video) {
        controller.messageData['type'] = 'video';
        controller.messageData['metadata'] = {
          'duration': asset.videoDuration.toString().substring(2, 7)
        };
      } else if (asset.type == AssetType.image) {
        controller.messageData['type'] = 'photo';
      }

      Directory tempDir = await getTemporaryDirectory();
      File tempThumbnail =
          File(tempDir.path + '/' + Helpers.randomString() + '.png');
      tempThumbnail.writeAsBytesSync(
          await asset.thumbDataWithSize(750, 750, quality: 75));
      controller.messageData['thumbnail'] = tempThumbnail.path;
      controller.messageData['source'] = pickedFile.path;
      controller.sendMessage(scrollController);
    }
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final bool previousSenderIsMe;
  final bool nextSenderIsMe;
  final bool lastMessage;
  final VoidCallback? goToPostMessage;
  final double? progress;
  final ConversationController controller;
  final AuthController authController;
  const ChatBubble(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.nextSenderIsMe,
      required this.previousSenderIsMe,
      required this.lastMessage,
      this.goToPostMessage,
      this.progress,
      required this.controller,
      required this.authController})
      : super(key: key);
  // final
  @override
  Widget build(BuildContext context) {
    final bool isEmoji = Helpers.isEmoji(message['message']);
    final bool isDeleted = message['deleted_at'] != null;
    if (isDeleted == true) {
      message['message'] = 'Message deleted';
      message['type'] = 'text';
      message['link_preview'] = null;
    }

    BorderRadius? borderRadius = isMe
        ? BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight:
                nextSenderIsMe ? Radius.circular(3) : Radius.circular(25),
            topLeft: Radius.circular(25),
            topRight:
                previousSenderIsMe ? Radius.circular(3) : Radius.circular(25),
          )
        : BorderRadius.only(
            bottomLeft: lastMessage
                ? Radius.circular(25)
                : nextSenderIsMe == false
                    ? Radius.circular(3)
                    : Radius.circular(25),
            bottomRight: Radius.circular(25),
            topRight: Radius.circular(25),
            topLeft: previousSenderIsMe == false
                ? Radius.circular(3)
                : Radius.circular(25),
          );
    return AbsorbPointer(
      absorbing: isDeleted || message['pending'] == true,
      child: Opacity(
        opacity: isDeleted || message['pending'] == true ? 0.5 : 1,
        child: Container(
          margin: isMe
              ? EdgeInsets.only(
                  right: 5,
                  bottom: nextSenderIsMe ? 2 : 15,
                )
              : EdgeInsets.only(
                  left: 5,
                  bottom: lastMessage
                      ? 15
                      : nextSenderIsMe
                          ? 15
                          : 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: PhysicalModel(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      borderRadius: borderRadius,
                      child: Material(
                        color: Colors.white,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: message['type'] == 'text'
                                ? isEmoji
                                    ? Colors.transparent
                                    : isMe
                                        ? Theme.of(context).primaryColor
                                        : const Color(0xFFedeff5)
                                : const Color(0xFFedeff5),
                            borderRadius: borderRadius,
                          ),
                          child: InkWell(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              messageActions(context, message);
                            },
                            customBorder: RoundedRectangleBorder(
                                borderRadius: borderRadius),
                            onTap: () => {},
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 260),
                              padding: message['type'] == 'text'
                                  ? isEmoji
                                      ? const EdgeInsets.all(0)
                                      : message['link_preview'] != null
                                          ? const EdgeInsets.all(0)
                                          : const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10)
                                  : null,
                              child: messageCard(
                                message,
                                context,
                                isEmoji,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              lastMessage && isMe && message['is_read'] == true
                  ? Icon(FeatherIcons.eye, size: 13)
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageCard(
      Map<String, dynamic> message, BuildContext context, bool isEmoji) {
    if (message['type'] == 'text') {
      if (message['link_preview'] != null) {
        Map<String, dynamic> linkPreview = {};
        if (message['link_preview'] is String) {
          linkPreview = jsonDecode(message['link_preview']);
        } else {
          linkPreview = message['link_preview'];
        }
        final uri = Uri.parse(linkPreview['url']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Linkify(
                text: message['message'],
                options: LinkifyOptions(humanize: false),
                onOpen: (link) => _launchURL(link.url),
                linkStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isMe ? Colors.white : Colors.black),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isMe ? Colors.white : Colors.black),
              ),
            ),
            GestureDetector(
              onTap: () => {_launchURL(linkPreview['url'])},
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: linkPreview['image'],
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(seconds: 0),
                    fadeOutDuration: Duration(seconds: 0),
                    errorWidget: (context, error, _) {
                      return Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text('Failed to load image.',
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54)),
                      );
                    },
                    placeholder: (context, url) {
                      return Center(
                        child: PlatformSpinner(),
                      );
                    },
                  ),
                  Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          linkPreview['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          uri.host,
                          style:
                              TextStyle(fontSize: 13.5, color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }
      return Text(
        message['message'],
        style: TextStyle(
          fontSize: isEmoji ? 60 : 16,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: isMe ? Colors.white : Colors.black87,
        ),
      );
    } else if (message['type'] == 'photo' || message['type'] == 'video') {
      Map<String, dynamic>? metadata;
      if (message['metadata'] is String) {
        metadata = jsonDecode(message['metadata']);
      } else {
        metadata = message['metadata'];
      }
      Widget heroImage = message['thumbnail'] != null
          ? Stack(
              children: [
                message['preview'] != null
                    ? Image.file(message['preview'])
                    : SizedBox.shrink(),
                message['thumbnail'] is String
                    ? CachedNetworkImage(
                        imageUrl: message['thumbnail'],
                        fadeInDuration: Duration(seconds: 0),
                        placeholderFadeInDuration: Duration(seconds: 0),
                        fadeOutDuration: Duration(seconds: 0),
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      message['thumbnail']))),
                          child: CachedNetworkImage(
                            imageUrl: message['thumbnail'],
                            fadeInDuration: Duration(seconds: 0),
                            placeholderFadeInDuration: Duration(seconds: 0),
                            fadeOutDuration: Duration(seconds: 0),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        width: double.infinity,
                        errorWidget: (context, error, _) {
                          return Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: Text(
                              'Failed to load content.',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          );
                        },
                      )
                    : SizedBox.shrink(),
                message['type'] == 'video'
                    ? Positioned.fill(
                        child: Center(
                        child: Container(
                          padding: EdgeInsets.all(7.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(50.0)),
                          child: Transform.translate(
                            offset: Offset(1, 0),
                            child: Icon(
                              FeatherIcons.play,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ))
                    : SizedBox.shrink(),
                message['type'] == 'video' && metadata != null
                    ? Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5)),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          child: Text(
                            metadata['duration'],
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.0),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            )
          : Container();

      return message['thumbnail'] != '' && message['thumbnail'] != null
          ? GestureDetector(
              onTap: () async {
                openMessageMedia(context,
                    tag: 'message_${message['id'] ?? message['timestamp']}');
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'message_${message['id'] ?? message['timestamp']}',
                    child: heroImage,
                    placeholderBuilder: (context, size, widget) {
                      return heroImage;
                    },
                  ),
                ],
              ),
            )
          : Text('Can\'t load media',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : Colors.black87,
              ));
    } else if (message['type'] == 'gif') {
      Widget heroImage = Stack(
        children: [
          message['preview'] != null
              ? Image.network(message['preview'])
              : SizedBox.shrink(),
          CachedNetworkImage(
            imageUrl: message['source'],
            fadeInDuration: Duration(seconds: 0),
            placeholderFadeInDuration: Duration(seconds: 0),
            fadeOutDuration: Duration(seconds: 0),
            placeholder: (context, url) {
              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            CachedNetworkImageProvider(message['thumbnail']))),
                child: CachedNetworkImage(
                  imageUrl: message['thumbnail'],
                  fadeInDuration: Duration(seconds: 0),
                  placeholderFadeInDuration: Duration(seconds: 0),
                  fadeOutDuration: Duration(seconds: 0),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
            fit: BoxFit.cover,
            width: double.infinity,
            errorWidget: (context, error, _) {
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Text('Failed to load content.',
                    style: TextStyle(fontSize: 15, color: Colors.black54)),
              );
            },
          )
        ],
      );

      return message['thumbnail'] != '' && message['thumbnail'] != null
          ? GestureDetector(
              onTap: () {
                String id;
                if (message.containsKey('timestamp')) {
                  id = message['timestamp'].toString();
                } else {
                  id = message['id'].toString();
                }

                openMessageMedia(context, tag: 'message_$id');
              },
              child: ClipRRect(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'message_${message['id'] ?? message['timestamp']}',
                      child: heroImage,
                      placeholderBuilder: (context, size, widget) {
                        return heroImage;
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Opacity(
                        opacity: 0.35,
                        child: Image.asset(
                          'assets/images/giphy.png',
                          height: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : Text('Can\'t load media',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : Colors.black87,
              ));
    } else if (message['type'] == 'post') {
      if (message['post'] != null) {
        Post post = Post.fromJson(message['post']);
        return GestureDetector(
          onTap: goToPostMessage,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                post.type == 'photo' || post.type == 'video'
                    ? CachedNetworkImage(
                        imageUrl: post.thumbnail!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover)
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            height: 1.2,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.user.username,
                        style: TextStyle(fontSize: 13.5, color: Colors.black45),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
    return Container(
      child: Container(),
    );
  }

  void openMessageMedia(context, {required String tag}) {
    MessageModal(message: message).open(context, tag: tag);
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  void messageActions(BuildContext context, Map<String, dynamic> message) {
    List<Widget> options = [];

    // Copy message
    if (message['type'] == 'text') {
      options.add(InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: message['message']));
          navigator?.pop();
        },
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Copy message',
                style: TextStyle(fontSize: 17, height: 1),
              ),
              Icon(
                FeatherIcons.copy,
                size: 20,
              ),
            ],
          ),
        ),
      ));
    }

    // Delete message
    if (authController.user?.id == message['user_id']) {
      options.add(
        InkWell(
          onTap: () {
            navigator?.pop();
            PlatformAlertDialog(
              title: 'Delete message',
              content:
                  'This message will be deleted from this conversation. Everyone in this conversation will not be able to see it anymore.',
              actions: [
                PlatformAlertDialogAction(
                  child: Text('Cancel'),
                  isDefaultAction: true,
                  onPressed: () => navigator?.pop(),
                ),
                PlatformAlertDialogAction(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    navigator?.pop();
                    controller.deleteMessage(message['id']);
                  },
                ),
              ],
            ).show();
          },
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.05)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete',
                  style: TextStyle(fontSize: 17, height: 1, color: Colors.red),
                ),
                Icon(
                  FeatherIcons.trash,
                  color: Colors.red,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget content = Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options,
      ),
    );

    PlatformBottomsheetModal(
        context: context,
        child: SafeArea(
          top: false,
          child: content,
        )).show();
  }
}
