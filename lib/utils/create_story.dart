// import 'dart:io';
// import 'package:alterr/controllers/stories.dart';
// import 'package:alterr/utils/custom_button.dart';
// import 'package:alterr/utils/mediapicker.dart';
// import 'package:alterr/utils/platform_alert_dialog.dart';
// import 'package:alterr/utils/story_designer.dart';
// import 'package:alterr/utils/video_player.dart';
// import 'package:camera/camera.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:palette_generator/palette_generator.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:video_thumbnail/video_thumbnail.dart' as vidThumbnail;
// import 'package:video_trimmer/video_trimmer.dart';
// import 'package:alterr/globals.dart' as globals;

// // ignore: must_be_immutable
// class CreateStory extends StatelessWidget {
//   final CreateStoryController controller = Get.put(CreateStoryController());
//   final Widget child;

//   CreateStory({this.child});
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => showCreateStory(context),
//       child: child,
//     );
//   }

//   Widget storyEditingScreen(BuildContext context) {
//     return Container(
//         child: Center(
//       child: controller.story['type'] == 'video'
//           ? //VideoPlayer(videoFile: controller.story['source'])
//           Container()
//           : StoryDesigner(
//               filePath: controller.story['source'].path,
//             ),
//     ));
//   }

//   showCreateStory(BuildContext context) async {
//     controller.reset();

//     navigator.push(
//       new MaterialPageRoute<Null>(
//           fullscreenDialog: true,
//           maintainState: false,
//           builder: (BuildContext context) => Obx(
//                 () => Scaffold(
//                   backgroundColor: Colors.black,
//                   resizeToAvoidBottomInset: false,
//                   body: Stack(children: [
//                     controller.story['thumbnail'] != null
//                         ? storyEditingScreen(context)
//                         : controller.cameraController != null
//                             ? CameraPreview(controller.cameraController)
//                             : Center(
//                                 child: Text(
//                                   'Error: No camera detected',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 17.5,
//                                       fontWeight: FontWeight.w700),
//                                 ),
//                               ),
//                     SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               GestureDetector(
//                                 onTap: () async {
//                                   if (controller.story['thumbnail'] != null) {
//                                     controller.reset();
//                                   } else {
//                                     navigator.pop();
//                                   }
//                                 },
//                                 child: Icon(
//                                   FeatherIcons.x,
//                                   size: 30,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               controller.story['type'] == 'video'
//                                   ? GestureDetector(
//                                       onTap: () async {
//                                         Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                                 fullscreenDialog: true,
//                                                 builder: (context) =>
//                                                     VideoTrimmer(
//                                                         pickedFile: controller
//                                                             .story['source'])));
//                                       },
//                                       child: Icon(
//                                         FeatherIcons.scissors,
//                                         color: Colors.white,
//                                       ))
//                                   : SizedBox.shrink(),
//                             ]),
//                       ),
//                     ),
//                   ]),
//                   bottomNavigationBar: Container(
//                     height: AppBar().preferredSize.height + 20,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                     ),
//                     child: controller.story['thumbnail'] != null
//                         ? Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Spacer(),
//                               Flexible(
//                                 fit: FlexFit.tight,
//                                 child: CustomButton(
//                                   label: 'Add to Story',
//                                   onPressed: () {
//                                     final dynamic story = controller.story;
//                                     if (story['type'] == 'video') {
//                                       List durationParts = story['metadata']
//                                               ['duration']
//                                           .toString()
//                                           .split(':');
//                                       Duration totalDuration = Duration(
//                                         minutes: int.parse(durationParts[0]),
//                                         seconds: int.parse(durationParts[1]),
//                                       );
//                                       if (totalDuration.inSeconds > 15) {
//                                         PlatformAlertDialog(
//                                           title: 'Video Too long',
//                                           content:
//                                               'Trim the video first. Maximum of 15 seconds.',
//                                           actions: [
//                                             PlatformAlertDialogAction(
//                                               child: Text('OK'),
//                                               isDefaultAction: true,
//                                               onPressed: () => navigator.pop(),
//                                             )
//                                           ],
//                                         ).show();
//                                         return;
//                                       }
//                                     }
//                                     controller.addStory();
//                                     navigator.pop();
//                                   },
//                                 ),
//                               ),
//                               Spacer(),
//                             ],
//                           )
//                         : Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     pickMedia(context);
//                                     // showGallery(context);
//                                   },
//                                   child: Icon(
//                                     FeatherIcons.image,
//                                     size: 25,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 // Spacer(),
//                                 Expanded(
//                                   child: CarouselSlider(
//                                     items: [
//                                       Text(
//                                         'Photo',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 17,
//                                         ),
//                                       ),
//                                       Text(
//                                         'Video',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 17,
//                                         ),
//                                       ),
//                                     ],
//                                     options: CarouselOptions(
//                                       enableInfiniteScroll: false,
//                                       enlargeCenterPage: true,
//                                       viewportFraction: 0.2,
//                                     ),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: Icon(
//                                     FeatherIcons.rotateCw,
//                                     size: 25,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ),
//                 ),
//               )),
//     );
//   }

//   File pickedFile;
//   pickMedia(BuildContext context) async {
//     FocusManager.instance.primaryFocus.unfocus();
//     AssetEntity asset = await Mediapicker.pick(context);

//     if (asset != null) {
//       pickedFile = await asset.file;
//       if (asset.type != AssetType.video && asset.type != AssetType.image) {
//         return;
//       }

//       if (asset.type == AssetType.video) {
//         String thumbnailFilePath =
//             await vidThumbnail.VideoThumbnail.thumbnailFile(
//                     video: pickedFile.path,
//                     imageFormat: vidThumbnail.ImageFormat.JPEG,
//                     maxWidth: 500,
//                     quality: 75,
//                     timeMs: asset.videoDuration.inMilliseconds ~/ 2)
//                 .catchError((err) {
//           print(err);
//         });
//         controller.story['thumbnail'] = File(thumbnailFilePath);
//         controller.story['type'] = 'video';
//         controller.story['metadata'] = {
//           'duration': asset.videoDuration.toString().substring(2, 7)
//         };

//         controller.story['source'] = pickedFile;
//       } else if (asset.type == AssetType.image) {
//         controller.story['type'] = 'photo';
//         controller.story['thumbnail'] = pickedFile;
//       }
//       controller.story['source'] = pickedFile;

//       PaletteGenerator paletteGenerator =
//           await PaletteGenerator.fromImageProvider(
//               Image.file(controller.story['thumbnail']).image);
//       controller.story['color'] =
//           paletteGenerator.dominantColor.color.value.toRadixString(16);
//     }
//   }
// }

// class VideoTrimmer extends StatefulWidget {
//   final File pickedFile;
//   const VideoTrimmer({Key key, this.pickedFile}) : super(key: key);
//   @override
//   _VideoTrimmerState createState() => _VideoTrimmerState();
// }

// class _VideoTrimmerState extends State<VideoTrimmer> {
//   final Trimmer _trimmer = Trimmer();
//   double startVal = 0.0;
//   double endVal = 0.0;
//   bool isPlaying = false;
//   bool isTrimming = false;
//   @override
//   void initState() {
//     loadVideo();
//     super.initState();
//   }

//   void loadVideo() async {
//     await _trimmer.loadVideo(videoFile: widget.pickedFile);
//   }

//   @override
//   void dispose() {
//     _trimmer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: isTrimming,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//             leading: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Icon(
//                   FeatherIcons.x,
//                   color: Colors.white,
//                   size: 30,
//                 )),
//             elevation: 0,
//             backgroundColor: Colors.black),
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Stack(
//                 alignment: AlignmentDirectional.center,
//                 children: [
//                   VideoViewer(trimmer: _trimmer),
//                   IconButton(
//                       icon: Icon(
//                         isPlaying ? FeatherIcons.pause : FeatherIcons.play,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                       onPressed: () async {
//                         bool playbackState = await _trimmer.videPlaybackControl(
//                           startValue: startVal,
//                           endValue: endVal,
//                         );
//                         isPlaying = playbackState;
//                         setState(() {});
//                       }),
//                 ],
//               ),
//               const SizedBox(height: 40),
//               Expanded(
//                 child: Column(children: [
//                   TrimEditor(
//                     trimmer: _trimmer,
//                     viewerWidth: Get.width,
//                     viewerHeight: 70,
//                     scrubberPaintColor: Colors.green,
//                     borderPaintColor: Theme.of(context).primaryColor,
//                     onChangeStart: (val) {
//                       startVal = val;
//                       // controller.startVal.refresh();
//                     },
//                     onChangeEnd: (val) {
//                       endVal = val;
//                       // controller.endVal.refresh();
//                     },
//                     maxVideoLength: Duration(seconds: 15),
//                     onChangePlaybackState: (isPlaying) {
//                       isPlaying = isPlaying;
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   Flexible(
//                       child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                     child: isTrimming
//                         ? Container(
//                             height: 48,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                                 color: Theme.of(context).primaryColor,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: SpinKitRing(
//                               color: Colors.white,
//                               size: 30,
//                               lineWidth: 2,
//                             ),
//                           )
//                         : CustomButton(
//                             label: 'Trim',
//                             onPressed: () async {
//                               setState(() {
//                                 isTrimming = true;
//                               });
//                               final totalDuration = endVal - startVal;
//                               Duration duration =
//                                   Duration(milliseconds: totalDuration.round());
//                               final dynamic story =
//                                   Get.find<CreateStoryController>().story;
//                               await _trimmer
//                                   .saveTrimmedVideo(
//                                       startValue: startVal,
//                                       endValue: endVal,
//                                       applyVideoEncoding: true)
//                                   .then((trimmedPath) {
//                                 story['source'] = File(trimmedPath);
//                                 story['metadata'] = {
//                                   'duration': '00:${duration.inSeconds}'
//                                 };
//                                 setState(() {
//                                   isTrimming = false;
//                                 });
//                               });

//                               Get.find<CreateStoryController>().story.refresh();
//                               Navigator.pop(context);
//                             }),
//                   )),
//                 ]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
