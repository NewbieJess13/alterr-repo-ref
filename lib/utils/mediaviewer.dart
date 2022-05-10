import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:alterr/transitions/drag_down_to_pop.dart';
import 'dart:io' show Platform;
import 'dart:io';

class MediaViewer {
  Future open(BuildContext context,
      {required String url, required String tag}) async {
    final MediaViewerController controller = Get.put(MediaViewerController());

    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }

    controller.appBar.value = true;

    await navigator?.push(
      ImageViewerPageRoute(
        backgroundColor: Colors.black87,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black87,
          body: GestureDetector(
              onTap: () => {controller.appBar.value = !controller.appBar.value},
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
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                                child: Hero(
                              flightShuttleBuilder: (flightContext,
                                  animation,
                                  flightDirection,
                                  fromHeroContext,
                                  toHeroContext) {
                                return Container(
                                  child: fromHeroContext.widget,
                                );
                              },
                              tag: tag,
                              child: CachedNetworkImage(
                                fadeInDuration: Duration(seconds: 0),
                                placeholderFadeInDuration: Duration(seconds: 0),
                                fadeOutDuration: Duration(seconds: 0),
                                imageUrl: url,
                                width: double.infinity,
                                imageBuilder: (context, imageProvider) =>
                                    PhotoView(
                                  backgroundDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  tightMode: true,
                                  imageProvider: imageProvider,
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale: 2.0,
                                ),
                                fit: BoxFit.contain,
                                errorWidget: (context, error, _) {
                                  return Container();
                                },
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    /* Top buttons */
                    Obx(
                      () => AnimatedOpacity(
                        duration: Duration(milliseconds: 150),
                        opacity: controller.appBar.value == true ? 1.0 : 0.0,
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                  top: 15, left: 15.0, right: 15.0),
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
                                      controller.appBar.value = false;
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
        ),
      ),
    );

    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
  }
}

class ImageViewerPageRoute extends MaterialPageRoute {
  Color? backgroundColor;
  ImageViewerPageRoute({required WidgetBuilder builder, this.backgroundColor})
      : super(builder: builder, maintainState: false);

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

class MediaViewerController extends GetxController {
  RxBool appBar = true.obs;
}
