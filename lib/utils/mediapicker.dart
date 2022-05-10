import 'dart:typed_data';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Mediapicker {
  static Future<AssetEntity?> pick(BuildContext context) async {
    MediaPickerController controller = Get.put(MediaPickerController());
    controller.showAlbums.value = false;
    controller.getAlbums();
    AssetEntity? selectedAsset;

    PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.isAuth) {
      await navigator?.push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return Obx(() => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    toolbarHeight: 55,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 50,
                          ),
                          InkWell(
                              onTap: () => {controller.showAlbums.value = true},
                              child: Column(
                                children: [
                                  Text(
                                    controller.selectedAlbum['name'] ??
                                        'Recents',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Tap to change',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                      )
                                    ],
                                  )
                                ],
                              )),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text('Done',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).primaryColor)),
                          )
                        ],
                      ),
                    ),
                    automaticallyImplyLeading: false,
                  ),
                  body: Column(
                    children: [
                      Divider(
                        height: 1,
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: controller.assets.length == 0
                                      ? Center(
                                          child: Text(
                                          'No media found',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black26),
                                        ))
                                      : GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 1,
                                                  crossAxisSpacing: 1),
                                          shrinkWrap: true,
                                          itemCount: controller.assets.length,
                                          itemBuilder: (context, index) {
                                            AssetEntity asset =
                                                controller.assets[index];
                                            return FutureBuilder(
                                              future: asset.thumbDataWithSize(
                                                  300, 300,
                                                  quality: 75),
                                              builder: (BuildContext context,
                                                  snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  Widget label = Container();
                                                  if (asset.type ==
                                                      AssetType.video) {
                                                    String duration = asset
                                                        .videoDuration
                                                        .toString()
                                                        .substring(2, 7);
                                                    label = Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: Container(
                                                            height: 24,
                                                            alignment: Alignment
                                                                .bottomLeft,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Icon(
                                                                    FeatherIcons
                                                                        .play,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 13,
                                                                  ),
                                                                  Text(
                                                                    duration,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            13.0),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5)));
                                                  }
                                                  return GestureDetector(
                                                    onTap: () {
                                                      selectedAsset = asset;
                                                      Navigator.pop(context);
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                            child: Image.memory(
                                                          snapshot.data
                                                              as Uint8List,
                                                          fit: BoxFit.cover,
                                                        )),
                                                        label,
                                                      ],
                                                    ),
                                                  );
                                                }

                                                return Container();
                                              },
                                            );
                                          }),
                                )
                              ],
                            ),
                            controller.showAlbums.value == true
                                ? albumsList(controller, context)
                                : SizedBox.shrink(),
                            controller.loading.value == true
                                ? Positioned.fill(
                                    child: Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: PlatformSpinner(
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ))
                                : SizedBox.shrink()
                          ],
                        ),
                      )
                    ],
                  ),
                ));
          },
          fullscreenDialog: true));
      Future.delayed(Duration(milliseconds: 150))
          .then((value) => {controller.setRecentAlbum()});
      controller.getAlbums(force: true);
      return selectedAsset;
    } else {
      PhotoManager.openSetting();
    }
  }

  static Widget albumsList(controller, context) {
    return Scaffold(
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.albums.length,
        itemBuilder: (context, index) {
          dynamic album = controller.albums.value[index];
          return InkWell(
            onTap: () {
              controller.selectAlbum(album['album']);
              controller.showAlbums.value = false;
            },
            child: Container(
              padding: EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.black.withOpacity(0.05)))),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(album['preview']),
                            fit: BoxFit.cover)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album['album'].name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          album['album'].assetCount.toString(),
                          style:
                              TextStyle(fontSize: 15.5, color: Colors.black45),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MediaPickerController extends GetxController {
  RxList<dynamic> albums = [].obs;
  RxMap<dynamic, dynamic> selectedAlbum = {}.obs;
  RxList<dynamic> assets = [].obs;
  RxBool showAlbums = false.obs;
  RxBool loading = true.obs;
  List<dynamic> parsedAlbums = [];
  List<AssetPathEntity> allAlbumsList = [];

  void setRecentAlbum({bool force = false}) {
    if (allAlbumsList.length > 0) {
      AssetPathEntity recentAlbum = allAlbumsList.firstWhere(
          (element) => element.name == 'Recents',
          orElse: () => AssetPathEntity());
      if (recentAlbum.id.isEmpty) {
        recentAlbum = allAlbumsList[0];
      }
      selectAlbum(recentAlbum, force: force);
    }
  }

  void getAlbums({bool force = false}) async {
    if (albums.firstRebuild || force) {
      parsedAlbums = [];
      allAlbumsList = await PhotoManager.getAssetPathList(
        hasAll: true,
      );
      setRecentAlbum(force: force);
      for (var album in allAlbumsList) {
        List<AssetEntity> latestMedia = await album.getAssetListPaged(0, 10);
        var thumbData =
            await latestMedia[0].thumbDataWithSize(300, 300, quality: 75);
        if (album.name == 'Recents') {
          parsedAlbums.insert(0, {'album': album, 'preview': thumbData});
        } else {
          parsedAlbums.add({'album': album, 'preview': thumbData});
        }
      }
      albums.value = parsedAlbums;
    }
  }

  void selectAlbum(AssetPathEntity album, {bool force = false}) async {
    if (assets.firstRebuild || album.id != selectedAlbum['id'] || force) {
      loading.value = true;
      assets.value = await album.getAssetListPaged(0, 500);
    }
    loading.value = false;
    selectedAlbum['id'] = album.id;
    selectedAlbum['name'] = album.name;
  }
}
