import 'package:alterr/models/follower.dart';
import 'package:alterr/utils/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

class FollowersDialog extends StatelessWidget {
  final String? title;
  final List? contentList;

  const FollowersDialog({Key? key, this.title, this.contentList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetAnimationDuration: Duration(milliseconds: 50),
      insetPadding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints.expand(),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Spacer(),
                GestureDetector(
                    onTap: () => Get.back(), child: Icon(FeatherIcons.x))
              ],
            ),
            Divider(),
            Obx(() {
              return Expanded(
                child: ListView.builder(
                  itemCount: contentList?.length,
                  itemBuilder: (contxt, index) {
                    final Follower follower = contentList![index];
                    return UserTile(
                      follower: follower,
                    );
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
