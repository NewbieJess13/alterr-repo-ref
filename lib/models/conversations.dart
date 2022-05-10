import 'package:alterr/models/user.dart';

class Conversations {
  int id;
  String sendText;

  RecentMessage? recentMessage;
  User user;
  Conversations(
      {required this.recentMessage,
      required this.id,
      required this.user,
      required this.sendText});

  factory Conversations.fromJson(Map<String, dynamic> json) {
    return Conversations(
        id: json['id'],
        recentMessage: json['recent_message'] != null
            ? RecentMessage.fromJson(
                json['recent_message'],
              )
            : null,
        user: User.fromJson(json['user']),
        sendText: 'Send');
  }
}

class RecentMessage {
  int id;
  String message;
  String? source;
  String? thumbnail;
  String type;
  String createdAt;
  String? deletedAt;
  bool isSeen;
  Map<String, dynamic> user;
  RecentMessage({
    required this.id,
    required this.message,
    required this.source,
    required this.thumbnail,
    required this.type,
    required this.createdAt,
    this.deletedAt,
    required this.isSeen,
    required this.user,
  });

  factory RecentMessage.fromJson(Map<String, dynamic> json) {
    return RecentMessage(
      id: json['id'],
      message: json['message'],
      source: json['source'],
      thumbnail: json['thumbnail'],
      type: json['type'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      isSeen: json['is_read'],
      user: json['user'],
    );
  }
}
