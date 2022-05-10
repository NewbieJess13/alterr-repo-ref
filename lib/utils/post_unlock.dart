import 'package:alterr/screens/topup.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/models/post.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:alterr/controllers/post_unlock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostUnlock extends StatefulWidget {
  final Rx<Post>? post;
  PostUnlock({Key? key, this.post}) : super(key: key);

  @override
  PostUnlockState createState() => PostUnlockState();
}

class PostUnlockState extends State<PostUnlock> {
  final PostUnlockController controller = Get.put(PostUnlockController());

  @override
  void initState() {
    super.initState();
    controller.loading.value = true;
    controller.unlocking.value = false;
    controller.getBarias();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.post?.value.price} barias',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => {
                          controller.loading.value ||
                                  controller.unlocking.value == true
                              ? null
                              : Navigator.pop(context)
                        },
                        child: Obx(() => Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(controller.loading.value ||
                                              controller.unlocking.value == true
                                          ? 0.25
                                          : 1.0)),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Obx(() => content(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(context) {
    return controller.loading.value == true
        ? Container(
            color: Colors.white,
            height: 200,
            child: Center(
              child: PlatformSpinner(
                width: 20,
                height: 20,
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.all(15),
            child: controller.barias.value < int.parse(widget.post!.value.price)
                ? _insufficient()
                : _confirmUnlock(),
          );
  }

  Widget _confirmUnlock() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(7.5)),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.post!.value.thumbnail!,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse('0xff${widget.post?.value.color}')),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      errorWidget: (context, error, _) {
                        return Container(
                          color: Color(
                              int.parse('0xff${widget.post?.value.color}')),
                          height: 40,
                          width: 40,
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post!.value.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              widget.post!.value.user.username,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black45),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            SizedBox(
              height: 15,
            ),
            Text(
              'Post price',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              '${widget.post?.value.price} barias',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Available barias',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              '${controller.barias.value.toString()} barias',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Material(
              child: CustomButton(
                onPressed: () => controller.unlockPost(widget.post!),
                label: '  Unlock Post',
                prefixIcon: Transform.translate(
                  offset: Offset(0, -1.5),
                  child: Icon(
                    FeatherIcons.unlock,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
        ),
        controller.unlocking.value == true
            ? Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.85),
                  child: Center(
                    child: PlatformSpinner(
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget _insufficient() {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Text(
          'Insufficient barias',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'You don\'t have enough barias to unlock this post.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          '${controller.barias.value.toString()} barias left',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black45),
        ),
        SizedBox(
          height: 20,
        ),
        Material(
          child: CustomButton(
            onPressed: () => _showTopUp(),
            label: '  Top Up',
            prefixIcon: Transform.translate(
              offset: Offset(0, -1),
              child: Icon(
                FeatherIcons.gift,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showTopUp() async {
    await navigator?.push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return TopupScreen();
        },
        fullscreenDialog: true));
    controller.getBarias();
  }
}
