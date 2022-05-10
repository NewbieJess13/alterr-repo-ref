class UsersStories {
  List<dynamic> stories;

  String username;
  String? profilePicture;
  UsersStories(
      {this.stories = const [], required this.username, this.profilePicture});

  factory UsersStories.fromJson(json) {
    return UsersStories(
        stories: json['stories'],
        username: json['username'],
        profilePicture: json['profile_picture']);
  }
}

class Story {
  String thumbnail;
  String source;

  Story({required this.thumbnail, required this.source});

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(thumbnail: json['thumbnail'], source: json['source']);
  }
}
