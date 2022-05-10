import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:photo_manager/photo_manager.dart';

typedef void OnSendMessage(AssetEntity entity);

class MessageMediaPicker {
  static Future<Widget?> pick(BuildContext context,
      {OnSendMessage? onSendMessage}) async {
    MessageMediaPickerController controller =
        Get.put(MessageMediaPickerController());

    PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.isAuth) {
      return Obx(() => Container(
            padding: const EdgeInsets.only(top: 10),
            child: controller.loading.value
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1),
                    shrinkWrap: true,
                    itemCount: controller.assets.length,
                    itemBuilder: (context, index) {
                      AssetEntity asset = controller.assets[index];
                      return FutureBuilder(
                        future: asset.thumbDataWithSize(300, 300, quality: 75),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Widget label = Container();
                            if (asset.type == AssetType.video) {
                              String duration = asset.videoDuration
                                  .toString()
                                  .substring(2, 7);
                              label = Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      height: 24,
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              FeatherIcons.play,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            Text(
                                              duration,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0),
                                            )
                                          ],
                                        ),
                                      ),
                                      color: Colors.black.withOpacity(0.5)));
                            }
                            return GestureDetector(
                              onTap: () {
                                onSendMessage!(asset);
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: Image.memory(
                                    snapshot.data as Uint8List,
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
          ));
    } else {
      PhotoManager.openSetting();
    }
  }
}

class MessageMediaPickerController extends GetxController {
  RxBool loading = true.obs;
  RxList<AssetEntity> assets = <AssetEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    getMedias();
  }

  getMedias() async {
    List<AssetPathEntity> assetPaths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    AssetPathEntity asset = assetPaths[0];
    assets.value = await asset.getAssetListPaged(0, assetPaths[0].assetCount);
    loading
      ..value = false
      ..refresh();
  }
}
