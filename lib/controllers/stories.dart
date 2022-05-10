import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:alterr/utils/s3.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as ManipulateImage;
import 'package:alterr/models/story.dart';
import 'package:alterr/services/api.dart';
import 'package:get/get.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_s3/simple_s3.dart';

class CreateStoryController extends GetxController {
  RxMap<String, dynamic> story = {
    'type': '',
    'source': null,
    'thumbnail': null,
    'progress': 0.1,
    'metadata': {}
  }.obs;
  RxMap<String, dynamic> videoPlaybackControls =
      {'start_val': 0.0, 'end_val': 0.0, 'is_playing': false}.obs;
  late CameraController cameraController;
  RxDouble startVal = 0.0.obs;
  RxBool isPlaying = false.obs;
  RxDouble endVal = 0.0.obs;
  RxBool toTrim = false.obs;
  final storiesController = Get.find<StoriesController>();
  @override
  void onInit() {
    initializeCamera();
    super.onInit();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    if (cameras.length > 0) {
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      cameraController.initialize();
    }
  }

  String _randomString() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        16,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
  }

  addStory() async {
    await Future.delayed(Duration(milliseconds: 400));
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    story['progress'] = 0.2;
    storiesController.usersStories.refresh();

    Rx<UsersStories> userStories = storiesController.usersStories[0];
    story['timestamp'] = timestamp;
    storiesController.pendingStory = story;
    storiesController.pendingStory.refresh();
    storiesController.usersStories.refresh();
    story['progress'] = 0.4;

    bool generateSource = true;

    if (story['type'] == 'video') {
      generateSource = false;
      await compressStoryVideo();
    }

    await generateStoryImages(source: generateSource, thumbnail: true);
    story['progress'] = 0.6;
    try {
      Map<String, dynamic> data = Map<String, dynamic>.from(story);

      String randomString = _randomString();
      String sourceName = _randomString();
      String thumbnailName = _randomString();
      String s3Path = 'stories/$randomString-$timestamp';

      // upload source
      String sourcePath = await S3.uploadFile(
        s3Path,
        {
          'file': story['source'],
          'filename':
              story['type'] == 'video' ? '$sourceName.mp4' : '$sourceName.jpg'
        },
      );
      data['source'] = sourcePath;

      // upload thumbnail
      String thumbnailPath = await S3.uploadFile(
        s3Path,
        {'file': story['thumbnail'], 'filename': '$thumbnailName.jpg'},
      );
      data['thumbnail'] = thumbnailPath;

      story['progress'] = 1.0;

      File(story['source'].path).delete();
      File(story['thumbnail'].path).delete();

      data['metadata'] = jsonEncode(data['metadata']);

      ApiService()
          .request('stories', data, 'POST', withToken: true)
          .then((response) {
        userStories.value.stories.insert(0, response);
        storiesController.pendingStory.value = {
          'type': '',
          'source': null,
          'thumbnail': null,
          'progress': 0.1,
        };
        storiesController.usersStories.refresh();
      });
    } catch (e) {
      print(e);
    }
  }

  Future generateStoryImages({bool source: true, bool thumbnail: false}) async {
    ManipulateImage.Image? decodedImage =
        ManipulateImage.decodeImage(story['thumbnail'].readAsBytesSync());

    Directory tempDir = await getTemporaryDirectory();
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    if (source) {
      String sourceTmpPath = '${tempDir.path}/$timestamp-source.jpg';
      ManipulateImage.Image sourceImage =
          ManipulateImage.copyResize(decodedImage!, width: 1200);
      File(sourceTmpPath).writeAsBytesSync(
          ManipulateImage.encodeJpg(sourceImage, quality: 75));
      story['source'] = File(sourceTmpPath);
    }
    if (thumbnail) {
      String thumbnailTmpPath = '${tempDir.path}/$timestamp-thumbnail.jpg';
      ManipulateImage.Image thumbnailImage =
          ManipulateImage.copyResize(decodedImage!, width: 500);
      File(thumbnailTmpPath).writeAsBytesSync(
          ManipulateImage.encodeJpg(thumbnailImage, quality: 80));
      story['thumbnail'] = File(thumbnailTmpPath);
    }
  }

  Future compressStoryVideo() async {
    Directory tempDir = await getTemporaryDirectory();

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String compressedTmpPath = '${tempDir.path}/$timestamp-compressed.mp4';

    final LightCompressor _lightCompressor = LightCompressor();
    final dynamic response = await _lightCompressor.compressVideo(
        path: story['source'].path,
        destinationPath: compressedTmpPath,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        iosSaveInGallery: false);
    if (response is OnSuccess) {
      story['source'] = File(response.destinationPath);
    }
  }

  void reset() {
    story.value = {
      'type': '',
      'source': null,
      'thumbnail': null,
      'progress': 0.1,
      'metadata': {}
    };
    story.refresh();
  }
}

class StoriesController extends GetxController {
  RxList<Rx<UsersStories>> usersStories = <Rx<UsersStories>>[].obs;

  RxBool loading = true.obs;
  @override
  void onInit() {
    super.onInit();
    getStories();
  }

  RxMap<String, dynamic> pendingStory = {
    'type': '',
    'source': null,
    'thumbnail': null,
    'progress': 0.1,
  }.obs;

  getStories() async {
    usersStories.clear();
    List<dynamic>? response =
        await ApiService().request('stories', {}, 'GET', withToken: true);
    if (response != null) {
      for (Map<String, dynamic> stories in response) {
        usersStories.add(UsersStories.fromJson(stories).obs);
      }
      usersStories.refresh();
      loading.value = false;
    }
  }
}
