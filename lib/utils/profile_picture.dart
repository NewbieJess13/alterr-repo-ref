import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatefulWidget {
  final String? source;
  final double? radius;
  ProfilePicture({Key? key, this.source, this.radius = 10}) : super(key: key);

  @override
  ProfilePictureState createState() => ProfilePictureState();
}

class ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return widget.source?.isNotEmpty == true
        ? CachedNetworkImage(
            fadeInDuration: Duration(seconds: 0),
            placeholderFadeInDuration: Duration(seconds: 0),
            fadeOutDuration: Duration(seconds: 0),
            imageUrl: widget.source!,
            imageBuilder: (context, imageProvider) => new CircleAvatar(
                radius: widget.radius,
                backgroundImage: imageProvider,
                backgroundColor: Colors.grey[200]),
            errorWidget: (context, url, error) => CircleAvatar(
                radius: widget.radius,
                backgroundImage:
                    AssetImage('assets/images/profile-placeholder.png')),
            placeholder: (context, string) => CircleAvatar(
                radius: widget.radius,
                backgroundImage:
                    AssetImage('assets/images/profile-placeholder.png')),
          )
        : CircleAvatar(
            radius: widget.radius,
            backgroundImage:
                AssetImage('assets/images/profile-placeholder.png'));
  }
}
