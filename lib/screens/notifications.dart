import 'package:alterr/controllers/notification.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/models/notification.dart' as modelNotif;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:swipeable_page_route/swipeable_page_route.dart';

// ignore: must_be_immutable
class NotificationsScreen extends StatelessWidget {
  NotificationController controller = Get.put(NotificationController());
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Widget notifScreen = Container();

  @override
  Widget build(BuildContext context) {
    return _notifications(context);
  }

  Widget _notifications(context) => Scaffold(
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
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                ),
                title: 'Notifications')
            .build(),
        body: Obx(
          () => SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () async {
              await controller.refreshNotifications();
              _refreshController.refreshCompleted();
            },
            onLoading: () async {
              await controller.nextPageNotifications();
              _refreshController.loadComplete();
            },
            child: controller.notifications.length == 0
                ? Center(
                    child: Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.black26, fontSize: 17),
                  ))
                : ListView.builder(
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final modelNotif.Notification notification =
                          controller.notifications[index].value;

                      return InkWell(
                        onTap: () {
                          if (notification.post != null) {
                            Navigator.of(context).push<void>(SwipeablePageRoute(
                                builder: (_) => PostScreen(
                                      post: notification.post!,
                                    )));
                          } else {
                            Navigator.of(context).push<void>(SwipeablePageRoute(
                                builder: (_) => ProfileScreen(
                                      user: notification.user,
                                      leading: true,
                                    )));
                          }
                          controller.updateStatus(notification.id);
                        },
                        child: NotificationTile(
                          notification: notification,
                        ),
                      );
                    },
                  ),
          ),
        ),
      );
}

class NotificationTile extends StatelessWidget {
  final modelNotif.Notification notification;

  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fromNow = timeago
        .format(DateTime.parse(notification.dateTime), locale: 'en_short')
        .replaceAll('~', '');
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
        color: notification.hasRead
            ? Colors.white30
            : Colors.blue.withOpacity(.075),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        notification.user.profilePicture != null &&
                notification.user.profilePicture != ''
            ? CachedNetworkImage(
                fadeInDuration: Duration(seconds: 0),
                placeholderFadeInDuration: Duration(seconds: 0),
                fadeOutDuration: Duration(seconds: 0),
                imageUrl: notification.user.profilePicture!,
                imageBuilder: (context, imageProvider) => new CircleAvatar(
                    radius: 17,
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.grey[200]),
                errorWidget: (context, url, error) => CircleAvatar(
                    radius: 17,
                    backgroundImage:
                        AssetImage('assets/images/profile-placeholder.png')),
                placeholder: (context, string) => CircleAvatar(
                    radius: 17,
                    backgroundImage:
                        AssetImage('assets/images/profile-placeholder.png')),
              )
            : CircleAvatar(
                radius: 17,
                backgroundImage:
                    AssetImage('assets/images/profile-placeholder.png')),
        const SizedBox(width: 7.5),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, -1),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: notification.eventUser['username'] + ' ',
                    style: TextStyle(
                        fontSize: 15.5,
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: Colors.black)),
                TextSpan(
                    text: notification.label,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.1,
                      color: Colors.black,
                      fontFamily: 'Helvetica Neue',
                    )),
              ])),
              SizedBox(
                height: 4,
              ),
              Text(
                fromNow,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.5,
                    color: Colors.black54),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
