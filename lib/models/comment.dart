import 'package:alterr/models/user.dart';

class Comment {
  int id;
  bool isLiked;
  String comment;
  int commentLikesCount;
  bool deletable;
  String createdAt;
  User user;

  Comment(
      {required this.id,
      required this.isLiked,
      required this.comment,
      required this.commentLikesCount,
      required this.deletable,
      required this.createdAt,
      required this.user});

  factory Comment.fromJson(json) {
    return Comment(
        id: json['id'],
        comment: json['comment'],
        isLiked: json['is_liked'] ?? false,
        commentLikesCount: json['comment_likes_count'],
        deletable: json['deletable'],
        createdAt: json['created_at'],
        user: User.fromJson(json['user']));
  }

  factory Comment.empty() {
    return Comment(
        id: 0,
        comment: '',
        isLiked: false,
        commentLikesCount: 0,
        deletable: false,
        createdAt: '',
        user: User.empty());
  }
}
