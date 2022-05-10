import 'dart:convert';

import 'package:alterr/models/user.dart';

class Post {
  String slug;
  String caption;
  int postLikesCount;
  int commentsCount;
  int? views;
  String createdAt;
  String type;
  String? thumbnail;
  String? source;
  String? preview;
  User user;
  bool editable;
  bool unlocked;
  bool isLiked;
  String? color;
  String price;
  bool isPublic;
  bool isSensitive;
  Map<String, dynamic>? metadata;
  List<dynamic>? mentions;
  Map<String, dynamic>? linkPreview;
  int? sharesCount;
  Map<String, dynamic>? parent;

  Post(
      {required this.slug,
      required this.caption,
      required this.createdAt,
      required this.type,
      required this.price,
      required this.isPublic,
      required this.isSensitive,
      required this.user,
      this.postLikesCount = 0,
      this.commentsCount = 0,
      this.views,
      this.thumbnail,
      this.source,
      this.preview,
      this.editable = false,
      this.unlocked = false,
      this.isLiked = false,
      this.color,
      this.metadata,
      this.mentions,
      this.sharesCount = 0,
      this.parent,
      this.linkPreview});
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        slug: json['slug'],
        caption: json['caption'],
        postLikesCount: json['post_likes_count'] ?? 0,
        commentsCount: json['comments_count'] ?? 0,
        views: json['views'],
        createdAt: json['created_at'],
        type: json['type'],
        thumbnail: json['thumbnail'],
        source: json['source'],
        preview: json['preview'],
        editable: json['editable'] ?? false,
        unlocked: json['unlocked'] ?? false,
        isLiked: json['is_liked'] ?? false,
        color: json['color'],
        price: json['price'],
        isPublic: json['is_public'] ?? false,
        isSensitive: json['is_sensitive'],
        metadata: json['metadata'],
        user: User.fromJson(json['user']),
        mentions: json['mentions'],
        sharesCount: json['shares_count'] ?? 0,
        parent: json['parent'] != null ? json['parent'] : null,
        linkPreview: json['link_preview']);
  }

  factory Post.empty() {
    return Post(
      slug: '',
      caption: '',
      postLikesCount: 0,
      commentsCount: 0,
      createdAt: '',
      type: '',
      editable: false,
      unlocked: false,
      isLiked: false,
      price: '',
      isPublic: true,
      isSensitive: false,
      sharesCount: 0,
      user: User.empty(),
    );
  }
}
