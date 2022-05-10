import 'package:alterr/controllers/nav.dart';
import 'package:alterr/controllers/search.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/utils/feed_card_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:alterr/models/post.dart';
import 'package:get/get.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/post_unlock.dart';
import 'package:alterr/utils/post_modal.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:xml_parser/xml_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedCardBody extends StatefulWidget {
  final Rx<Post> post;
  final String screen;
  final List<XmlNode> parsedCaption;
  final bool blurSensitve;

  const FeedCardBody(
      {Key? key,
      required this.post,
      required this.screen,
      required this.parsedCaption,
      this.blurSensitve = true})
      : super(key: key);

  @override
  FeedCardBodyState createState() => FeedCardBodyState();
}

class FeedCardBodyState extends State<FeedCardBody> {
  PostController? controller;

  @override
  Widget build(BuildContext context) {
    Widget heroImage = SizedBox.shrink();
    if (widget.post.value.type == 'photo' ||
        widget.post.value.type == 'video') {
      heroImage = _heroImage(context);
    }
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: _caption())),
            ),
            if (widget.post.value.type == 'photo' ||
                widget.post.value.type == 'video')
              GestureDetector(
                onTap: () => {
                  openPost(context,
                      tag:
                          "${widget.post.value.slug.toString()}.${widget.screen}.source")
                },
                child: Container(
                  child: ClipRRect(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.post.value.color != null
                            ? Color(int.parse('0xff${widget.post.value.color}'))
                            : Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            child: Hero(
                              tag:
                                  "${widget.post.value.slug.toString()}.${widget.screen}.source",
                              placeholderBuilder: (context, size, widget) {
                                return heroImage;
                              },
                              child: heroImage,
                            ),
                          ),
                          widget.post.value.unlocked == true &&
                                  widget.post.value.type == 'video'
                              ? Positioned(
                                  child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  child: Transform.translate(
                                    offset: Offset(1.5, 0),
                                    child: Icon(
                                      FeatherIcons.play,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                              : Container(),
                          widget.post.value.type == 'video' &&
                                  widget.post.value.metadata != null
                              ? Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    child: Text(
                                      widget.post.value.metadata!['duration'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13.0),
                                    ),
                                  ),
                                )
                              : Container(),
                          widget.post.value.unlocked == false
                              ? Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    FeatherIcons.lock,
                                    size: 19,
                                    color: Colors.white,
                                  ))
                              : Container(),
                          widget.post.value.unlocked == false
                              ? Material(
                                  color: Colors.transparent,
                                  child: CustomButton(
                                      unconstrained: true,
                                      theme: 'primary',
                                      label:
                                          'Unlock for ${widget.post.value.price} barias',
                                      onPressed: () => {openUnlock(context)}),
                                )
                              : SizedBox.shrink(),
                          widget.post.value.unlocked == true &&
                                  widget.post.value.type == 'photo' &&
                                  widget.post.value.isSensitive == true &&
                                  widget.blurSensitve
                              ? Positioned(
                                  child: Icon(
                                  FeatherIcons.eyeOff,
                                  size: 24,
                                  color: Colors.white,
                                ))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.post.value.type == 'text' &&
                widget.post.value.linkPreview != null &&
                widget.post.value.linkPreview!['image'] != null &&
                widget.post.value.linkPreview!['image'] != '')
              Container(
                child: GestureDetector(
                  onTap: () =>
                      _launchURL(widget.post.value.linkPreview!['url']),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        fadeInDuration: Duration(seconds: 0),
                        placeholderFadeInDuration: Duration(seconds: 0),
                        fadeOutDuration: Duration(seconds: 0),
                        imageUrl: widget.post.value.linkPreview!['image'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                              widget.post.value.linkPreview!['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              Uri.parse(widget.post.value.linkPreview!['url'])
                                  .host
                                  .replaceAll('www.', '')
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.post.value.type == 'post')
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: _sharedPost(),
              )
          ],
        ));
  }

  Widget _sharedPost() {
    if (widget.post.value.parent == null ||
        widget.post.value.parent!['user'] == null) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 35),
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(color: Colors.black12),
          ),
          child: Text('Content not available',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15)));
    }
    User parentUser = User.fromJson(widget.post.value.parent!['user']);
    Post parentPost = Post.fromJson(widget.post.value.parent!);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(SwipeablePageRoute(
            builder: (_) => PostScreen(
                  post: parentPost.obs,
                )));
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding:
                    EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                child: FeedCardHeader(
                  userPicture: parentUser.profilePicture,
                  isPublic: parentPost.isPublic,
                  dateTime: parentPost.createdAt,
                  userName: parentUser.username,
                  hideOptions: true,
                  onUserTapped: () {
                    Navigator.of(context).push<void>(SwipeablePageRoute(
                        builder: (_) => ProfileScreen(
                              user: parentUser,
                              leading: true,
                            )));
                  },
                )),
            FeedCardBody(
              post: parentPost.obs,
              parsedCaption: Helpers.parseCaption(parentPost.caption),
              screen: UniqueKey().toString(),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _caption() {
    List<InlineSpan> _caption = [];
    widget.parsedCaption.forEach((element) {
      if (element is XmlElement) {
        XmlElement userNode = element;
        bool isAtorHash = userNode.text![0] == '@';
        _caption.add(TextSpan(children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                if (isAtorHash) {
                  dynamic mentioned =
                      widget.post.value.mentions?.firstWhere((element) {
                    return element['user_id'] ==
                        int.parse(userNode.attributes![0].value);
                  }, orElse: () => null);
                  if (mentioned != null) {
                    User mentionedUser = User.fromJson(mentioned['user']);
                    Navigator.of(context).push<void>(SwipeablePageRoute(
                        builder: (_) => ProfileScreen(
                              user: mentionedUser,
                              leading: true,
                            )));
                  }
                } else {
                  NavController navController = Get.find<NavController>();
                  SearchController searchController =
                      Get.find<SearchController>();
                  searchController
                    ..searchTextController.text =
                        '#${userNode.attributes![0].value}'
                    ..searchFocus.refresh()
                    ..searchFocused.value = true;

                  navController.selectTab(navController.pageKeys[1], 1);
                }
              },
              child: Transform.translate(
                offset: Offset(0, 1),
                child: Text(
                  userNode.text!,
                  style: TextStyle(
                      fontSize: 15.5,
                      height: 1.2,
                      fontFamily: 'Helvetica Neue',
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          TextSpan(text: ' '),
        ]));
      } else {
        XmlText xmlText = element as XmlText;
        List parts = xmlText.value.split(' ');
        parts.forEach((element) {
          bool validURL = false;
          try {
            validURL = Uri.parse(element).host == '' ? false : true;
          } catch (e) {}
          Color color = Colors.black;
          if (validURL) {
            color = Colors.blue;
          }
          _caption.add(TextSpan(
              text: element,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (validURL) {
                    _launchURL(element);
                  }
                },
              style: TextStyle(
                  color: color,
                  fontSize: 15.5,
                  height: 1.2,
                  fontFamily: 'Helvetica Neue'),
              children: [TextSpan(text: ' ')]));
        });
      }
    });

    return _caption;
  }

  Widget _heroImage(context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double placeholderHeight = 210;
    if (widget.post.value.metadata!['width'] != null &&
        widget.post.value.metadata!['height'] != null) {
      double postWidth = widget.post.value.metadata!['width'].toDouble();
      double postHeight = widget.post.value.metadata!['height'].toDouble();
      double ratio = mediaQuery.size.width / postWidth;
      placeholderHeight = postHeight * ratio;
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double maxHeight = screenHeight - 360;
    if (placeholderHeight > maxHeight) {
      placeholderHeight = maxHeight;
    }

    return Obx(() => CachedNetworkImage(
          height: placeholderHeight,
          imageUrl: widget.post.value.isSensitive == true &&
                  widget.blurSensitve == true
              ? widget.post.value.preview!
              : widget.post.value.type == 'photo'
                  ? widget.post.value.source!
                  : widget.post.value.thumbnail!,
          fadeInDuration: Duration(seconds: 0),
          placeholderFadeInDuration: Duration(seconds: 0),
          fadeOutDuration: Duration(seconds: 0),
          width: double.infinity,
          placeholder: (context, url) => CachedNetworkImage(
            fadeInDuration: Duration(seconds: 0),
            placeholderFadeInDuration: Duration(seconds: 0),
            fadeOutDuration: Duration(seconds: 0),
            imageUrl: widget.post.value.thumbnail!,
            height: placeholderHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          fit: BoxFit.cover,
          errorWidget: (context, error, _) {
            return Container(
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text('Failed to load content.',
                  style: TextStyle(fontSize: 15, color: Colors.black54)),
            );
          },
        ));
  }

  void openUnlock(context) async {
    await PlatformBottomsheetModal(
            isDismissible: false,
            enableDrag: false,
            context: context,
            child: PostUnlock(post: widget.post))
        .show();
    if (widget.post.value.unlocked == true) {
      openPost(context,
          tag: "${widget.post.value.slug.toString()}.${widget.screen}.source");
    }
  }

  void openPost(context, {required String tag}) {
    PostModal(widget.post).open(context, tag: tag);
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
