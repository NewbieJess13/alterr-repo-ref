import 'dart:convert';
import 'dart:io';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/utils/s3.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/models/conversations.dart';
import 'package:alterr/models/conversation.dart';
import 'package:alterr/services/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';

class ConversationController extends GetxController {
  Rx<Conversation> conversation = Conversation().obs;
  TextEditingController message = TextEditingController();
  RxBool postPage = false.obs;
  RxMap<String, dynamic> messageData = {
    'thumbnail': null,
    'source': null,
    'type': 'text',
    'message': '',
    'metadata': {}
  }.obs;
  RxMap<String, bool> showActions = {
    'showEmojis': false,
  }.obs;
  RxList<dynamic> messages = [].obs;
  RxBool loading = false.obs;
  String? nextPageUrl;
  int page = 1;
  late int conversationID;

  getConversation({bool clear = true}) async {
    if (messages.length == 0) {
      loading.value = true;
      loading.refresh();
    }
    Map<String, dynamic>? responseData = await ApiService().request(
        'conversations/$conversationID?page=$page', {}, 'GET',
        withToken: true);
    if (clear) {
      messages.clear();
    }
    if (responseData != null) {
      if (responseData['messages']['data'] != null &&
          responseData['messages']['data'].length > 0) {
        conversation.value = Conversation.fromJson(responseData);
        messages.insertAll(0, conversation.value.messages);
        nextPageUrl = responseData['messages']['next_page_url'];
      }
      loading.value = false;
      loading.refresh();
      Get.find<ConversationsController>().countUnreadMessages();
      await readConversation();
    }
  }

  Future loadOlderMessages() async {
    if (nextPageUrl != null) {
      Uri uri = Uri.dataFromString(nextPageUrl!);
      String? olderMessagesPage = uri.queryParameters['page'];
      if (olderMessagesPage != null) {
        page = int.parse(olderMessagesPage);
        await getConversation(clear: false);
      }
    }
  }

  sendMessage(scrollController) async {
    if (messageData['type'] == 'text' &&
        messageData['message'].trim().length == 0) {
      return;
    }
    bool hasProgress = true;
    messageData['conversation_id'] = conversationID;
    User? user = Get.find<AuthController>().user;
    messageData['user_id'] = user?.id;
    if (messageData['type'] == 'text') {
      hasProgress = false;
      messageData.remove('metadata');
    }
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    messageData['timestamp'] = timestamp;

    Map<String, dynamic> pendingMessageData =
        jsonDecode(jsonEncode(messageData));
    if (pendingMessageData['type'] == 'photo' ||
        pendingMessageData['type'] == 'video') {
      pendingMessageData['source'] = File(pendingMessageData['source']);
      pendingMessageData['thumbnail'] =
          pendingMessageData['preview'] = File(pendingMessageData['thumbnail']);
    }
    if (messageData['type'] != 'text') {
      pendingMessageData['pending'] = true;
    }

    if (hasProgress) {
      PaletteGenerator? paletteGenerator;
      if (pendingMessageData['type'] == 'photo' ||
          pendingMessageData['type'] == 'video') {
        paletteGenerator = await PaletteGenerator.fromImageProvider(
            Image.file(File(messageData['thumbnail'])).image);
      } else if (pendingMessageData['type'] == 'gif') {
        paletteGenerator = await PaletteGenerator.fromImageProvider(
            Image.network(messageData['thumbnail']).image);
      }
      pendingMessageData['color'] = messageData['color'] = paletteGenerator!
          .dominantColor?.color.value
          .toRadixString(16)
          .substring(2);
    }

    messages.add(pendingMessageData);
    messages.refresh();

    Map<String, dynamic> data = jsonDecode(jsonEncode(messageData));
    goToMaxScroll(scrollController);

    if (hasProgress) {
      messageData['message'] = '';
      if (messageData['type'] == 'video') {
        await compressPostVideo();
      } else if (messageData['type'] == 'photo') {
        await generateMessageImages();
      }
    }

    if (hasProgress) {
      if (messageData['type'] != 'gif') {
        /* Upload to S3 */
        String randomString = Helpers.randomString();
        String sourceName = Helpers.randomString();
        String thumbnailName = Helpers.randomString();
        String s3Path = 'messages/$randomString-$timestamp';

        // upload source
        String sourcePath = await S3.uploadFile(
          s3Path,
          {
            'file': messageData['source'],
            'filename': messageData['type'] == 'video'
                ? '$sourceName.mp4'
                : '$sourceName.jpg'
          },
        );
        data['source'] = sourcePath;
        pendingMessageData['source'] = sourcePath;
        messages.refresh();

        // upload thumbnail
        String thumbnailPath = await S3.uploadFile(
          s3Path,
          {'file': messageData['thumbnail'], 'filename': '$thumbnailName.jpg'},
        );
        data['thumbnail'] = thumbnailPath;
        pendingMessageData['thumbnail'] = thumbnailPath;
        messages.refresh();

        File(messageData['source']?.path).delete();
        File(messageData['thumbnail']?.path).delete();

        data['metadata'] = jsonEncode(data['metadata']);
      } else {
        data.remove('metadata');
      }
    }

    Map<String, dynamic>? response = await ApiService().request(
      'conversations/messages',
      data,
      'POST',
      withToken: true,
    );
    if (response != null) {
      pendingMessageData['pending'] = false;
      pendingMessageData = response;
      messages.refresh();

      List<Rx<Conversations>> conversations =
          Get.find<ConversationsController>().conversations;
      int conversationsIndex = conversations
          .indexWhere((element) => element.value.id == conversationID);
      ConversationsController conversationsController =
          Get.find<ConversationsController>();

      conversationsController.conversations[conversationsIndex].value
          .recentMessage = RecentMessage.fromJson(response);
      conversationsController.conversations.refresh();
    }

    messageData.value = {
      'thumbnail': null,
      'source': null,
      'type': 'text',
      'message': '',
      'metadata': {}
    };
  }

  goToMaxScroll(scrollController) {
    if (scrollController.hasClients)
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  readConversation() async {
    await ApiService().request(
        'conversations/seen', {'conversation_id': conversationID}, 'POST',
        withToken: true);
    ConversationsController conversationsController =
        Get.find<ConversationsController>();
    Rx<Conversations>? conversation = conversationsController.conversations
        .firstWhere((e) => e.value.id == conversationID);
    conversation.value.recentMessage?.isSeen = true;
    conversationsController.conversations.refresh();
  }

  Future generateMessageImages() async {
    Directory tempDir = await getTemporaryDirectory();
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Source
    String sourceTmpPath = '${tempDir.path}/$timestamp-source.jpg';
    messageData['source'] = await FlutterImageCompress.compressAndGetFile(
        messageData['source'], sourceTmpPath,
        autoCorrectionAngle: true, quality: 50, minWidth: 1200, keepExif: true);

    // Thumbnail
    messageData['thumbnail'] = File(messageData['thumbnail']);
  }

  Future compressPostVideo() async {
    Directory tempDir = await getTemporaryDirectory();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String compressedTmpPath = '${tempDir.path}/$timestamp-compressed.mp4';
    final LightCompressor _lightCompressor = LightCompressor();
    final dynamic response = await _lightCompressor.compressVideo(
        path: messageData['source'],
        destinationPath: compressedTmpPath,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        iosSaveInGallery: false);
    if (response is OnSuccess) {
      messageData['source'] = File(response.destinationPath);
    }

    // Thumbnail
    messageData['thumbnail'] = File(messageData['thumbnail']);
  }

  Future deleteMessage(int messageID) async {
    updateDeletedMessage(messageID, 'now');
    Map<String, dynamic>? response = await ApiService().request(
        'conversations/messages/$messageID', {}, 'DELETE',
        withToken: true);
    if (response != null) {
      updateDeletedMessage(response['id'], response['deleted_at']);
    }
  }

  updateDeletedMessage(int messageID, String deletedAt) {
    dynamic message = messages.firstWhere(
      (element) => element['id'] == messageID,
      orElse: () => null,
    );
    if (message != null) {
      message['deleted_at'] = 'noq';
      messages.refresh();
      ConversationsController conversationsController =
          Get.find<ConversationsController>();
      Rx<Conversations>? conversation = conversationsController.conversations
          .firstWhere((e) => e.value.id == conversationID);
      if (conversation.value.recentMessage != null &&
          conversation.value.recentMessage!.id == messageID) {
        conversation.value.recentMessage!.deletedAt = deletedAt;
        conversationsController.conversations.refresh();
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    message.dispose();
    Get.find<AuthController>().currentConversationId = null;
  }
}
