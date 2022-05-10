import 'package:alterr/controllers/feed.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:alterr/utils/report_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';

class FeedCardHeader extends StatelessWidget {
  final String? userPicture;
  final String? dateTime;
  final String? userName;
  final String? slug;
  final bool? editable;
  final bool? isPublic;
  final Function()? onUserTapped;
  final BuildContext? context;
  final bool hideOptions;
  FeedCardHeader(
      {Key? key,
      this.userPicture,
      this.dateTime,
      this.userName,
      this.editable = false,
      this.isPublic = true,
      this.slug,
      this.context,
      this.onUserTapped,
      this.hideOptions = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fromNow = timeago
        .format(DateTime.parse(dateTime!), locale: 'en_short')
        .replaceAll('~', '');

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      GestureDetector(
          onTap: () => onUserTapped!(),
          child: ProfilePicture(
            source: userPicture,
            radius: 18,
          )),
      SizedBox(width: 10),
      Transform.translate(
        offset: Offset(0, -1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onUserTapped!(),
              child: Text(userName!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(fromNow,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.black45,
                        fontWeight: FontWeight.normal)),
                SizedBox(
                  width: 15,
                  child: Text(
                    '•',
                    style: TextStyle(color: Colors.black26, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  isPublic == true ? FeatherIcons.globe : FeatherIcons.lock,
                  color: Colors.black45,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
      Spacer(),
      hideOptions
          ? SizedBox.shrink()
          : GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 0, color: Colors.transparent)),
                padding: EdgeInsets.only(bottom: 7, left: 7),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    FeatherIcons.moreHorizontal,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              ),
              onTap: () => {postActions(context)},
            ),
    ]);
  }

  postActions(context) {
    List<Widget> options = [];
    if (editable!) {
      options.add(InkWell(
        onTap: () {
          confirmDeletePost(slug);
        },
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(
                FeatherIcons.trash2,
                size: 22,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                'Delete post',
                style: TextStyle(fontSize: 15.5),
              )
            ],
          ),
        ),
      ));
    } else {
      options.add(InkWell(
        onTap: () {
          navigator?.pop();
          Get.put(ReportContent())
              .showModalReport(context, type: 'Post', name: slug!);
        },
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
                'Report this post',
                style: TextStyle(fontSize: 15.5),
              )
            ],
          ),
        ),
      ));
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

  confirmDeletePost(slug) {
    navigator?.pop();
    PlatformAlertDialog(
      title: 'Delete Post',
      content: 'Are you sure you want to delete this post?',
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
            if (context != null) {
              Navigator.pop(context!);
            }
            Get.find<FeedController>().deletePost(slug);
          },
        ),
      ],
    ).show();
  }
}
