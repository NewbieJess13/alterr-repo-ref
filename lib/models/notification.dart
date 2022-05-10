import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Notification {
  int id;
  String label;
  Map<String, dynamic> eventUser;
  bool hasRead;
  String dateTime;
  User user;
  Rx<Post>? post;
  Notification(
      {required this.id,
      required this.label,
      required this.eventUser,
      required this.hasRead,
      required this.dateTime,
      required this.user,
      this.post});

  factory Notification.fromJson(json) {
    return Notification(
        id: json['id'],
        label: json['label'],
        eventUser: json['event_user'],
        hasRead: json['is_read'],
        dateTime: json['created_at'],
        user: new User.fromJson(json['event_user']),
        post:
            json['post'] != null ? new Post.fromJson(json['post']).obs : null);
  }
}
