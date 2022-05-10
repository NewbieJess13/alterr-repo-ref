import 'package:alterr/controllers/search.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:alterr/screens/post.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

// ignore: must_be_immutable
class SearchScreen extends StatefulWidget {
  final String? postTag;

  const SearchScreen({Key? key, this.postTag}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Widget contentScreen = Container();
  SearchController controller = Get.put(SearchController());
  @override
  void initState() {
    super.initState();
    final debouncer =
        Debouncer<String>(Duration(milliseconds: 300), initialValue: '');
    controller.searchTextController.addListener(() {
      debouncer.value = controller.searchTextController.text;
    });
    debouncer.values.listen((searchKey) {
      if (searchKey.length > 0) {
        if (searchKey[0] == '#') {
          if (searchKey.trim().length > 2) {
            controller.showtagSearch.value = true;
            controller.getPostByTags(searchKey.replaceFirst(RegExp(r'#'), ''));
          }
        } else {
          if (searchKey.trim().length >= 2) {
            controller.showtagSearch.value = false;
            controller.getSuggestions(searchKey);
          }
        }
      }
    });
    controller.getPopularPosts();
  }

  @override
  Widget build(BuildContext context) {
    return _searchScreen(context);
  }

  Widget _searchScreen(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                widget.postTag != '' && widget.postTag != null
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: Icon(
                            FeatherIcons.arrowLeft,
                            color: Colors.black45,
                            size: 22,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                Expanded(
                  child: Obx(() => CustomTextField(
                        autofocus: false,
                        title: 'Search Alterr',
                        controller: controller.searchTextController,
                        focusNode: controller.searchFocus.value,
                        onTap: () {
                          controller.searchFocus.refresh();
                          controller.searchFocused.value = true;
                        },
                        onChanged: (val) {
                          controller.searchFocus.refresh();
                        },
                        suffixTap: () {
                          controller
                            ..searchSuggestions.clear()
                            ..searchTextController.clear()
                            ..relatedPostTags.clear()
                            ..searchFocus.refresh();
                        },
                        suffixIcon: controller.searchTextController.text
                                    .toString()
                                    .trim()
                                    .length >
                                0
                            ? Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Transform.translate(
                                  offset: Offset(0, -0.3),
                                  child: Icon(
                                    FeatherIcons.x,
                                    size: 16,
                                  ),
                                ),
                              )
                            : Icon(
                                FeatherIcons.search,
                                color: Colors.black26,
                                size: 22,
                              ),
                      )),
                ),
                Obx(() => controller.searchFocused.value == true
                    ? Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            controller
                              ..searchSuggestions.clear()
                              ..searchTextController.clear()
                              ..searchFocus.refresh()
                              ..searchFocus.value.unfocus();
                            controller.searchFocused.value = false;
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : SizedBox.shrink())
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => Stack(
            children: [
              _popularPosts(),
              controller.searchFocused.value
                  ? controller.showtagSearch.value
                      ? _relatedTags()
                      : _searchResult()
                  : SizedBox.shrink()
            ],
          )),
    );
  }

  Widget _relatedTags() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: controller.loading.value == true
          ? Center(
              child: PlatformSpinner(
                width: 20,
                height: 20,
                strokeWidth: 2,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(
                    () => controller.relatedPostTags.isEmpty
                        ? Center(
                            child: Text(
                            'No matches found.',
                            style:
                                TextStyle(color: Colors.black26, fontSize: 17),
                          ))
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 1.0,
                              crossAxisSpacing: 1.0,
                            ),
                            itemCount: controller.relatedPostTags.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Rx<Post> post =
                                  controller.relatedPostTags[index].obs;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push<void>(SwipeablePageRoute(
                                          builder: (_) => PostScreen(
                                                post: post,
                                              )));
                                },
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      fadeInDuration: Duration(seconds: 0),
                                      placeholderFadeInDuration:
                                          Duration(seconds: 0),
                                      fadeOutDuration: Duration(seconds: 0),
                                      imageUrl: post.value.thumbnail!,
                                      fit: BoxFit.cover,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: imageProvider,
                                            )),
                                      ),
                                    ),
                                    post.value.type == 'video'
                                        ? Positioned(
                                            child: Center(
                                            child: Container(
                                              padding: EdgeInsets.all(7.0),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                              child: Transform.translate(
                                                offset: Offset(1, 0),
                                                child: Icon(
                                                  FeatherIcons.play,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ))
                                        : Container(),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _popularPosts() {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: SmartRefresher(
          scrollController: controller.scrollController,
          primary: false,
          onRefresh: () async {
            AssetsAudioPlayer.newPlayer().open(
              Audio("assets/sounds/refresh.mp3"),
            );
            HapticFeedback.mediumImpact();
            await controller.getPopularPosts();
            _refreshController.refreshCompleted();
          },
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
            ),
            itemCount: controller.postSearchResults.length,
            itemBuilder: (BuildContext context, int index) {
              final Rx<Post> post = controller.postSearchResults[index].obs;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push<void>(SwipeablePageRoute(
                      builder: (_) => PostScreen(
                            post: post,
                          )));
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color(int.parse('0xff${post.value.color}')),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  post.value.thumbnail!),
                              fit: BoxFit.cover)),
                    ),
                    post.value.type == 'video'
                        ? Positioned(
                            child: Center(
                            child: Container(
                              padding: EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Transform.translate(
                                offset: Offset(1, 0),
                                child: Icon(
                                  FeatherIcons.play,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ))
                        : Container(),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _searchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 7.5),
          child: Text('Recent', style: TextStyle(fontSize: 15)),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.recentSearchedList.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> recent =
                      controller.recentSearchedList[index];
                  return InkWell(
                    onTap: () {
                      // Get.toNamed('/profile',
                      //     parameters: {'username': recent['username']});
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0, color: Colors.transparent)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7.5, vertical: 7.5),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              fadeInDuration: Duration(seconds: 0),
                              placeholderFadeInDuration: Duration(seconds: 0),
                              fadeOutDuration: Duration(seconds: 0),
                              imageUrl: recent['profile_picture'],
                              imageBuilder: (context, imageProvider) =>
                                  new CircleAvatar(
                                      radius: 15,
                                      backgroundImage: imageProvider,
                                      backgroundColor: Colors.grey[200]),
                              errorWidget: (context, url, error) => CircleAvatar(
                                  radius: 15,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile-placeholder.png')),
                              placeholder: (context, string) => CircleAvatar(
                                  radius: 15,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile-placeholder.png')),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              recent['username'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Spacer(),
                            GestureDetector(
                                onTap: () {
                                  controller
                                      .deleteFromRecents(recent['username']);
                                },
                                child: Icon(
                                  FeatherIcons.x,
                                  size: 18.5,
                                  color: Colors.black54,
                                ))
                          ],
                        )),
                  );
                },
              )),
        ),
      ],
    );
  }

  Widget _searchResult() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: controller.loading.value == true
          ? Center(
              child: PlatformSpinner(
                width: 20,
                height: 20,
                strokeWidth: 2,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() => controller.searchSuggestions.isEmpty
                      ? Center(
                          child: Text(
                          'No matches found.',
                          style: TextStyle(color: Colors.black26, fontSize: 17),
                        ))
                      : ListView.builder(
                          itemCount: controller.searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final Map<String, dynamic> searchSuggestion =
                                controller.searchSuggestions[index];
                            User user = User.fromJson(searchSuggestion);
                            return GestureDetector(
                              onTap: () {
                                controller.saveToRecents(searchSuggestion);
                                Navigator.of(context)
                                    .push<void>(SwipeablePageRoute(
                                        builder: (_) => ProfileScreen(
                                              user: user,
                                              leading: true,
                                            )));
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0, color: Colors.transparent)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      searchSuggestion['profile_picture'] !=
                                                  null &&
                                              searchSuggestion[
                                                      'profile_picture'] !=
                                                  ''
                                          ? CachedNetworkImage(
                                              fadeInDuration:
                                                  Duration(seconds: 0),
                                              placeholderFadeInDuration:
                                                  Duration(seconds: 0),
                                              fadeOutDuration:
                                                  Duration(seconds: 0),
                                              imageUrl: searchSuggestion[
                                                  'profile_picture'],
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      new CircleAvatar(
                                                          radius: 18,
                                                          backgroundImage:
                                                              imageProvider,
                                                          backgroundColor:
                                                              Colors.grey[200]),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  CircleAvatar(
                                                      radius: 18,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/profile-placeholder.png')),
                                              placeholder: (context, string) =>
                                                  CircleAvatar(
                                                      radius: 18,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/profile-placeholder.png')),
                                            )
                                          : CircleAvatar(
                                              radius: 18,
                                              backgroundImage: AssetImage(
                                                  'assets/images/profile-placeholder.png')),
                                      SizedBox(width: 7.5),
                                      Expanded(
                                        child: Transform.translate(
                                          offset: Offset(0, -1.5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                searchSuggestion['username'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              searchSuggestion['bio'] != null &&
                                                      searchSuggestion['bio']
                                                              .trim()
                                                              .length >
                                                          0
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: 1.5),
                                                      child: Text(
                                                        searchSuggestion['bio'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            height: 1.2,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            );
                          },
                        )),
                ),
              ],
            ),
    );
  }

  Widget searchLoader() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 30,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15)),
                  )
                ],
              )),
        );
      },
    );
  }
}

// Text('Most Popular',
//     style: TextStyle(
//         fontSize: 20,
//         color: Colors.black,
//         fontWeight: FontWeight.bold))
