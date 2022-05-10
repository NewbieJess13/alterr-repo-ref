import 'package:alterr/models/post.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:alterr/transitions/drag_down_to_pop.dart';
import 'dart:io';
import 'package:alterr/utils/audio_video_progress_bar.dart';
import 'package:video_player/video_player.dart';

class PostModal {
  Rx<Post> post;
  PostModal(this.post);

  Future open(BuildContext context, {required String tag}) async {
    if (post.value.unlocked != true) {
      return;
    }

    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color(int.parse('0xff${post.value.color}')),
      ));
    }

    await navigator?.push(
      ImageViewerPageRoute(
        backgroundColor: Color(int.parse('0xff${post.value.color}')),
        builder: (context) => PostMedia(post: post, tag: tag),
      ),
    );

    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    } else {
      Brightness brightness = MediaQuery.of(context).platformBrightness;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: brightness == Brightness.light
              ? Color(0xFFFFFFFF)
              : Color(0xFF000000),
          systemNavigationBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light));
    }
  }
}

class PostMedia extends StatefulWidget {
  final Rx<Post> post;
  final String tag;
  PostMedia({
    Key? key,
    required this.post,
    required this.tag,
  }) : super(key: key);

  @override
  _PostMediaState createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  bool appBar = true;
  late CachedNetworkImageProvider photoViewSource;

  @override
  void initState() {
    super.initState();
    appBar = true;
    setState(() {});
    photoViewSource = CachedNetworkImageProvider(widget.post.value.source!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse('0xff${widget.post.value.color}')),
      body: GestureDetector(
          onVerticalDragDown: (_) {},
          onTap: () {
            appBar = !appBar;
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 0, color: Colors.transparent)),
            child: Stack(
              children: [
                /* Body */
                Container(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      widget.post.value.type == 'photo'
                          ? Center(
                              child: CachedNetworkImage(
                                imageUrl: widget.post.value.thumbnail!,
                                fit: BoxFit.fitWidth,
                              ),
                            )
                          : SizedBox.shrink(),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: widget.post.value.type == 'photo'
                              ? Hero(
                                  flightShuttleBuilder: (flightContext,
                                      animation,
                                      flightDirection,
                                      fromHeroContext,
                                      toHeroContext) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: photoViewSource)),
                                    );
                                  },
                                  tag: widget.tag,
                                  child: Container(
                                    width: double.infinity,
                                    child: PhotoView(
                                        imageProvider: photoViewSource,
                                        loadingBuilder: (context, event) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.fitWidth,
                                                    image: photoViewSource)),
                                          );
                                        },
                                        gaplessPlayback: true,
                                        tightMode: true,
                                        backgroundDecoration: BoxDecoration(
                                            color: Colors.transparent),
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale: 2.0),
                                  ),
                                )
                              : VideoplayerWidget(
                                  appBar: appBar,
                                  tag: widget.tag,
                                  post: widget.post.value),
                        ),
                      ),
                    ],
                  ),
                ),
                /* Top buttons */
                GestureDetector(
                  onTap: () => {},
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 150),
                    opacity: appBar == true ? 1.0 : 0.0,
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          padding:
                              EdgeInsets.only(top: 15, left: 15.0, right: 15.0),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          )),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  appBar = false;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(7.5),
                                  child: Icon(
                                    FeatherIcons.x,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class VideoplayerWidget extends StatefulWidget {
  final Post post;
  final String? tag;
  final bool appBar;
  VideoplayerWidget(
      {Key? key, required this.post, this.tag, required this.appBar})
      : super(key: key);
  @override
  _VideoplayerWidgetState createState() => _VideoplayerWidgetState();
}

class _VideoplayerWidgetState extends State<VideoplayerWidget> {
  Duration progress = Duration(milliseconds: 0);
  Duration buffered = Duration(milliseconds: 0);
  bool isPlaying = true;
  bool isInitialized = false;
  Duration duration = Duration(milliseconds: 0);
  late VideoPlayerController _videoPlayerController;
  bool isBuffering = true;

  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.network(widget.post.source!)
      ..initialize().then((_) {
        duration = _videoPlayerController.value.duration;
        isInitialized = true;
        setState(() {});
      });
    _videoPlayerController.setLooping(true);
    _videoPlayerController.addListener(() {
      if (mounted) {
        if (_videoPlayerController.value.buffered.isNotEmpty) {
          Duration newBuffered = _videoPlayerController.value.buffered[0].end;
          if (newBuffered == buffered) {
            buffered = duration;
          } else {
            buffered = newBuffered;
          }
          try {
            setState(() {});
          } catch (e) {}
        }

        if (_videoPlayerController.value.isPlaying) {
          isBuffering = false;
          progress = _videoPlayerController.value.position;
          try {
            setState(() {});
          } catch (e) {}
        }

        if (_videoPlayerController.value.isBuffering) {
          isBuffering = true;
          try {
            setState(() {});
          } catch (e) {}
        }
      }
    });

    Future.delayed(Duration(milliseconds: 250)).then((value) {
      if (mounted) {
        _videoPlayerController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: widget.post.thumbnail!,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
        Center(
          child: AbsorbPointer(
            absorbing: true,
            child: Opacity(
              opacity: isInitialized ? 1 : 0,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ),
        ),
        isBuffering
            ? Center(
                child: PlatformSpinner(
                radius: 10,
                width: 20,
                height: 20,
                brightness: Brightness.dark,
              ))
            : SizedBox.shrink(),
        GestureDetector(
          onTap: () => {},
          child: videoControls(),
        )
      ],
    );
  }

  Widget videoControls() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 150),
      opacity: widget.appBar == true ? 1.0 : 0.0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            )),
            child: SafeArea(
              top: false,
              child: Container(
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: () => toggleVideo(),
                          child: Container(
                            decoration: BoxDecoration(),
                            padding: EdgeInsets.all(5),
                            child: isPlaying == true
                                ? Transform.translate(
                                    offset: Offset(0, -1),
                                    child: Icon(FeatherIcons.pause,
                                        color: Colors.white, size: 24),
                                  )
                                : Transform.translate(
                                    offset: Offset(1, -1),
                                    child: Icon(FeatherIcons.play,
                                        color: Colors.white, size: 24),
                                  ),
                          )),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Center(
                              child: ProgressBar(
                                timeLabelLocation: TimeLabelLocation.sides,
                                timeLabelTextStyle:
                                    TextStyle(color: Colors.white),
                                progress: progress,
                                thumbGlowRadius: 0,
                                thumbRadius: 8,
                                progressBarColor:
                                    Colors.white.withOpacity(0.75),
                                baseBarColor: Colors.white.withOpacity(0.15),
                                bufferedBarColor:
                                    Colors.white.withOpacity(0.25),
                                barHeight: 3,
                                buffered: buffered,
                                total: duration,
                                onDragUpdate: (ThumbDragDetails details) {
                                  _videoPlayerController
                                      .seekTo(details.timeStamp);
                                },
                                onSeek: (seekDuration) {
                                  _videoPlayerController.seekTo(seekDuration);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  toggleVideo() {
    if (_videoPlayerController.value.isPlaying == true) {
      _videoPlayerController.pause();
      isPlaying = false;
      setState(() {});
    } else {
      _videoPlayerController.play();
      isPlaying = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    super.dispose();
  }
}

class ImageViewerPageRoute extends MaterialPageRoute {
  Color? backgroundColor;
  ImageViewerPageRoute({
    required WidgetBuilder builder,
    this.backgroundColor,
  }) : super(builder: builder, maintainState: false);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return DragDownToPopPageTransitionsBuilder(backgroundColor: backgroundColor)
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return false;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return false;
  }
}
