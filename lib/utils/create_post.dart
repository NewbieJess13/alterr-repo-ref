import 'dart:convert';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/feed.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/utils/feed_card_body.dart';
import 'package:alterr/utils/feed_card_header.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:alterr/controllers/nav.dart';
import 'dart:io';
import 'package:alterr/services/api.dart';
import 'package:image/image.dart' as ManipulateImage;
import 'package:path_provider/path_provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:alterr/utils/s3.dart';
import 'package:alterr/utils/mediapicker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';
import 'package:alterr/forks/flutter_mentions/flutter_mentions.dart';
import 'package:alterr/utils/camera.dart';
import 'package:video_compress/video_compress.dart' as VC;

class CreatePost {
  open({Post? post}) async {
    await navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) => CreatePostForm(
              repost: post,
            ),
        fullscreenDialog: true));
  }
}

class CreatePostForm extends StatefulWidget {
  final Post? repost;
  CreatePostForm({
    Key? key,
    this.repost,
  }) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePostForm> {
  Map<String, dynamic> post = {
    'price': 50.00,
    'is_public': true,
    'caption': '',
    'type': 'text',
    'source': null,
    'thumbnail': null,
    'preview': null,
    'progress': 0.1,
    'metadata': {}
  };
  File? tempThumbnail;
  bool creatingPost = false;
  AssetEntity? asset;
  FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[];
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  User? user = Get.find<AuthController>().user;

  @override
  void initState() {
    super.initState();
    getSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
            leading: InkWell(
              onTap: () {
                navigator?.pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).primaryColor),
              ),
            ),
            title: '${widget.repost != null ? 'Share' : 'Create'} Post',
            action: InkWell(
              onTap:
                  post['caption'].length > 0 ? () => createPost(context) : null,
              child: Opacity(
                opacity: post['caption'].length == 0 ? 0.5 : 1,
                child: Text(
                  'Post',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )).build(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          choosePrivacy(context);
                        },
                        child: Container(
                          color: Colors.grey.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15.0),
                          child: Row(
                            children: [
                              Icon(
                                post['is_public']
                                    ? FeatherIcons.globe
                                    : FeatherIcons.lock,
                                size: 17.0,
                                color: Colors.black45,
                              ),
                              Text(
                                post['is_public']
                                    ? ' Public'
                                    : ' Locked (' +
                                        post['price'].round().toString() +
                                        ' barias)',
                                style: TextStyle(fontSize: 15.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ProfilePicture(
                                radius: 16,
                                source: user?.profilePicture,
                              ),
                            ),
                            Expanded(
                              child: FlutterMentions(
                                dataLength: suggestions.length,
                                autofocus: true,
                                focusNode: _focusNode,
                                key: key,
                                suggestionPosition: SuggestionPosition.Bottom,
                                maxLines: 12,
                                minLines: 1,
                                onChanged: (String value) {
                                  post['caption'] = value.trim();
                                  setState(() {});
                                },
                                decoration: InputDecoration.collapsed(
                                    hintText: 'What do you want to say?',
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                    )),
                                mentions: [
                                  Mention(
                                      trigger: '@',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      data: suggestions,
                                      disableMarkup: true,
                                      matchAll: false,
                                      suggestionBuilder: (data) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 9, horizontal: 15),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.transparent)),
                                          child: Row(
                                            children: [
                                              ProfilePicture(
                                                source: data['profile_picture'],
                                                radius: 18,
                                              ),
                                              SizedBox(width: 7.5),
                                              Expanded(
                                                child: Transform.translate(
                                                  offset: Offset(0, -1.5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        data['username'],
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      data['bio'] != null &&
                                                              data['bio']
                                                                      .trim()
                                                                      .length >
                                                                  0
                                                          ? Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 1.5),
                                                              child: Text(
                                                                data['bio'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    height: 1.2,
                                                                    color: Colors
                                                                        .black87),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      widget.repost != null
                          ? _repost()
                          : post['source'] != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(
                                      post['thumbnail'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    post['type'] == 'video'
                                        ? Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Icon(
                                              FeatherIcons.play,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )
                                        : Container(),
                                    Positioned(
                                      top: 7.5,
                                      right: 7.5,
                                      child: InkWell(
                                        onTap: () {
                                          post['source'] = null;
                                          post['thumbnail'] = null;
                                          post['preview'] = null;
                                          post['is_public'] = true;
                                          post['price'] = 50.00;
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.black
                                                  .withOpacity(0.75)),
                                          child: Transform.translate(
                                            offset: Offset(0, -1),
                                            child: Icon(
                                              FeatherIcons.x,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : SizedBox.shrink(),
                    ]),
              ),
            ),
            SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(
                              color: Colors.black.withOpacity(0.05)))),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: () => {
                            pickCamera(),
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
                            onTap: () => {
                              pickMedia(context),
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
                          )),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (tempThumbnail != null && !creatingPost) {
      tempThumbnail?.delete();
    }
    tempThumbnail = null;
    super.dispose();
  }

  Widget _repost() {
    return AbsorbPointer(
      absorbing: true,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                child: FeedCardHeader(
                    userPicture: widget.repost!.user.profilePicture,
                    isPublic: widget.repost!.isPublic,
                    dateTime: widget.repost!.createdAt,
                    userName: widget.repost!.user.username,
                    editable: widget.repost!.editable,
                    slug: widget.repost!.slug,
                    hideOptions: true),
              ),
              FeedCardBody(
                post: widget.repost!.obs,
                parsedCaption: Helpers.parseCaption(widget.repost!.caption),
                screen: UniqueKey().toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getSuggestions() async {
    List<dynamic>? response = await ApiService()
        .request('users/suggested', {}, 'GET', withToken: true);
    if (response != null) {
      List<Map<String, dynamic>> suggested = [];
      response.forEach((element) {
        element['id'] = element['id'].toString();
        element['display'] = element['username'];
        suggested.add(element);
      });
      suggestions.addAll(suggested);
    }
  }

  choosePrivacy(BuildContext context) {
    showCupertinoModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.5),
        duration: Duration(milliseconds: 300),
        expand: false,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, modalSetState) {
                return Material(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Post Privacy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () => {Navigator.pop(context)},
                              child: Text('Done',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor)),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 0,
                      ),
                      InkWell(
                        onTap: () {
                          setPrivacy(true);
                          modalSetState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black.withOpacity(0.05)))),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                FeatherIcons.globe,
                                color: post['is_public']
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Public',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.5,
                                          height: 1,
                                          color: post['is_public']
                                              ? Theme.of(context).primaryColor
                                              : Colors.black),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Anyone can see your post.',
                                      style:
                                          TextStyle(fontSize: 15.5, height: 1),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              Radio<bool>(
                                value: post['is_public'],
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) => {},
                                groupValue: true,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (post['source'] == null)
                        Container(
                          padding:
                              EdgeInsets.only(left: 47.0, top: 10, right: 47),
                          child: Container(
                            padding: EdgeInsets.all(7.5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.5),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.15)),
                            child: Text(
                              'Only posts that contain a photo or video can be set to locked.',
                              style: TextStyle(fontSize: 14, height: 1.2),
                            ),
                          ),
                        ),
                      AbsorbPointer(
                        absorbing: post['source'] == null,
                        child: InkWell(
                          onTap: () {
                            setPrivacy(false);
                            modalSetState(() {});
                          },
                          child: Opacity(
                            opacity: post['source'] == null ? 0.5 : 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    FeatherIcons.lock,
                                    color: !post['is_public']
                                        ? Theme.of(context).primaryColor
                                        : Colors.black,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Locked',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.5,
                                                height: 1,
                                                color: !post['is_public']
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.black),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Set a premium price for your post for users to unlock.',
                                            style: TextStyle(
                                                fontSize: 15.5, height: 1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Radio(
                                    value: !post['is_public'],
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => {},
                                    groupValue: true,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 34.0, top: 6),
                              child: Text(
                                  '${post['price'].round().toString()} barias',
                                  style: TextStyle(
                                      color: post['is_public'] ||
                                              post['source'] == null
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 15.5,
                                      height: 1,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 18.0),
                              child: SfSliderTheme(
                                data: SfSliderThemeData(
                                    tooltipTextStyle: TextStyle(fontSize: 16)),
                                child: SfSlider(
                                  stepSize: 50,
                                  value: double.parse(post['price'].toString()),
                                  min: 50.0,
                                  max: 1000.0,
                                  enableTooltip: true,
                                  minorTicksPerInterval: 50,
                                  onChanged: post['is_public'] ||
                                          post['source'] == null
                                      ? null
                                      : (value) {
                                          post['price'] = value;
                                          setState(() {});
                                          modalSetState(() {});
                                        },
                                  tooltipShape: SfPaddleTooltipShape(),
                                  tooltipTextFormatterCallback:
                                      (tooltip, value) {
                                    return '$value barias';
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35.0,
                      ),
                    ],
                  ),
                );
              },
            ));
  }

  pickMedia(BuildContext context) async {
    asset = await Mediapicker.pick(context);

    if (asset != null) {
      File? pickedFile = await asset?.originFile;

      if (asset?.type != AssetType.video && asset?.type != AssetType.image) {
        return;
      }

      if (asset?.type == AssetType.video) {
        List? durationParts =
            asset?.videoDuration.toString().substring(2, 7).split(':');
        Duration totalDuration = Duration(
          minutes: int.parse(durationParts![0]),
          seconds: int.parse(durationParts[1]),
        );
        if (totalDuration.inMinutes > 3) {
          PlatformAlertDialog(
            title: 'Error',
            content:
                'Your selected video exceeds the duration limit of 3 minutes.',
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

      // Set thumbnail
      Directory tempDir = await getTemporaryDirectory();
      tempThumbnail =
          File(tempDir.path + '/' + Helpers.randomString() + '.png');
      List<int>? listData =
          await asset?.thumbDataWithSize(750, 750, quality: 75);
      if (listData != null) {
        tempThumbnail?.writeAsBytesSync(listData);
        post['thumbnail'] = tempThumbnail;
      }

      if (asset?.type == AssetType.video) {
        post['type'] = 'video';
        post['metadata']['duration'] =
            asset?.videoDuration.toString().substring(2, 7);
      } else if (asset?.type == AssetType.image) {
        post['type'] = 'photo';
      }
      post['source'] = pickedFile;
    }

    setState(() {});
  }

  pickCamera() async {
    PickedFile? pickedFile = await Camera.pick();
    if (pickedFile != null) {
      String? mimeStr = lookupMimeType(pickedFile.path);
      String fileType = mimeStr!.split('/')[0];
      post['type'] = fileType == 'image' ? 'photo' : fileType;
      Directory tempDir = await getTemporaryDirectory();
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String thumbnailTmpPath = '${tempDir.path}/$timestamp-thumbnail.jpg';
      if (post['type'] == 'photo') {
        post['thumbnail'] = await FlutterImageCompress.compressAndGetFile(
            pickedFile.path, thumbnailTmpPath,
            autoCorrectionAngle: true,
            quality: 25,
            minWidth: 750,
            keepExif: true);
      } else if (post['type'] == 'video') {
        File postThumbnail = await VC.VideoCompress.getFileThumbnail(
          pickedFile.path,
          quality: 75,
        );

        post['thumbnail'] = postThumbnail;
        post['metadata']['duration'] =
            pickedFile.duration.toString().substring(2, 7);
      }
      post['source'] = File(pickedFile.path);
    }
  }

  void createPost(context) async {
    creatingPost = true;
    Navigator.pop(context);

    await Future.delayed(Duration(milliseconds: 400));
    post['progress'] = 0.2;

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    List pendingPosts = Get.find<FeedController>().pendingPosts;
    RxList<Rx<Post>> posts = Get.find<FeedController>().posts;
    post['timestamp'] = timestamp;
    post['user'] = Get.find<AuthController>().user;
    post['post'] = widget.repost;
    if (widget.repost != null) {
      post['post'] = widget.repost;
      post['post_slug'] = widget.repost?.slug;
      post['type'] = 'post';
    }
    pendingPosts.add(post);
    pendingPosts.reactive.refresh();

    Get.put(NavController()).screenIndex.value = 0;

    try {
      Map<String, dynamic> data = Map<String, dynamic>.from(post);
      data['price'] = post['price'].round().toString();
      data['source'] = data['thumbnail'] = data['preview'] = '';
      data.remove('post');

      if (post['type'] == 'photo' || post['type'] == 'video') {
        PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(
                Image.file(post['thumbnail']).image);
        data['color'] = paletteGenerator.dominantColor?.color.value
            .toRadixString(16)
            .substring(2);
        post['progress'] = 0.4;

        bool generateSource = post['type'] == 'photo';
        if (post['type'] == 'video') {
          generateSource = false;
          post['source'] = await compressPostVideo(post['source']);
          post['progress'] = 0.6;
        }

        await generatePostImages(
            source: generateSource, thumbnail: true, preview: true);
        post['progress'] = 0.8;

        /* Upload to S3 */
        String randomString = Helpers.randomString();
        String sourceName = Helpers.randomString();
        sourceName =
            post['type'] == 'video' ? '$sourceName.mp4' : '$sourceName.jpg';
        String thumbnailName = Helpers.randomString();
        String previewName = Helpers.randomString();
        String s3Path = 'posts/$randomString-$timestamp';

        // Upload source
        String sourcePath = await S3.uploadFile(
          s3Path,
          {'file': post['source'], 'filename': '$sourceName'},
        );
        data['source'] = sourcePath;
        post['progress'] = 0.8;

        // Upload thumbnail
        String thumbnailPath = await S3.uploadFile(s3Path,
            {'file': post['thumbnail'], 'filename': '$thumbnailName.jpg'});
        data['thumbnail'] = thumbnailPath;

        // Upload preview
        String previewPath = await S3.uploadFile(
            s3Path, {'file': post['preview'], 'filename': '$previewName.jpg'});
        data['preview'] = previewPath;

        File(post['source'].path).delete();
        File(post['thumbnail'].path).delete();
        File(post['preview'].path).delete();
      }

      post['progress'] = 1.0;

      data['metadata'] = jsonEncode(data['metadata']);

      ApiService()
          .request(
        'posts',
        data,
        'POST',
        withToken: true,
      )
          .then((response) {
        if (response != null) {
          posts.insert(0, Post.fromJson(response).obs);
          int index = pendingPosts
              .indexWhere((element) => element['timestamp'] == timestamp);
          if (index > -1) {
            pendingPosts.removeAt(index);
          }
        }
      });
    } catch (e) {
      PlatformAlertDialog(
        title: 'Error',
        content: '${e.toString()}',
        actions: [
          PlatformAlertDialogAction(
            child: Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              navigator?.pop();
            },
          )
        ],
      ).show();
    }

    creatingPost = false;
  }

  void setPrivacy(bool state) {
    if (post['is_public'] != state) {
      post['price'] = 50.0;
    }
    post['is_public'] = state;
    setState(() {});
  }

  Future generatePostImages(
      {bool source: true, bool thumbnail: false, bool preview: false}) async {
    ManipulateImage.Image decodedImage =
        ManipulateImage.decodeJpg(post['thumbnail'].readAsBytesSync());
    Directory tempDir = await getTemporaryDirectory();
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    if (source) {
      String sourceTmpPath = '${tempDir.path}/$timestamp-source.jpg';
      post['source'] = await FlutterImageCompress.compressAndGetFile(
          post['source'].path, sourceTmpPath,
          autoCorrectionAngle: true,
          quality: 50,
          minWidth: 1200,
          keepExif: true);
    }

    if (preview) {
      String previewTmpPath = '${tempDir.path}/$timestamp-preview.jpg';
      ManipulateImage.Image previewImage =
          ManipulateImage.copyResize(decodedImage, width: 350);
      previewImage = ManipulateImage.gaussianBlur(previewImage, 35);
      File(previewTmpPath)
          .writeAsBytesSync(ManipulateImage.encodeJpg(previewImage));
      post['preview'] = File(previewTmpPath);
    }
  }

  Future<File> compressPostVideo(File source) async {
    Directory tempDir = await getTemporaryDirectory();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String compressedTmpPath = '${tempDir.path}/$timestamp-compressed.mp4';
    final LightCompressor _lightCompressor = LightCompressor();
    final dynamic response = await _lightCompressor.compressVideo(
        path: source.path,
        destinationPath: compressedTmpPath,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        iosSaveInGallery: false);
    return File(response.destinationPath);
  }
}
