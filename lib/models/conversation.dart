class Conversation {
  final List messages;
  final Map<String, dynamic> user;
  Conversation({
    this.messages = const [],
    this.user = const {},
  });

  factory Conversation.fromJson(json) {
    return Conversation(
      messages: json['messages']['data'].reversed.toList(),
      user: json['user'],
    );
  }
}
