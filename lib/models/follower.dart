import 'package:alterr/models/user.dart';

class Follower {
  int id;
  int userId;
  int followerId;
  bool isFollowed;
  int userCount;
  User user;

  Follower(
      {required this.id,
      required this.userId,
      required this.followerId,
      required this.isFollowed,
      required this.userCount,
      required this.user});

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
        id: json['id'],
        userId: json['user_id'],
        followerId: json['follower_id'],
        isFollowed: json['is_followed'],
        userCount: json['user_count'],
        user: User.fromJson(
            json.containsKey('user') ? json['user'] : json['user_following']));
  }
}
