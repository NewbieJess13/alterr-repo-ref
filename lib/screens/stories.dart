// import 'dart:convert';
// import 'dart:ui';
// import 'package:alterr/controllers/stories.dart';
// import 'package:alterr/models/story.dart';
// import 'package:alterr/utils/circle_avatar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:story_view/story_view.dart';

// class StoriesScreen extends StatelessWidget {
//   final StoryController swipeController = StoryController();
//   final StoriesController controller = Get.put(StoriesController());
//   final Rx<UsersStories> storyOwner = Rx<UsersStories>(null);
//   final PageController pageController =
//       PageController(initialPage: Get.arguments['index']);
//   @override
//   Widget build(BuildContext context) {
//     int startingIndex = Get.arguments['index'];
//     return Scaffold(
//       body: Container(
//         child: Obx(() {
//           return PageView.builder(
//               controller: pageController,
//               itemCount: controller.usersStories.length,
//               itemBuilder: (context, index) {
//                 storyOwner.value = controller.usersStories[index].value;
//                 return controller.usersStories[index].value.stories.length > 0
//                     ? Stack(
//                         children: [
//                           StoryView(
//                             controller: swipeController,
//                             storyItems: List.generate(
//                                 storyOwner.value.stories.length, (index) {
//                               final Map<String, dynamic> story =
//                                   storyOwner.value.stories[index];
//                               Map<String, dynamic> metadata = {};
//                               List durationParts = [];
//                               if (story['type'] == 'video') {
//                                 if (story['metadata'].isNotEmpty) {
//                                   metadata = jsonDecode(story['metadata']);
//                                   durationParts =
//                                       metadata['duration'].split(':');
//                                 }
//                               }

//                               return story['type'] == 'video'
//                                   ? StoryItem.pageVideo(story['source'],
//                                       controller: swipeController,
//                                       duration: Duration(
//                                           seconds: int.parse(durationParts[1])))
//                                   : StoryItem.pageImage(
//                                       url: story['source'],
//                                       controller: swipeController,
//                                       duration: Duration(seconds: 5),
//                                     );
//                             }),
//                             onComplete: () {
//                               if (index + 1 == controller.usersStories.length) {
//                                 navigator.pop();
//                               } else {
//                                 pageController.nextPage(
//                                     duration: Duration(seconds: 1),
//                                     curve: Curves.fastLinearToSlowEaseIn);
//                               }
//                             },
//                             onVerticalSwipeComplete: (Direction direction) {
//                               if (direction == Direction.down) {
//                               } else if (direction == Direction.up) {
//                                 storyOwner.value = controller
//                                     .usersStories[startingIndex + 1].value;
//                                 storyOwner.refresh();
//                               }
//                             },
//                             inline: true,
//                           ),
//                           Positioned(
//                             left: 10,
//                             top: 80,
//                             child: Row(children: [
//                               CircleImageAvatar(
//                                 image: storyOwner.value.profilePicture,
//                                 radius: 14,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 storyOwner.value.username,
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white),
//                               ),
//                             ]),
//                           )
//                         ],
//                       )
//                     : null;
//               });
//         }),
//       ),
//     );
//   }
// }
