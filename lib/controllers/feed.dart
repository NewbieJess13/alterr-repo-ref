import 'dart:io';
import 'package:alterr/services/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/controllers/profile.dart';
import 'package:alterr/controllers/auth.dart';

class FeedController extends GetxController {
  RxList<Rx<Post>> posts = <Rx<Post>>[].obs;
  RxList pendingPosts = [].obs;

  Rx<File?> mediaFile = Rx<File?>(null);
  RxString isPublic = '0'.obs;

  Rx<bool> showPhotoSource = Rx<bool>(false);

  RxBool loading = true.obs;
  String? nextPageUrl;
  String cursor = '';
  Rx<bool> detailsPage = false.obs;
  ScrollController scrollController = ScrollController();

  showImageSourceSelection() {
    showPhotoSource.value = !showPhotoSource.value;
    update();
  }

  removeMedia() {
    mediaFile.value = null;
    update();
  }

  likePost(String slug, bool isLiked) async {
    Rx<Post> post = posts.firstWhere((element) => element.value.slug == slug);
    post.value.isLiked = isLiked;
    int postLikesCount = post.value.postLikesCount;
    if (!isLiked) {
      postLikesCount = postLikesCount <= 1 ? 0 : postLikesCount--;
    } else {
      postLikesCount += 1;
    }
    post.value.postLikesCount = postLikesCount;
    post.refresh();
    Map<String, dynamic> response = await ApiService()
        .request('posts/likes', {'slug': '$slug'}, 'POST', withToken: true);
    post.value.postLikesCount = response['count'];
    post.value.isLiked = response['is_liked'];
    post.refresh();
  }

  deletePost(String slug) async {
    await ApiService()
        .request('posts/$slug', {}, 'DELETE', withToken: true)
        .then((value) {
      posts.removeWhere((element) => element.value.slug == slug);
      ProfileController? profileController = Get.put(ProfileController(),
          tag: 'profile_${Get.find<AuthController>().user?.id}');
      if (profileController != null) {
        profileController.posts
            .removeWhere((element) => element.value.slug == slug);
      }
    });
  }

  Future getFeedPosts({bool clear = true}) async {
    Map<String, dynamic>? postsData = await ApiService()
        .request('posts/feed?cursor=$cursor', {}, 'GET', withToken: true);

    if (clear) {
      posts.clear();
    }
    if (postsData != null && postsData['data'].length > 0) {
      List<Rx<Post>> feedPosts = [];
      for (Map<String, dynamic> post in postsData['data']) {
        feedPosts.add(Post.fromJson(post).obs);
      }
      posts.addAll(feedPosts);
      posts.refresh();
      nextPageUrl = postsData['next_page_url'];
    }
    loading.value = false;
    loading.refresh();
  }

  Future refreshFeedPosts() async {
    cursor = '';
    await getFeedPosts();
  }

  Future nextPageFeedPosts() async {
    if (nextPageUrl != null) {
      Uri uri = Uri.dataFromString(nextPageUrl!);
      String? nextPageCursor = uri.queryParameters['cursor'];
      if (nextPageCursor != null) {
        cursor = nextPageCursor;
        await getFeedPosts(clear: false);
      }
    }
  }
}
