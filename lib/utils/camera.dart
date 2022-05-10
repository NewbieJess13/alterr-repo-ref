import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'dart:io' as IO;
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

PickedFile? selectedFile;

class Camera {
  static pick() async {
    selectedFile = null;
    await navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return CameraApp();
        },
        fullscreenDialog: true));
    return selectedFile;
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<CameraApp>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  double scale = 1.0;
  double _scaleFactor = 1.0;
  int cameraIndex = 0;
  CarouselController carouselController = CarouselController();
  bool recording = false;
  XFile? file;
  String flashMode = 'auto';
  CountdownTimerController? countdownTimerController;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
  VideoPlayerController? videoPlayerController;
  bool isDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    countdownTimerController =
        CountdownTimerController(endTime: endTime, onEnd: onVideoLimit);
    Future.delayed(Duration(milliseconds: 500)).then((_) => initCameras());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || controller?.value.isInitialized == false) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        _setCamera(controller!.description);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    countdownTimerController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isDenied == true) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FeatherIcons.cameraOff,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Camera not accessible.',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              SizedBox(
                height: 30,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onTap: () {
                    openAppSettings();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(25)),
                    child: Text('Allow access',
                        style: TextStyle(
                            color: Colors.white, fontSize: 17, height: 1.1)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onTap: () {
                    navigator?.pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 17,
                            height: 1.1)),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _cameraPreview()),
          file != null ? Positioned.fill(child: _filePreview()) : Container(),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
                onScaleStart: (details) {
                  scale = _scaleFactor;
                },
                onScaleUpdate: (details) {
                  _scaleFactor = scale * details.scale;
                  if (_scaleFactor >= 1 && _scaleFactor <= 3) {
                    controller?.setZoomLevel(_scaleFactor);
                  }
                },
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: cameras.isEmpty ||
                                    controller?.value.isInitialized == false
                                ? Container()
                                : CameraPreview(controller!)),
                      ),
                      !recording
                          ? Stack(
                              children: [
                                !recording
                                    ? Container(
                                        child: CarouselSlider(
                                          carouselController:
                                              carouselController,
                                          items: [
                                            GestureDetector(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 25),
                                                child: Text(
                                                  'Photo',
                                                  style: TextStyle(
                                                    color: cameraIndex == 0
                                                        ? Colors.white
                                                        : Colors.white
                                                            .withOpacity(0.35),
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                cameraIndex = 0;
                                                carouselController
                                                    .animateToPage(0,
                                                        duration: Duration(
                                                            milliseconds: 100),
                                                        curve: Curves.linear);
                                              },
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 25),
                                                child: Text(
                                                  'Video',
                                                  style: TextStyle(
                                                    color: cameraIndex == 1
                                                        ? Colors.white
                                                        : Colors.white
                                                            .withOpacity(0.35),
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                cameraIndex = 1;
                                                carouselController
                                                    .animateToPage(1,
                                                        duration: Duration(
                                                            milliseconds: 100),
                                                        curve: Curves.linear);
                                              },
                                            ),
                                          ],
                                          options: CarouselOptions(
                                            height: 70,
                                            initialPage: cameraIndex,
                                            enableInfiniteScroll: false,
                                            enlargeCenterPage: false,
                                            viewportFraction: 0.22,
                                            onPageChanged: (index, reason) {
                                              cameraIndex = index;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                Positioned(
                                  top: 18.5,
                                  left: MediaQuery.of(context).size.width / 2 -
                                      40,
                                  child: Container(
                                    width: 80,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                            Border.all(color: Colors.white)),
                                  ),
                                )
                              ],
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 23),
                              child: CountdownTimer(
                                controller: countdownTimerController,
                                onEnd: onVideoLimit,
                                endTime: endTime,
                                widgetBuilder: (_, CurrentRemainingTime? time) {
                                  if (time == null) {
                                    return Text(
                                      '00:00',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20),
                                    );
                                  }
                                  String paddingMinute = '';
                                  if (time.min != null &&
                                      time.min!.isLowerThan(10)) {
                                    paddingMinute = '0';
                                  }
                                  String paddingSecond = '';
                                  if (time.sec != null &&
                                      time.sec!.isLowerThan(10)) {
                                    paddingSecond = '0';
                                  }
                                  return Text(
                                    '$paddingMinute${time.min ?? '00'}:$paddingSecond${time.sec ?? '00'}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  );
                                },
                              ),
                            )
                    ],
                  ),
                ))),
        Positioned(
          top: 8,
          right: 10,
          child: SafeArea(
            child: !recording
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black),
                      child: Transform.translate(
                        offset: Offset(0, -1),
                        child: Icon(FeatherIcons.x, color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 130),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AbsorbPointer(
                    absorbing: recording || cameraIndex == 1,
                    child: Opacity(
                      opacity: recording || cameraIndex == 1 ? 0 : 1,
                      child: GestureDetector(
                        onTap: () => _toggleFlash(),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            flashMode == 'auto'
                                ? Icons.flash_auto
                                : flashMode == 'off'
                                    ? Icons.flash_off
                                    : flashMode == 'always'
                                        ? Icons.flash_on
                                        : Icons.flash_on,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    )),
                AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  child: Material(
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () => {_capture()},
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: cameraIndex == 0
                                ? Colors.white.withOpacity(0.5)
                                : recording
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.red),
                      ),
                    ),
                    color: Colors.transparent,
                  ),
                ),
                AbsorbPointer(
                    absorbing: recording,
                    child: Opacity(
                      opacity: recording ? 0 : 1,
                      child: GestureDetector(
                        onTap: () => _switchCamera(),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filePreview() {
    Widget preview = Container();
    if (cameraIndex == 0) {
      preview = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          image: DecorationImage(
              fit: BoxFit.cover, image: FileImage(IO.File(file!.path))),
        ),
      );
    } else {
      preview = AspectRatio(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(videoPlayerController!),
      );
    }
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: preview,
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    file = null;
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Retake',
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onTap: () async {
                      PickedFile pickedfile = new PickedFile(path: file!.path);
                      if (videoPlayerController != null) {
                        pickedfile.duration =
                            videoPlayerController!.value.duration;
                      }
                      selectedFile = pickedfile;
                      navigator?.pop();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 9, horizontal: 13),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(25)),
                      child: Text('Use ${cameraIndex == 0 ? 'photo' : 'video'}',
                          style: TextStyle(
                              color: Colors.white, fontSize: 17, height: 1.1)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  initCameras() async {
    cameras = await availableCameras().catchError((e) {
      isDenied = true;
      setState(() {});
    });
    if (cameras.isEmpty) return;
    _setCamera(cameras[0]);
  }

  _setCamera(CameraDescription camera) {
    controller = CameraController(camera, ResolutionPreset.ultraHigh,
        imageFormatGroup: ImageFormatGroup.yuv420);
    controller?.initialize().then((_) async {
      await controller?.lockCaptureOrientation();
      switch (controller!.value.flashMode) {
        case FlashMode.auto:
          flashMode = 'auto';
          break;
        case FlashMode.off:
          flashMode = 'off';
          break;
        case FlashMode.always:
          flashMode = 'always';
          break;
        case FlashMode.torch:
          break;
      }
      setState(() {});
    }).catchError((e) {
      isDenied = true;
      setState(() {});
    });
  }

  _capture() async {
    if (cameraIndex == 0) {
      file = await controller?.takePicture().catchError((e) {
        print('takePicture error');
        print(e);
      });
    } else {
      if (!recording) {
        try {
          await controller?.prepareForVideoRecording();
          controller?.startVideoRecording();
          endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
          countdownTimerController?.endTime = endTime;
          countdownTimerController?.start();
          recording = true;
        } catch (e) {
          print(e);
        }
      } else {
        XFile tempFile = await controller!.stopVideoRecording();
        videoPlayerController =
            VideoPlayerController.file(IO.File(tempFile.path));
        await videoPlayerController?.initialize();
        file = tempFile;
        recording = false;
        videoPlayerController?.play();
      }
    }

    setState(() {});
  }

  _switchCamera() async {
    final lensDirection = controller?.description.lensDirection;
    CameraDescription newCamera;
    if (lensDirection == CameraLensDirection.front) {
      newCamera = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newCamera = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }
    _setCamera(newCamera);
  }

  _toggleFlash() {
    FlashMode? newFlashMode;
    switch (controller!.value.flashMode) {
      case FlashMode.auto:
        newFlashMode = FlashMode.off;
        flashMode = 'off';
        break;
      case FlashMode.off:
        newFlashMode = FlashMode.always;
        flashMode = 'always';
        break;
      case FlashMode.always:
        newFlashMode = FlashMode.auto;
        flashMode = 'auto';
        break;
      case FlashMode.torch:
        break;
    }
    setState(() {});
    controller?.setFlashMode(newFlashMode!);
  }

  onVideoLimit() async {
    _capture();
  }
}

class PickedFile {
  final String path;
  Duration? duration;
  PickedFile({
    required this.path,
    this.duration,
  });
}
