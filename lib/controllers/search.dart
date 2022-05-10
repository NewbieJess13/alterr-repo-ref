import 'dart:convert';
import 'package:alterr/models/post.dart';
import 'package:alterr/services/api.dart';
import 'package:alterr/services/localstorage.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  RxList<Map<String, dynamic>> searchSuggestions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> recentSearchedList =
      <Map<String, dynamic>>[].obs;
  RxList<Post> postSearchResults = <Post>[].obs;
  RxList<Post> relatedPostTags = <Post>[].obs;
  Rx<FocusNode> searchFocus = FocusNode().obs;
  TextEditingController searchTextController = TextEditingController();
  Rx<bool> detailsPage = false.obs;
  Rx<bool> searchFocused = false.obs;
  Rx<bool> loading = false.obs;
  Rx<bool> showtagSearch = false.obs;
  ScrollController scrollController = ScrollController();

  getPostByTags(tag) async {
    List<dynamic> response = await ApiService()
        .request('posts/tags/$tag', {}, 'GET', withToken: true);
    if (response != null) {
      relatedPostTags.clear();
      for (Map<String, dynamic> post in response) {
        relatedPostTags.add(Post.fromJson(post));
      }
      relatedPostTags.refresh();
    }
  }

  getPopularPosts() async {
    List<dynamic>? response =
        await ApiService().request('posts/popular', {}, 'GET', withToken: true);
    if (response != null) {
      postSearchResults.clear();
      for (Map<String, dynamic> post in response) {
        postSearchResults.add(Post.fromJson(post));
      }
      postSearchResults.refresh();
    }
  }

  Future getSuggestions(String keyword) async {
    searchSuggestions.clear();
    loading.value = true;
    List<dynamic> listResult = await ApiService()
        .request('users?query=$keyword', {}, 'GET', withToken: true);
    if (listResult.length == 0) {
      searchSuggestions.clear();
    }
    for (Map<String, dynamic> suggestion in listResult) {
      bool toAdd = true;

      if (searchSuggestions
          .map((item) => item['username'])
          .contains(suggestion['username'])) {
        toAdd = false;
      }
      searchSuggestions.addIf(toAdd, suggestion);
    }
    searchSuggestions.refresh();
    loading.value = false;
  }

  getRecentSearches() async {
    String? recentSearches = await LocalStorage.getRecentSearchesSharedPref();
    if (recentSearches != null) {
      for (Map<String, dynamic> recent in jsonDecode(recentSearches)) {
        bool toAdd = true;

        if (recentSearchedList
            .map((item) => item['username'])
            .contains(recent['username'])) {
          toAdd = false;
        }
        recentSearchedList.addIf(toAdd, recent);
      }
      recentSearchedList.refresh();
    }
  }

  saveToRecents(Map<String, dynamic> searchedData) async {
    String? recentSearches = await LocalStorage.getRecentSearchesSharedPref();
    List recentSearchesList = [];
    if (recentSearches == null) recentSearches = '[]';
    if (jsonDecode(recentSearches) is List) {
      recentSearchesList = jsonDecode(recentSearches);
      bool toAdd = true;
      if (recentSearchesList
          .map((item) => item['username'])
          .contains(searchedData['username'])) {
        toAdd = false;
      }
      recentSearchesList.addIf(toAdd, searchedData);
    }
    // encode recents
    LocalStorage.saveRecentSearchesSharedPref(jsonEncode(recentSearchesList));
    recentSearchedList
      ..add(searchedData)
      ..refresh();
  }

  deleteFromRecents(String username) async {
    int index = recentSearchedList
        .indexWhere((element) => element['username'] == username);
    recentSearchedList
      ..removeAt(index)
      ..refresh();
    LocalStorage.saveRecentSearchesSharedPref(jsonEncode(recentSearchedList));
  }

  @override
  void dispose() {
    searchTextController.dispose();
    searchFocus.value.dispose();
    super.dispose();
  }
}
