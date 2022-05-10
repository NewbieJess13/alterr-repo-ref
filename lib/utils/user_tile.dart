import 'package:alterr/models/follower.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final Follower? follower;

  const UserTile({Key? key, this.follower}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(children: [
        CircleAvatar(
            radius: 15,
            backgroundImage:
                CachedNetworkImageProvider(follower!.user.profilePicture!)),
        const SizedBox(width: 10),
        Text(
          follower!.user.username,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        )
      ]),
    );
  }
}
