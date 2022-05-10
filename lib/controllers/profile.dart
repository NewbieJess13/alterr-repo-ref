import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/services/api.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

class ProfileController extends GetxController {
  RxList<dynamic> followers = <dynamic>[].obs;
  RxList<dynamic> following = <dynamic>[].obs;
  RxList<Rx<Post>> posts = <Rx<Post>>[].obs;
  RxList<dynamic> media = <dynamic>[].obs;
  Rx<User> user = User.empty().obs;
  RxBool isFollowed = false.obs;
  RxInt screenIndex = 0.obs;
  ScrollController scrollController = ScrollController();
  RxInt followTabIndex = 0.obs;
  RxInt followersCount = 0.obs;
  RxInt followingCount = 0.obs;
  RxBool followButtonLoading = false.obs;
  RxBool isFollower = false.obs;
  RxString activeTab = 'posts'.obs;

  getProfile(int userID) async {
    await Future.delayed(Duration(milliseconds: 350));
    Map<String, dynamic>? response =
        await ApiService().request('users/$userID', {}, 'GET', withToken: true);

    if (response != null) {
      posts.clear();
      media.clear();

      followers.value = response['followers'];
      following.value = response['following'];
      user.value = User.fromJson(response);
      user.refresh();
      isFollowed.value = response['isFollowed'];
      isFollower.value = response['isFollower'];

      followersCount.value = followers.length;
      followingCount.value = following.length;

      List<Rx<Post>> postsData = [];
      for (Map<String, dynamic> post in response['posts']) {
        postsData.add(Post.fromJson(post).obs);
      }
      posts.addAll(postsData);
      posts.refresh();

      List<Rx<Post>> mediaData = [];
      for (Map<String, dynamic> post in response['posts']) {
        if (post['type'] == 'photo' || post['type'] == 'video') {
          mediaData.add(Post.fromJson(post).obs);
        }
      }
      media.addAll(mediaData);
      media.refresh();
    }
  }

  followUser() async {
    followButtonLoading.value = true;
    bool follow = !isFollowed.value;
    if (follow) {
      followersCount++;
    } else if (followersCount > 0) {
      followersCount--;
    }
    isFollowed.value = follow;
    Map<String, dynamic>? response = await ApiService().request(
        'followers', {'username': user.value.username.toString()}, "POST",
        withToken: true);
    if (response != null) {
      followers.value = response['followers'];
      following.value = response['following'];
      isFollowed.value = response['isFollowed'];
      followersCount.value = followers.length;
      followingCount.value = following.length;
    }
    followButtonLoading.value = false;
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
}
