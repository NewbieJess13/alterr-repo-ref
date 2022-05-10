import 'package:alterr/utils/create_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:alterr/utils/alterr_icons.dart';
import 'package:alterr/utils/send_post_as_message.dart';
import 'package:alterr/models/post.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

class FeedCardFooter extends StatelessWidget {
  final String? likes;
  final String? comments;
  final bool? isLiked;
  final String? views;
  final Function()? onLikeTap;
  final Function()? onCommentTap;
  final Rx<Post>? post;
  FeedCardFooter(
      {Key? key,
      this.likes,
      this.comments,
      this.views,
      this.onLikeTap,
      this.onCommentTap,
      this.post,
      this.isLiked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double topPadding = (post?.value.linkPreview != null &&
                post?.value.linkPreview!['image'] != null &&
                post?.value.linkPreview!['image'] != '') ||
            (post?.value.type == 'photo' || post?.value.type == 'video')
        ? 12
        : 0;
    return Column(
      children: [
        int.parse(likes!) > 0 || int.parse(comments!) > 0
            ? Container(
                padding: EdgeInsets.only(
                    bottom: 12, left: 15, right: 15, top: topPadding),
                child: Row(
                  children: [
                    int.parse(likes!) > 0
                        ? Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Text(
                              '$likes like' +
                                  (int.parse(likes!) > 1 ? 's' : ''),
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15.5),
                            ),
                          )
                        : Container(),
                    int.parse(comments!) > 0
                        ? Text(
                            '$comments comment' +
                                (int.parse(comments!) > 1 ? 's' : ''),
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15.5),
                          )
                        : Container(),
                    Spacer(),
                    post!.value.sharesCount! > 0
                        ? Text(
                            '${post!.value.sharesCount.toString()} share' +
                                (post!.value.sharesCount! > 1 ? 's' : ''),
                            style: TextStyle(
                                color: Colors.black54, fontSize: 15.5),
                          )
                        : Container(),
                  ],
                ),
              )
            : Container(),
        Container(
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05)),
          )),
          padding: EdgeInsets.all(7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LikeButton(
                isLiked: isLiked,
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
                          offset: Offset(0, -0.5),
                          child: Icon(AlterrIcons.heart_red,
                              size: 24, color: Colors.red[600]),
                        )
                      : Transform.translate(
                          offset: Offset(0, -1.5),
                          child: Icon(
                            FeatherIcons.heart,
                            color: Colors.black87,
                            size: 22,
                          ),
                        );
                },
                onTap: onLikeButtonTapped,
              ),
              InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onCommentTap!,
                  child: Container(
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.all(3),
                      child: Transform.translate(
                        offset: Offset(0, -1.5),
                        child: Icon(
                          FeatherIcons.messageCircle,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ))),
              InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => rePost(context),
                  child: Container(
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.all(3),
                      child: Transform.translate(
                        offset: Offset(-0.5, -0.5),
                        child: Icon(
                          FeatherIcons.rotateCw,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ))),
              InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => {
                        SendPostAsMessage(post: post!.value)
                            .showModalBottomSheet(context)
                      },
                  child: Container(
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.all(3),
                      child: Transform.translate(
                        offset: Offset(0, -1.5),
                        child: Icon(
                          FeatherIcons.share,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ))),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    onLikeTap!();
    return !isLiked;
  }

  void rePost(BuildContext context) {
    return CreatePost().open(post: post!.value);
  }
}
