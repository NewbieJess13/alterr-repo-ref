import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/feed.dart';
import 'package:alterr/controllers/notification.dart';
import 'package:alterr/controllers/profile.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/search.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/models/conversations.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/feed_card_body.dart';
import 'package:alterr/utils/feed_card_footer.dart';
import 'package:alterr/utils/feed_card_header.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:alterr/screens/profile_settings.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:alterr/screens/conversation.dart';
import 'package:alterr/screens/account_settings.dart';
import 'package:alterr/screens/monetization_settings.dart';
import 'package:alterr/screens/topup.dart';
import 'package:alterr/services/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/report_content.dart';
import 'package:intl/intl.dart';
import 'package:alterr/utils/mediaviewer.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class ProfileScreen extends StatefulWidget {
  final bool leading;
  final User user;

  ProfileScreen({Key? key, required this.user, this.leading = false})
      : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

// ignore: must_be_immutable
class ProfileScreenState extends State<ProfileScreen> {
  final authController = Get.put(AuthController());
  Widget contentScreen = Container();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController(), tag: 'profile_${widget.user.id}');
    controller.getProfile(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _profileScreen(context));
  }

  Widget _profileScreen(context) {
    final User? currentUser = authController.user;
    final df = new DateFormat('MMM yyyy');
    return Scaffold(
        appBar: CustomAppBar(
            leading: widget.leading == true
                ? Transform.translate(
                    offset: Offset(-5, 0),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      splashRadius: 15.0,
                      color: Colors.black87,
                      icon: Transform.translate(
                        offset: Offset(-1, -6),
                        child: Icon(
                          FeatherIcons.arrowLeft,
                          size: 26,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                : Container(),
            title: widget.user.username,
            action: Transform.translate(
              offset: Offset(5, 0),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                splashRadius: 15.0,
                color: Colors.black87,
                icon: Transform.translate(
                  offset: Offset(0, -6),
                  child: Icon(currentUser?.id == widget.user.id
                      ? FeatherIcons.menu
                      : FeatherIcons.moreHorizontal),
                ),
                onPressed: () => _showProfileActions(context),
              ),
            )).build(),
        body: SmartRefresher(
          primary: false,
          onRefresh: () async {
            AssetsAudioPlayer.newPlayer().open(
              Audio("assets/sounds/refresh.mp3"),
            );
            HapticFeedback.mediumImpact();
            await controller.getProfile(widget.user.id);
            _refreshController.refreshCompleted();
          },
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          scrollController: controller.scrollController,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      widget.user.profilePicture != null &&
                              widget.user.profilePicture != ''
                          ? GestureDetector(
                              onTap: () => {
                                MediaViewer().open(context,
                                    url: widget.user.profilePicture!,
                                    tag: '${widget.user.id}-profile-picture')
                              },
                              child: ProfilePicture(
                                  source: widget.user.profilePicture,
                                  radius: 42.5),
                            )
                          : Container(
                              height: 85,
                              width: 85,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/profile-placeholder.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(50))),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        child: Column(
                                          children: [
                                            Text(
                                                controller.user.value.id == 0
                                                    ? ''
                                                    : controller.posts.length
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.black)),
                                            Text('Posts',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                ))
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          controller.followTabIndex.value = 0;
                                          Navigator.of(context).push<void>(
                                              SwipeablePageRoute(
                                                  builder: (_) => _follow()));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.transparent)),
                                          child: Column(
                                            children: [
                                              Text(
                                                  controller.user.value.id == 0
                                                      ? ''
                                                      : controller
                                                          .followersCount
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      color: Colors.black)),
                                              Text('Followers',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          controller.followTabIndex.value = 1;
                                          Navigator.of(context).push<void>(
                                              SwipeablePageRoute(
                                                  builder: (_) => _follow()));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.transparent)),
                                          child: Column(
                                            children: [
                                              Text(
                                                  controller.user.value.id == 0
                                                      ? ''
                                                      : controller
                                                          .following.length
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      color: Colors.black)),
                                              Text('Following',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                controller.user.value.id == 0
                                    ? Container(
                                        height: 38,
                                      )
                                    : Container(
                                        child: currentUser?.id ==
                                                controller.user.value.id
                                            ? CustomButton(
                                                color: Colors.black,
                                                size: 'medium',
                                                theme: 'bordered',
                                                onPressed: () {
                                                  _showProfileSettings();
                                                },
                                                label: 'Edit Profile',
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Expanded(
                                                      child: CustomButton(
                                                        disabled: controller
                                                            .followButtonLoading
                                                            .value,
                                                        onPressed: () {
                                                          controller
                                                              .followUser();
                                                        },
                                                        prefixIcon:
                                                            Transform.translate(
                                                          offset: Offset(0, -1),
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 7.5),
                                                            child: Icon(
                                                              controller
                                                                      .isFollowed
                                                                      .value
                                                                  ? FeatherIcons
                                                                      .userCheck
                                                                  : FeatherIcons
                                                                      .userPlus,
                                                              size: 18,
                                                              color: controller
                                                                          .isFollowed
                                                                          .value ==
                                                                      false
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        ),
                                                        color: controller
                                                                    .isFollowed
                                                                    .value ==
                                                                false
                                                            ? Colors.white
                                                            : Colors.black,
                                                        size: 'medium',
                                                        label: controller
                                                                .isFollowed
                                                                .value
                                                            ? "Following"
                                                            : controller.isFollower
                                                                        .value ==
                                                                    true
                                                                ? 'Follow back'
                                                                : 'Follow',
                                                        theme: controller
                                                                    .isFollowed
                                                                    .value ==
                                                                false
                                                            ? null
                                                            : 'bordered',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Container(
                                                      width: 45,
                                                      child: CustomButton(
                                                        size: 'medium',
                                                        theme: 'bordered',
                                                        prefixIcon: Icon(
                                                          FeatherIcons
                                                              .messageSquare,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                        onPressed: () async {
                                                          Map<String, String>
                                                              participants = {
                                                            'participants':
                                                                '[${currentUser?.id},${controller.user.value.id}]'
                                                          };

                                                          Map<String, dynamic>
                                                              response =
                                                              await ApiService()
                                                                  .request(
                                                                      'conversations',
                                                                      participants,
                                                                      'POST',
                                                                      withToken:
                                                                          true);
                                                          Conversations
                                                              conversation =
                                                              Conversations
                                                                  .fromJson(
                                                                      response);
                                                          conversation.user =
                                                              controller
                                                                  .user.value;
                                                          Get.find<
                                                                  ConversationsController>()
                                                              .conversations
                                                              .add(conversation
                                                                  .obs);
                                                          Navigator.of(context).push<
                                                                  void>(
                                                              SwipeablePageRoute(
                                                                  builder: (_) =>
                                                                      ConversationScreen(
                                                                        user: controller
                                                                            .user
                                                                            .value,
                                                                        conversationID:
                                                                            response['id'],
                                                                      )));
                                                        },
                                                      ),
                                                    ),
                                                  ]),
                                      )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.username,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        widget.user.bio != null && widget.user.bio!.isNotEmpty
                            ? Text(
                                widget.user.bio!,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    color: Colors.black),
                              )
                            : SizedBox.shrink(),
                        Text(
                          'Joined ' +
                              df.format(DateTime.parse(widget.user.createdAt)),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        child: CustomButton(
                          pill: true,
                          color: controller.activeTab.value == 'posts'
                              ? Colors.white
                              : Colors.black,
                          size: 'small',
                          theme: controller.activeTab.value == 'posts'
                              ? 'black'
                              : 'bordered',
                          onPressed: () {
                            controller.activeTab.value = 'posts';
                          },
                          label: 'Posts',
                        ),
                      ),
                      SizedBox(
                        width: 7.5,
                      ),
                      Container(
                        width: 80,
                        child: CustomButton(
                          pill: true,
                          color: controller.activeTab.value == 'media'
                              ? Colors.white
                              : Colors.black,
                          size: 'small',
                          theme: controller.activeTab.value == 'media'
                              ? 'black'
                              : 'bordered',
                          onPressed: () {
                            controller.activeTab.value = 'media';
                          },
                          label: 'Media',
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                _tabView()
              ],
            ),
          ),
        ));
  }

  Widget _tabView() {
    Widget _tabView = Container();
    switch (controller.activeTab.value) {
      case 'posts':
        _tabView = controller.user.value.id == 0 ? _postShimmers() : _posts();
        break;

      case 'media':
        _tabView = controller.user.value.id == 0 ? _mediaShimmers() : _media();
        break;
    }
    return _tabView;
  }

  Widget _following() {
    return controller.following.length == 0
        ? Center(
            child: Text(
            'No followed users yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black26, fontSize: 17),
          ))
        : SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.following.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> following = controller.following[index];
                  User followingUser = User.fromJson(following['user']);
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push<void>(SwipeablePageRoute(
                          builder: (_) => ProfileScreen(
                                user: followingUser,
                                leading: true,
                              )));
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          followingUser.profilePicture != null &&
                                  followingUser.profilePicture != ''
                              ? CachedNetworkImage(
                                  fadeInDuration: Duration(seconds: 0),
                                  placeholderFadeInDuration:
                                      Duration(seconds: 0),
                                  fadeOutDuration: Duration(seconds: 0),
                                  imageUrl: followingUser.profilePicture!,
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
                          const SizedBox(width: 7.5),
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(0, -1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    followingUser.username,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  followingUser.bio != null
                                      ? Container(
                                          margin: EdgeInsets.only(top: 1.5),
                                          child: Text(
                                            followingUser.bio!,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                height: 1.2),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  Widget _followers() {
    return controller.followersCount.value == 0
        ? Center(
            child: Text(
            'No followers yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black26, fontSize: 17),
          ))
        : SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.followers.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> follower = controller.followers[index];
                  if (follower['user_following'] == null) {
                    return Container();
                  }
                  follower['user'] = User.fromJson(follower['user_following']);
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push<void>(SwipeablePageRoute(
                          builder: (_) => ProfileScreen(
                                user: follower['user'],
                                leading: true,
                              )));
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          follower['user_following']['profile_picture'] !=
                                      null &&
                                  follower['user_following']
                                          ['profile_picture'] !=
                                      ''
                              ? CachedNetworkImage(
                                  fadeInDuration: Duration(seconds: 0),
                                  placeholderFadeInDuration:
                                      Duration(seconds: 0),
                                  fadeOutDuration: Duration(seconds: 0),
                                  imageUrl: follower['user_following']
                                      ['profile_picture'],
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
                          const SizedBox(width: 7.5),
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(0, -1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    follower['user_following']['username'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  follower['user_following']['bio'] != null &&
                                          follower['user_following']['bio']
                                                  .trim()
                                                  .length >
                                              0
                                      ? Container(
                                          margin: EdgeInsets.only(top: 1.5),
                                          child: Text(
                                            follower['user_following']['bio'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                height: 1.2),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  Widget _follow() {
    return Obx(
      () => DefaultTabController(
          length: 2,
          initialIndex: controller.followTabIndex.value,
          child: Scaffold(
            appBar: CustomAppBar(
              leading: Transform.translate(
                offset: Offset(-5, 0),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 15.0,
                  color: Colors.black87,
                  icon: Transform.translate(
                    offset: Offset(-1, -6),
                    child: Icon(
                      FeatherIcons.arrowLeft,
                      size: 26,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              title: controller.user.value.username,
            ).build(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  unselectedLabelColor: Colors.black38,
                  labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica Neue'),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Helvetica Neue'),
                  tabs: [
                    Tab(
                      text:
                          '${controller.followersCount.value.toString()} Followers',
                    ),
                    Tab(
                      text:
                          '${controller.followingCount.value.toString()} Following',
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                ),
                Expanded(
                  child: TabBarView(
                    children: [_followers(), _following()],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget _posts() {
    return Obx(() => controller.posts.length > 0
        ? ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: controller.posts.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Rx<Post> post = controller.posts[index];
              post.value.user = controller.user.value;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push<void>(SwipeablePageRoute(
                      builder: (_) => PostScreen(
                            post: post,
                            popOnUserTap: true,
                          )));
                },
                child: feedCard(post, index, context),
              );
            },
          )
        : Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 150),
            child: Text(
              'No posts yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 17),
            )));
  }

  Widget _media() {
    return Obx(() => controller.media.length > 0
        ? GridView.builder(
            padding: EdgeInsets.all(0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
            itemCount: controller.media.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Rx<Post> post = controller.media[index];
              post.value.user = controller.user.value;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push<void>(SwipeablePageRoute(
                      builder: (_) => PostScreen(
                            post: post,
                            popOnUserTap: true,
                          )));
                },
                child: mediaThumbnail(post, index, context),
              );
            },
          )
        : Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 150),
            child: Text(
              'No media yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 17),
            )));
  }

  Widget mediaThumbnail(Rx<Post> post, int postIndex, context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Color(int.parse('0xff${post.value.color}')),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      post.value.isSensitive == true
                          ? post.value.preview!
                          : post.value.thumbnail!),
                  fit: BoxFit.cover)),
        ),
        post.value.type == 'video' && post.value.unlocked == true
            ? Positioned(
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
            : Container(),
        post.value.type == 'video' && post.value.metadata != null
            ? Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Text(
                    post.value.metadata?['duration'],
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.1),
                  ),
                ),
              )
            : Container(),
        post.value.unlocked == false
            ? Center(
                child: Icon(
                  FeatherIcons.lock,
                  size: 18,
                  color: Colors.white,
                ),
              )
            : SizedBox.shrink(),
        post.value.unlocked == true &&
                post.value.type == 'photo' &&
                post.value.isSensitive == true
            ? Center(
                child: Icon(
                FeatherIcons.eyeOff,
                size: 18,
                color: Colors.white,
              ))
            : Container(),
      ],
    );
  }

  Widget _postShimmers() {
    final items = List<String>.generate(10, (i) => "Item $i");
    return ListView.builder(
      itemCount: items.length,
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 15),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 40,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 350,
                color: Colors.black.withOpacity(0.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mediaShimmers() {
    final items = List<String>.generate(12, (i) => "Item $i");
    return GridView.builder(
      padding: EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
      itemCount: items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.black.withOpacity(0.4),
            width: double.infinity,
          ),
        );
      },
    );
  }

  Widget feedCard(Rx<Post> post, int postIndex, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 7.5, color: Colors.black.withOpacity(0.075)))),
      child: Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: FeedCardHeader(
              userPicture: post.value.user.profilePicture,
              isPublic: post.value.isPublic,
              dateTime: post.value.createdAt,
              userName: post.value.user.username,
              editable: post.value.editable,
              slug: post.value.slug,
              onUserTapped: () {
                Navigator.of(context).push<void>(SwipeablePageRoute(
                    builder: (_) => ProfileScreen(
                          user: post.value.user,
                          leading: true,
                        )));
              },
            ),
          ),
          FeedCardBody(
            post: post,
            parsedCaption: Helpers.parseCaption(post.value.caption),
            screen: UniqueKey().toString(),
          ),
          Obx(
            () => FeedCardFooter(
              post: post,
              onLikeTap: () async {
                controller.likePost(post.value.slug, !post.value.isLiked);
              },
              onCommentTap: () async {
                Navigator.of(context).push<void>(SwipeablePageRoute(
                    builder: (_) => PostScreen(
                          post: post,
                          focusCommentInput: true,
                        )));
              },
              isLiked: post.value.isLiked,
              likes: post.value.postLikesCount.toString(),
              comments: post.value.commentsCount.toString(),
              views: post.value.views.toString(),
            ),
          ),
        ]),
      ),
    );
  }

  _showProfileActions(context) {
    List<Widget> options = [];

    if (authController.user?.id == controller.user.value.id) {
      options = [
        InkWell(
          onTap: () => {_showAccountSettings()},
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.settings,
                  size: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 17, height: 1),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => {_showTopUp()},
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.gift,
                  size: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'Top Up',
                  style: TextStyle(fontSize: 17, height: 1),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => {_showMonetizationSettings()},
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.dollarSign,
                  size: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'Monetization',
                  style: TextStyle(fontSize: 17, height: 1),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            navigator?.pop();
            authController.signOut();
          },
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Text('Logout',
                style: TextStyle(fontSize: 17, color: Colors.red, height: 1),
                textAlign: TextAlign.center),
          ),
        ),
      ];
    } else {
      options = [
        InkWell(
          onTap: () => {_blockUser(context)},
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.05)))),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.userX,
                  size: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'Block',
                  style: TextStyle(fontSize: 17, height: 1),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => {_reportUser(context)},
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.alertCircle,
                  size: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'Report',
                  style: TextStyle(fontSize: 17, height: 1),
                )
              ],
            ),
          ),
        ),
      ];
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
            child: SafeArea(
              top: false,
              child: content,
            ),
            context: context)
        .show();
  }

  _reportUser(context) {
    navigator?.pop();
    Get.put(ReportContent()).showModalReport(context,
        type: 'User', name: controller.user.value.username);
  }

  _blockUser(context) {
    navigator?.pop();
    PlatformAlertDialog(
      title: 'Block ${controller.user.value.username}?',
      content:
          '${controller.user.value.username} will no longer be able to message you or find your profile and posts on Alterr.',
      actions: [
        PlatformAlertDialogAction(
          child: Text('Cancel'),
          isDefaultAction: true,
          onPressed: () => navigator?.pop(),
        ),
        PlatformAlertDialogAction(
          child: Text(
            'Block',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            navigator?.pop();
            Navigator.of(context).pop();
            ProfileController profileController = Get.find<ProfileController>(
                tag: 'profile_${authController.user?.id}');

            int index;
            // remove user from followers
            index = profileController.followers.indexWhere((element) =>
                element['user_following']['username'] ==
                controller.user.value.username);
            if (index > -1) {
              profileController.followers.removeAt(index);
            }

            // remove user from following
            index = profileController.following.indexWhere((element) =>
                element['user']['username'] == controller.user.value.username);
            if (index > -1) {
              profileController.following.removeAt(index);
            }

            // remove conversation with user
            ConversationsController conversationsController =
                Get.find<ConversationsController>();
            index = conversationsController.conversations.indexWhere(
                (element) => element.value.user.id == controller.user.value.id);
            if (index > -1) {
              conversationsController.conversations.removeAt(index);
            }

            // remove notifications from user
            NotificationController notificationController =
                Get.find<NotificationController>();
            index = notificationController.notifications.indexWhere(
                (element) => element.value.user.id == controller.user.value.id);
            if (index > -1) {
              notificationController.notifications.removeAt(index);
            }

            // remove user's post from feed
            FeedController feedController = Get.find<FeedController>();
            index = feedController.posts.indexWhere(
                (element) => element.value.user.id == controller.user.value.id);
            if (index > -1) {
              feedController.posts.removeAt(index);
            }

            // remove user's post from popular posts (search)
            SearchController searchController = Get.find<SearchController>();
            index = searchController.postSearchResults.indexWhere(
                (element) => element.user.id == controller.user.value.id);
            if (index > -1) {
              searchController.postSearchResults.removeAt(index);
            }

            // block user (server)
            ApiService().request(
                'users/${controller.user.value.username}/block',
                {'is_blocked': true},
                'PUT',
                withToken: true);
          },
        ),
      ],
    ).show();
  }

  _showProfileSettings() {
    navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ProfileSettingsScreen();
        },
        fullscreenDialog: true));
  }

  _showAccountSettings() {
    navigator?.pop();
    navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return AccountSettingsScreen();
        },
        fullscreenDialog: true));
  }

  _showMonetizationSettings() {
    navigator?.pop();
    navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return MonetizationSettingsScreen();
        },
        fullscreenDialog: true));
  }

  _showTopUp() {
    navigator?.pop();
    navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return TopupScreen();
        },
        fullscreenDialog: true));
  }
}
