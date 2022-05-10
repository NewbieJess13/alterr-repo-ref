class User {
  int id;
  String username;
  String? email;
  String? profilePicture;
  String? bio;
  String? birthdate;
  String createdAt;
  Settings? settings;
  Map<String, dynamic>? bank;
  Map<String, dynamic>? apiKeys;
  User(
      {required this.id,
      required this.username,
      required this.email,
      this.profilePicture,
      this.bio,
      this.apiKeys,
      this.bank,
      required this.birthdate,
      required this.createdAt,
      required this.settings});

  factory User.fromJson(json) {
    return User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        profilePicture: json['profile_picture'],
        bio: json['bio'],
        apiKeys: json['api_keys'],
        bank: json['bank'],
        birthdate: json['birthdate'],
        createdAt: json['created_at'],
        settings: json['user_setting'] != null
            ? Settings.fromJson(json['user_setting']['settings'])
            : null);
  }

  factory User.empty() {
    return User(
        id: 0,
        username: '',
        email: '',
        birthdate: '',
        createdAt: '',
        settings: null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['profile_picture'] = this.profilePicture;
    data['bio'] = this.bio;
    data['api_keys'] = this.apiKeys;
    data['bank'] = this.bank;
    data['birthdate'] = this.birthdate;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Settings {
  String? newMessage;
  String? postLike;
  String? postComment;
  String? postUnlock;
  String? commentLike;

  Settings(
      {this.newMessage,
      this.postLike,
      this.postComment,
      this.postUnlock,
      this.commentLike});

  factory Settings.fromJson(json) {
    return Settings(
        newMessage: json['new_message'],
        postLike: json['post_like'],
        postComment: json['post_comment'],
        postUnlock: json['post_unlock'],
        commentLike: json['comment_like']);
  }

  Map<String, String?> toJson() {
    final Map<String, String?> data = new Map<String, String?>();
    data['new_message'] = this.newMessage;
    data['post_like'] = this.postLike;
    data['post_comment'] = this.postComment;
    data['post_unlock'] = this.postUnlock;
    data['comment_like'] = this.commentLike;
    return data;
  }
}
