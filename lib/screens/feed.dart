import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/feed.dart';
import 'package:alterr/controllers/notification.dart';
import 'package:alterr/controllers/stories.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/story.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/screens/notifications.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/utils/create_story.dart';
import 'package:alterr/utils/feed_card_body.dart';
import 'package:alterr/utils/feed_card_footer.dart';
import 'package:alterr/utils/feed_card_header.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

// ignore: must_be_immutable
class FeedScreen extends StatefulWidget {
  @override
  FeedScreenState createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  final FeedController controller = Get.put(FeedController());
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Widget contentScreen = Container();
  NotificationController notificationController =
      Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    controller.getFeedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return _feedScreen(context);
  }

  Widget _feedScreen(context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: Container(
              padding: EdgeInsets.only(
                left: 15.0,
                right: 7.5,
                bottom: 15.0,
              ),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
              )),
              child: SafeArea(
                //child: SearchAlterr(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 23,
                    ),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        splashRadius: 15,
                        onPressed: () {
                          Navigator.of(context).push<void>(SwipeablePageRoute(
                              builder: (_) => NotificationsScreen()));
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.translate(
                              offset: Offset(0, -3.5),
                              child: Icon(FeatherIcons.bell),
                            ),
                            Obx(
                              () =>
                                  notificationController.toReadNotifs.value == 0
                                      ? SizedBox.shrink()
                                      : Positioned(
                                          top: -8,
                                          right: -4,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.5, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Text(
                                              notificationController
                                                  .toReadNotifs
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            )),
      ),
      body: SmartRefresher(
        scrollController: controller.scrollController,
        enablePullDown: true,
        enablePullUp: true,
        primary: false,
        controller: _refreshController,
        onRefresh: () async {
          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/sounds/refresh.mp3"),
          );
          HapticFeedback.mediumImpact();
          await controller.refreshFeedPosts();
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await controller.nextPageFeedPosts();
          _refreshController.loadComplete();
        },
        child: Obx(
          () => SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  ..._feedPosts(),
                ],
              )),
        ),
      ),
    );
  }

  List<Widget> _feedPosts() {
    List<Widget> widgets = [];

    if (controller.loading.value) {
      widgets = [_shimmers()];
    } else if (controller.posts.length == 0 &&
        controller.pendingPosts.length == 0) {
      widgets = [
        Container(
          margin: EdgeInsets.only(top: 300),
          alignment: Alignment.center,
          child: Text(
            'No posts to show',
            style: TextStyle(color: Colors.black26, fontSize: 17),
          ),
        )
      ];
    } else {
      widgets = [
        ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: controller.pendingPosts.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return pendingPost(controller.pendingPosts[index], context);
          },
        ),
        ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: controller.posts.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Rx<Post> post = controller.posts[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push<void>(SwipeablePageRoute(
                    builder: (_) => PostScreen(
                          post: post,
                        )));
              },
              child: feedCard(post, index, context),
            );
          },
        ),
      ];
    }

    return widgets;
  }

  Widget showPendingStory(Map<String, dynamic> pendingStory) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 0, 5),
      child: Stack(alignment: AlignmentDirectional.center, children: [
        Container(
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: FileImage(
                pendingStory['thumbnail'],
              ),
            ),
          ),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.center,
                  colors: [Colors.black, Colors.black12],
                ),
                //   borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 0),
                    blurRadius: 0.0,
                  ),
                ]),
          ),
        ),
        Center(
            child: CircularProgressIndicator(
          strokeWidth: 5.0,
          value: pendingStory['progress'],
        ))
      ]),
    );
  }

  Widget _shimmers() {
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

  Widget pendingPost(Map<String, dynamic> pendingPost, context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.35,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 15, left: 15, right: 15, bottom: 10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfilePicture(
                            source: pendingPost['user'].profilePicture,
                            radius: 18,
                          ),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pendingPost['user'].username,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 2,
                              ),
                              Text('Just now',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black45)),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0.35,
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
                child: Text(pendingPost['caption'],
                    style: TextStyle(fontSize: 15.5, height: 1.3)),
              ),
            ),
            pendingPost['type'] == 'photo' || pendingPost['type'] == 'video'
                ? Stack(
                    children: [
                      Opacity(
                        opacity: 0.35,
                        child: Image.file(pendingPost['thumbnail']),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Obx(() => LinearProgressIndicator(
                              value: pendingPost['progress'],
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor),
                            )),
                      )
                    ],
                  )
                : SizedBox.shrink()
          ],
        ),
      ],
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
}

class StoryCard extends StatelessWidget {
  final bool addStory;
  final UsersStories stories;

  StoryCard({Key? key, this.addStory = false, required this.stories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = Get.find<AuthController>().user;
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 0, 0, 5),
      child: Stack(alignment: AlignmentDirectional.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            fadeInDuration: Duration(seconds: 0),
            placeholderFadeInDuration: Duration(seconds: 0),
            fadeOutDuration: Duration(seconds: 0),
            imageUrl: addStory
                ? currentUser?.profilePicture
                : stories.stories[0]['thumbnail'],
            placeholder: (context, _) {
              return Container(
                width: 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/profile-placeholder.png'),
                        fit: BoxFit.cover)),
              );
            },
            errorWidget: (context, url, _) {
              return Container(
                width: 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/profile-placeholder.png'),
                        fit: BoxFit.cover)),
              );
            },
            imageBuilder: (context, imageProvider) {
              return Container(
                width: 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                    color: addStory ? Colors.grey[200] : null),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.center,
                        colors: [Colors.black, Colors.black12],
                      ),
                      //   borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 0),
                          blurRadius: 0.0,
                        ),
                      ]),
                ),
              );
            },
          ),
        ),
        addStory == false
            ? Positioned(
                right: 5,
                bottom: 5,
                child: ProfilePicture(
                  source: stories.profilePicture,
                  radius: 12,
                ),
              )
            : Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Ionicons.add_circle,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    )),
              )
      ]),
    );
  }
}
