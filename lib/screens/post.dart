import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/comment.dart';
import 'package:alterr/utils/alterr_icons.dart';
import 'package:alterr/utils/feed_card_body.dart';
import 'package:alterr/utils/post_unlock.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alterr/services/api.dart';
import 'package:alterr/utils/feed_card_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:alterr/utils/feed_card_header.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alterr/utils/platform_spinner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:alterr/screens/profile.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';

class PostScreen extends StatefulWidget {
  final Rx<Post> post;
  final bool popOnUserTap;
  final bool focusCommentInput;

  PostScreen(
      {Key? key,
      required this.post,
      this.popOnUserTap = false,
      this.focusCommentInput = false})
      : super(key: key);

  @override
  PostScreenState createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  Widget contentScreen = Container();
  FocusNode commentFocus = FocusNode();
  late PostController controller;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late AuthController authController;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller =
        Get.put(PostController(), tag: 'post_${widget.post.value.slug}');
    controller.post = widget.post;
    controller.getPost();
    authController = Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusCommentInput == true) {
      commentFocus.requestFocus();
    }
    controller.context = context;
    return _post(context);
  }

  Widget _post(context) {
    return Obx(() => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(64),
            child: AppBar(
              leading: IconButton(
                splashRadius: 15.0,
                color: Colors.black87,
                icon: Icon(FeatherIcons.arrowLeft, size: 26),
                onPressed: () => Navigator.of(context).pop(),
              ),
              leadingWidth: 50,
              automaticallyImplyLeading: false,
              centerTitle: false,
              backgroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 3,
              title: Padding(
                padding: EdgeInsets.only(right: 15),
                child: FeedCardHeader(
                  context: context,
                  isPublic: widget.post.value.isPublic,
                  userPicture: widget.post.value.user.profilePicture,
                  dateTime: widget.post.value.createdAt,
                  userName: widget.post.value.user.username,
                  slug: widget.post.value.slug,
                  editable: widget.post.value.editable,
                  onUserTapped: () {
                    if (widget.popOnUserTap) {
                      return Navigator.of(context).pop();
                    }
                    Navigator.of(context).push<void>(SwipeablePageRoute(
                        builder: (_) => ProfileScreen(
                              user: widget.post.value.user,
                              leading: true,
                            )));
                  },
                ),
              ),
            ),
          ),
          body: SmartRefresher(
            enablePullUp: controller.postComments.length >= 20,
            enablePullDown: true,
            controller: _refreshController,
            scrollController: scrollController,
            onRefresh: () async {
              await controller.refreshComments();
              _refreshController.refreshCompleted();
            },
            onLoading: () async {
              await controller.nextPageComments();
              _refreshController.loadComplete();
            },
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeedCardBody(
                      blurSensitve: false,
                      post: widget.post,
                      parsedCaption:
                          Helpers.parseCaption(widget.post.value.caption),
                      screen: UniqueKey().toString(),
                    ),
                    Obx(
                      () => FeedCardFooter(
                        post: widget.post,
                        onLikeTap: () {
                          controller.likePost(!widget.post.value.isLiked);
                        },
                        onCommentTap: () async {
                          commentFocus.requestFocus();
                        },
                        isLiked: widget.post.value.isLiked,
                        likes: widget.post.value.postLikesCount.toString(),
                        comments: widget.post.value.commentsCount.toString(),
                        views: widget.post.value.views.toString(),
                      ),
                    ),
                    controller.commentsLoading.value == true
                        ? Padding(
                            padding: EdgeInsets.only(top: 70),
                            child: Center(
                              child: PlatformSpinner(
                                width: 16,
                                height: 16,
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(top: 10, bottom: 15),
                            child: controller.postComments.length == 0
                                ? Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 60.0),
                                      child: Text(
                                        'No comments yet.',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 15.5),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: controller.postComments.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final Rx<Comment> comment =
                                          controller.postComments[index];
                                      return CommentTile(
                                          controller: controller,
                                          authController: authController,
                                          post: widget.post.value,
                                          comment: comment,
                                          onUserTap: () {
                                            Navigator.of(context).push<void>(
                                                SwipeablePageRoute(
                                                    builder: (_) =>
                                                        ProfileScreen(
                                                          user: comment
                                                              .value.user,
                                                          leading: true,
                                                        )));
                                          });
                                    },
                                  ),
                          )
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.05)))),
            padding: EdgeInsets.all(10.0),
            child: Stack(
              children: [
                CustomTextField(
                  padding: EdgeInsets.only(right: 20),
                  controller: controller.commentTextEditing,
                  title: 'Write your comment...',
                  focusNode: commentFocus,
                  onChanged: (value) =>
                      {controller.newComment.value = value.toString().trim()},
                ),
                Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        await controller.addComment(navigator?.context);
                        await Future.delayed(Duration(milliseconds: 50));
                        controller.goToMaxScroll(scrollController);
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0, color: Colors.transparent)),
                        height: 48,
                        width: 35,
                        child: Transform.rotate(
                          angle: 44.8,
                          child: Icon(
                            FeatherIcons.send,
                            size: 20,
                            color: controller.newComment.value.length > 0
                                ? Theme.of(navigator!.context).primaryColor
                                : Colors.black26,
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

  void openPayment(context) async {
    await showCupertinoModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        duration: Duration(milliseconds: 300),
        context: context,
        builder: (context) => PostUnlock(post: widget.post));
  }
}

class CommentTile extends StatelessWidget {
  final Rx<Comment> comment;
  final Function onUserTap;
  final PostController controller;
  final AuthController authController;
  final Post post;
  const CommentTile(
      {Key? key,
      required this.comment,
      required this.onUserTap,
      required this.controller,
      required this.post,
      required this.authController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fromNow = timeago
        .format(DateTime.parse(comment.value.createdAt), locale: 'en_short')
        .replaceAll('~', '');

    return InkWell(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        commentActions(context, comment.value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: GestureDetector(
                onTap: () => onUserTap(),
                child: ProfilePicture(
                  source: comment.value.user.profilePicture,
                  radius: 16,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => onUserTap(),
                child: Text(
                  comment.value.user.username,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                comment.value.comment,
                style: TextStyle(fontSize: 15.5, height: 1.15),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                fromNow,
                style: TextStyle(fontSize: 13.5, color: Colors.black54),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Obx(() => Column(
                children: [
                  LikeButton(
                    isLiked: comment.value.isLiked,
                    size: 24,
                    circleColor: CircleColor(
                        start: Colors.transparent, end: Colors.transparent),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.red[600]!,
                      dotSecondaryColor: Colors.red[600]!,
                    ),
                    likeBuilder: (bool isLiked) {
                      return isLiked
                          ? Transform.translate(
                              offset: Offset(0, 0.5),
                              child: Icon(AlterrIcons.heart_red,
                                  size: 19, color: Colors.red[600]),
                            )
                          : Icon(
                              FeatherIcons.heart,
                              color: Colors.black87,
                              size: 17,
                            );
                    },
                    onTap: likeComment,
                  ),
                  if (comment.value.commentLikesCount > 0)
                    Text(
                      comment.value.commentLikesCount.toString(),
                      style: TextStyle(fontSize: 13.5, color: Colors.black54),
                    )
                ],
              )),
        ]),
      ),
    );
  }

  Future<bool?> likeComment(bool isLiked) async {
    await ApiService().request(
        'comments/likes', {'comment_id': comment.value.id.toString()}, 'POST',
        withToken: true);
    if (isLiked) {
      comment.value.commentLikesCount -= 1;
    } else {
      comment.value.commentLikesCount += 1;
    }
    comment.value.isLiked = !isLiked;
    comment.refresh();
    return true;
  }

  void commentActions(BuildContext context, Comment comment) {
    List<Widget> options = [];

    // Copy message
    options.add(InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: comment.comment));
        navigator?.pop();
      },
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Copy comment',
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

    // Delete message
    if (authController.user?.id == comment.user.id ||
        authController.user?.id == post.user.id) {
      options.add(
        InkWell(
          onTap: () {
            navigator?.pop();
            PlatformAlertDialog(
              title: 'Delete comment',
              content:
                  'Are you sure you want to permanently delete this comment?',
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
                    controller.deleteComment(comment.id);
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

/* Controller */
class PostController extends GetxController {
  Rx<Post> post = Post.empty().obs;
  int commentPage = 1;
  String? nextPageUrl;
  RxList<Rx<Comment>> postComments = <Rx<Comment>>[].obs;
  RxString newComment = ''.obs;
  TextEditingController commentTextEditing = TextEditingController();
  RxBool commentsLoading = false.obs;
  RxBool detailsPage = false.obs;
  late BuildContext context;

  @override
  void dispose() {
    commentTextEditing.dispose();
    super.dispose();
  }

  getPost() async {
    if (postComments.length == 0) {
      commentsLoading.value = true;
    }
    await Future.delayed(Duration(milliseconds: 350));
    Map<String, dynamic>? response = await ApiService()
        .request('posts/${post.value.slug}', {}, 'GET', withToken: true);
    if (response != null) {
      post.value.postLikesCount = response['post_likes_count'];
      post.value.commentsCount = response['comments_count'];
      post.value.isLiked = response['is_liked'];
      post.value.unlocked = response['unlocked'];
      post.value.sharesCount = response['shares_count'];
      post.refresh();
      await getPostComments();
      commentsLoading.value = false;
    } else {
      Navigator.pop(context);
    }
  }

  goToMaxScroll(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  deleteComment(int commentID) {
    postComments
        .removeWhere((Rx<Comment> element) => element.value.id == commentID);
    if (post.value.commentsCount > 0) {
      post.value.commentsCount--;
      post.refresh();
    }
    ApiService().request(
        'posts/${post.value.slug}/comments/$commentID', {}, 'DELETE',
        withToken: true);
  }

  getPostComments() async {
    Map<String, dynamic>? response = await ApiService().request(
        'posts/${post.value.slug}/comments?page=$commentPage', {}, 'GET',
        withToken: true);

    if (response != null && response['data'].length > 0) {
      List<Rx<Comment>> comments = [];
      for (Map<String, dynamic> c in response['data']) {
        Rx<Comment> existing = postComments.firstWhere(
            (element) => element.value.id == c['id'],
            orElse: () => Comment.empty().obs);
        if (existing.value.id == 0) {
          comments.add(Comment.fromJson(c).obs);
        }
      }
      postComments.addAll(comments);
      postComments.refresh();
      nextPageUrl = response['next_page_url'];
    }
  }

  Future refreshComments() async {
    commentPage = 1;
    await getPostComments();
  }

  Future nextPageComments() async {
    if (nextPageUrl != null) {
      Uri uri = Uri.dataFromString(nextPageUrl!);
      String? nextPage = uri.queryParameters['page'];
      if (nextPage != null) {
        commentPage = int.parse(nextPage);
        await getPostComments();
      }
    }
  }

  likePost(bool isLiked) async {
    post.value.isLiked = isLiked;
    int postLikesCount = post.value.postLikesCount;
    if (isLiked == false) {
      postLikesCount = postLikesCount <= 1 ? 0 : postLikesCount - 1;
    } else {
      postLikesCount += 1;
    }
    post.value.postLikesCount = postLikesCount;
    post.refresh();
    Map<String, dynamic> response = await ApiService().request(
        'posts/likes', {'slug': '${post.value.slug}'}, 'POST',
        withToken: true);
    post.value.postLikesCount = response['count'];
    post.value.isLiked = response['is_liked'];
    post.refresh();
  }

  deletePost() async {
    await ApiService()
        .request('posts/${post.value.slug}', {}, 'DELETE', withToken: true);
  }

  Future addComment(context) async {
    if (newComment.value.length == 0) return;

    AuthController authController = Get.find<AuthController>();
    commentTextEditing.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String> comment = {
      'slug': post.value.slug,
      'comment': newComment.value
    };
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Comment pendingComment = new Comment(
        id: timestamp,
        deletable: false,
        isLiked: false,
        createdAt: DateTime.now().toString(),
        commentLikesCount: 0,
        user: authController.user!,
        comment: newComment.value);
    postComments.add(pendingComment.obs);
    newComment.value = '';
    Map<String, dynamic>? response = await ApiService().request(
        'posts/${post.value.slug}/comments', comment, 'POST',
        withToken: true);
    if (response != null) {
      postComments.add(Comment.fromJson(response).obs);
      post.value.commentsCount++;
      post.refresh();
    }
    postComments
        .removeWhere((element) => element.value.id == pendingComment.id);
  }
}
