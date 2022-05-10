import 'package:alterr/services/api.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';

class ReportContent {
  ReportContentController controller = Get.put(ReportContentController());

  showModalReport(context, {required String type, required String name}) async {
    List<String> _items = [];
    if (type == 'Post') {
      _items = [
        'Stolen content',
        'Misleading post',
        'Promotes violence',
        'I don\'t like it',
      ];
    } else if (type == 'User') {
      _items = [
        'This account appears to be hacked',
        'This user is pretending to be me or someone else',
        'This user is promoting self-harm or suicide',
        'This user is a minor'
      ];
    }
    controller.type.value = type;
    controller.reason.value = '';
    return await PlatformBottomsheetModal(
        context: context,
        child: Obx(() => SafeArea(
              child: Material(
                color: Colors.white,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 60,
                              ),
                              Text(
                                'Report ${controller.type.value}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (controller.loading.value == false) {
                                    navigator?.pop();
                                  }
                                },
                                child: Opacity(
                                  opacity: controller.loading.value == true
                                      ? 0.5
                                      : 1,
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              )
                            ]),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help us understand the problem',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () =>
                                      {controller.reason.value = _items[index]},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black
                                                    .withOpacity(0.05)))),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _items[index],
                                            style: TextStyle(fontSize: 15.5),
                                          ),
                                        ),
                                        Opacity(
                                          opacity: controller.reason.value ==
                                                  _items[index]
                                              ? 1
                                              : 0,
                                          child: Icon(FeatherIcons.check,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: _items.length,
                            ),
                            SizedBox(height: 15),
                            CustomButton(
                              loading: controller.loading.value,
                              disabled: controller.loading.value ||
                                  controller.reason.value == '',
                              onPressed: () async {
                                await controller.submitReport(name);
                              },
                              label: 'Submit',
                            )
                          ],
                        ),
                      )
                    ]),
              ),
              top: false,
            ))).show();
  }
}

class ReportContentController extends GetxController {
  RxBool loading = false.obs;
  RxString reason = ''.obs;
  String description = '';
  RxString type = ''.obs;

  submitReport(String name) async {
    String? target;
    if (type.value == 'Post') {
      target = 'posts';
    } else if (type.value == 'User') {
      target = 'users';
    }
    if (target != null) {
      loading
        ..value = true
        ..refresh();
      await ApiService().request('$target/$name/report',
          {'reason': reason.value, 'description': description}, 'POST',
          withToken: true);
      loading
        ..value = false
        ..refresh();
      navigator?.pop();
      PlatformAlertDialog(
        title: '$type Reported',
        content:
            'Thanks for letting us know. Your feedback is important to improve the platform and keeping our community safe.',
        actions: [
          PlatformAlertDialogAction(
            child: Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              navigator?.pop();
            },
          )
        ],
      ).show();
    }
  }
}
