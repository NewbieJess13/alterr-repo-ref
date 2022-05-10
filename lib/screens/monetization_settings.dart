import 'package:alterr/controllers/auth.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/mediapicker.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/s3.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:alterr/services/api.dart';
import 'package:alterr/utils/platform_bottomsheet_modal.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:intl/intl.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:alterr/utils/platform_spinner.dart';

// ignore: must_be_immutable
class MonetizationSettingsScreen extends StatefulWidget {
  @override
  MonetizationSettingsScreenState createState() =>
      MonetizationSettingsScreenState();
}

class MonetizationSettingsScreenState
    extends State<MonetizationSettingsScreen> {
  final _MonetizationController controller = new _MonetizationController();
  final AuthController authController = Get.put(AuthController());
  Widget contentScreen = Container(
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    controller.getBank();
  }

  @override
  Widget build(BuildContext context) {
    return _monetizationSettings(context);
  }

  Widget _monetizationSettings(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
          title: 'Monetization',
          action: InkWell(
            onTap: () => navigator?.pop(),
            child: Text(
              'Done',
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).primaryColor),
            ),
          )).build(),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 20),

        /* Cashouts */
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 15),
          child: Text(
            'Finance',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _cashouts(context)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.05)),
                      bottom:
                          BorderSide(color: Colors.black.withOpacity(0.05)))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cashouts',
                      style: TextStyle(fontSize: 15.5, height: 1),
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                  )
                ],
              )),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push<void>(SwipeablePageRoute(builder: (_) => _bank(context)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.black.withOpacity(0.05)))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bank',
                      style: TextStyle(fontSize: 15.5, height: 1),
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                  )
                ],
              )),
        ),
      ]),
    );
  }

  _cashouts(context) {
    controller.getCashouts();
    return Obx(() => Scaffold(
        appBar: CustomAppBar(
          leading: Transform.translate(
            offset: Offset(-5, 0),
            child: Obx(() => IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 15.0,
                  color: Colors.black87,
                  icon: Transform.translate(
                    offset: Offset(-1, -6),
                    child: Icon(
                      FeatherIcons.arrowLeft,
                      size: 26,
                    ),
                  ),
                  onPressed: controller.loading.value == true
                      ? null
                      : () => {Navigator.pop(context)},
                )),
          ),
          title: 'Cashouts',
        ).build(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Text(
                '${controller.bariasEarned.toString()} barias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            controller.isAffiliate.value == true
                ? Container(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 2),
                    child: Text(
                      'Affiliate Program: PHP ${controller.affiliateBalance.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 15.5, color: Colors.black38),
                    ),
                  )
                : SizedBox.shrink(),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                'PHP ${controller.availableBalance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15.5, color: Colors.black38),
              ),
            ),
            ..._cashoutContent()
          ],
        )));
  }

  List<Widget> _cashoutContent() {
    List<Widget> _cashout = [];
    _cashout.addAll([
      Container(
        padding: EdgeInsets.all(15),
        child: CustomButton(
          disabled: controller.bankDetails['id'] == null ||
              controller.bankDetails['is_verified'] == false,
          label: 'Request Cashout',
          onPressed: () => {_openCashoutForm(context)},
        ),
      ),
      Divider(
        height: 1,
      )
    ]);

    if (controller.bankDetails['id'] == null ||
        controller.bankDetails['is_verified'] == false) {
      _cashout.add(Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Please add a bank account to request a cashout.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ),
      ));
    } else {
      _cashout.addAll([
        Container(
          padding: EdgeInsets.only(left: 15, top: 15, right: 15),
          child: Text(
            'Cashouts History',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(
          () => Expanded(
              child: controller.cashouts.length == 0
                  ? Center(
                      child: Text(
                        'No cashouts yet.',
                        style: TextStyle(color: Colors.black26, fontSize: 17),
                      ),
                    )
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.cashouts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                            bottom: BorderSide(
                                color: Colors.black.withOpacity(0.05)),
                          )),
                          padding: EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '₱${double.parse(controller.cashouts[index]['amount'].toString()).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                        DateFormat('MMMM dd, y').format(
                                            DateTime.parse(
                                                controller.cashouts[index]
                                                    ['created_at'])),
                                        style: TextStyle(
                                            fontSize: 15.5,
                                            color: Colors.black54))
                                  ],
                                ),
                              ),
                              Text(
                                  StringUtils.capitalize(
                                      controller.cashouts[index]['status']),
                                  style: TextStyle(
                                      fontSize: 15.5, color: Colors.black54))
                            ],
                          ),
                        );
                      })),
        )
      ]);
    }

    return _cashout;
  }

  _bank(context) {
    if (controller.bankDetails['id'] != null) {
      controller.accountNameController.text =
          controller.bankDetails['account_name'];
      controller.accountNumberController.text =
          controller.bankDetails['account_number'];
    }
    bool isVerified = false;
    if (controller.bankDetails['id'] != null) {
      isVerified = controller.bankDetails['is_verified'] ?? false;
    }
    controller.getBanks();
    return Obx(() => Scaffold(
        appBar: CustomAppBar(
                leading: Transform.translate(
                  offset: Offset(-5, 0),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    splashRadius: 15.0,
                    color: Colors.black87,
                    icon: Transform.translate(
                      offset: Offset(-1, -6),
                      child: Icon(
                        FeatherIcons.arrowLeft,
                        size: 26,
                      ),
                    ),
                    onPressed: controller.loading.value == true
                        ? null
                        : () => {Navigator.pop(context)},
                  ),
                ),
                title: 'Bank',
                action: controller.loading.value == true
                    ? SizedBox(
                        width: 25,
                        height: 25,
                        child: PlatformSpinner(
                          radius: 10,
                          width: 16,
                          height: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : InkWell(
                        onTap: controller.isChanged.value == false ||
                                controller.bankDetails['id'] != null
                            ? null
                            : () =>
                                controller.updateBank(authController, context),
                        child: Opacity(
                          opacity: controller.isChanged.value == false ||
                                  controller.bankDetails['id'] != null
                              ? 0.5
                              : 1,
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ))
            .build(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _showBankPicker(context),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              'Bank name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Obx(() => Text(
                                  controller.bankDetails['bank_code'] != null
                                      ? controller.banks[controller
                                              .bankDetails['bank_code']] ??
                                          ''
                                      : '',
                                  style:
                                      TextStyle(fontSize: 15.5, height: 1.3))),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              'Account name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: TextField(
                                controller: controller.accountNameController,
                                readOnly: controller.loading.value,
                                minLines: 1,
                                maxLines: 2,
                                keyboardType: TextInputType.emailAddress,
                                decoration: new InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                cursorColor: Colors.black,
                                cursorWidth: 1,
                                onChanged: (value) {
                                  controller.bankDetails['account_name'] =
                                      value.trim();
                                  if ((controller.bankDetails['bank_code'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      (controller.bankDetails['account_name'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      (controller.bankDetails[
                                                      'account_number'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      controller.bankDetails['valid_id'] !=
                                          null) {
                                    controller.isChanged.value = true;
                                  } else {
                                    controller.isChanged.value = false;
                                  }
                                  controller.isChanged.refresh();
                                },
                              ),
                            ),
                          )
                        ],
                      )),
                  Divider(
                    height: 1,
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              'Account no.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: TextField(
                                controller: controller.accountNumberController,
                                readOnly: controller.loading.value,
                                minLines: 1,
                                maxLines: 2,
                                keyboardType: TextInputType.emailAddress,
                                decoration: new InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                cursorColor: Colors.black,
                                cursorWidth: 1,
                                onChanged: (value) {
                                  controller.bankDetails['account_number'] =
                                      value.trim();
                                  if ((controller.bankDetails['bank_code'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      (controller.bankDetails['account_name'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      (controller.bankDetails[
                                                      'account_number'] ??
                                                  '')
                                              .trim()
                                              .length >
                                          0 &&
                                      controller.bankDetails['valid_id'] !=
                                          null) {
                                    controller.isChanged.value = true;
                                  } else {
                                    controller.isChanged.value = false;
                                  }
                                  controller.isChanged.refresh();
                                },
                              ),
                            ),
                          )
                        ],
                      )),
                  Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valid ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                AssetEntity? asset =
                                    await Mediapicker.pick(context);
                                if (asset != null) {
                                  if (asset.type == AssetType.image) {
                                    controller.bankDetails['valid_id'] =
                                        await asset.file;
                                    if ((controller.bankDetails['bank_code'] ??
                                                    '')
                                                .trim()
                                                .length >
                                            0 &&
                                        (controller.bankDetails[
                                                        'account_name'] ??
                                                    '')
                                                .trim()
                                                .length >
                                            0 &&
                                        (controller.bankDetails[
                                                        'account_number'] ??
                                                    '')
                                                .trim()
                                                .length >
                                            0 &&
                                        controller.bankDetails['valid_id'] !=
                                            null) {
                                      controller.isChanged.value = true;
                                    } else {
                                      controller.isChanged.value = false;
                                    }
                                    // controller.isChanged.refresh();
                                  } else {
                                    PlatformAlertDialog(
                                      title: 'Invalid file',
                                      content: 'Upload images only.',
                                      actions: [
                                        PlatformAlertDialogAction(
                                          child: Text('OK'),
                                          isDefaultAction: true,
                                          onPressed: () => navigator?.pop(),
                                        )
                                      ],
                                    ).show();
                                  }
                                }
                              },
                              child: controller.bankDetails['valid_id'] == null
                                  ? Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: Colors.grey[200],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Upload a photo of your valid ID',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Stack(children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          child: controller.bankDetails[
                                                      'valid_id'] !=
                                                  null
                                              ? controller.bankDetails[
                                                      'valid_id'] is File
                                                  ? Image.file(controller
                                                      .bankDetails['valid_id'])
                                                  : CachedNetworkImage(
                                                      fadeInDuration:
                                                          Duration(seconds: 0),
                                                      placeholderFadeInDuration:
                                                          Duration(seconds: 0),
                                                      fadeOutDuration:
                                                          Duration(seconds: 0),
                                                      imageUrl: controller
                                                              .bankDetails[
                                                          'valid_id'])
                                              : Container()),
                                      controller.bankDetails['id'] == null
                                          ? Positioned(
                                              top: 7.5,
                                              right: 7.5,
                                              child: InkWell(
                                                onTap: () {
                                                  controller.bankDetails[
                                                      'valid_id'] = null;
                                                  controller.bankDetails
                                                      .refresh();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      color: Colors.black
                                                          .withOpacity(0.75)),
                                                  child: Transform.translate(
                                                    offset: Offset(0, -1),
                                                    child: Icon(
                                                      FeatherIcons.x,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink()
                                    ]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'List of accepted IDs',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.5,
                                  color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'Passport',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'Driver\'s license',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'PRC',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'TIN',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'UMID',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\u2022',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.5,
                                          color: Colors.black54),
                                    )),
                                Text(
                                  'NBI clearance',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: Colors.black54),
                                )
                              ],
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
            controller.bankDetails['id'] == null
                ? SizedBox.shrink()
                : Container(
                    color: Colors.grey[700]?.withOpacity(.6),
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey[200]),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  isVerified
                                      ? FeatherIcons.checkCircle
                                      : FeatherIcons.clock,
                                  size: 40,
                                  color: isVerified
                                      ? Colors.green
                                      : Colors.black38),
                              const SizedBox(height: 10),
                              Text(
                                isVerified
                                    ? 'Your bank is verified. If you wish to edit your bank details, please contact us at alterr@codabyte.io'
                                    : 'Your bank information is being verified. We will notify you once the verification status is complete.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              )
                            ]),
                      ),
                    )),
            controller.updatingBank.value == true
                ? Container(
                    color: Colors.grey[700]?.withOpacity(.6),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: PlatformSpinner(
                        radius: 10,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                        brightness: Brightness.dark,
                      ),
                    ))
                : SizedBox.shrink(),
            controller.bankLoading.value == true
                ? Container(
                    color: Colors.white,
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: PlatformSpinner(
                        radius: 10,
                        width: 20,
                        height: 20,
                      ),
                    ))
                : SizedBox.shrink()
          ],
        )));
  }

  _showBankPicker(BuildContext context) {
    final _scrollController = ScrollController();
    PlatformBottomsheetModal(
            child: Scaffold(
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select bank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () => {
                            controller.loading.value
                                ? null
                                : Navigator.pop(context)
                          },
                          child: Obx(() => Text(
                                'Done',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(controller.loading.value
                                            ? 0.25
                                            : 1.0)),
                              )),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() => ListView.builder(
                        physics: ClampingScrollPhysics(),
                        controller: _scrollController,
                        itemCount: controller.banks.length,
                        itemBuilder: (context, index) {
                          String key = controller.banks.keys.elementAt(index);
                          Color backgroundColor = Colors.transparent;
                          Color textColor = Colors.black;
                          if (controller.bankDetails['bank_code'] == key) {
                            backgroundColor = Theme.of(context).primaryColor;
                            textColor = Colors.white;
                          }
                          return InkWell(
                            onTap: () {
                              controller.bankDetails['bank_code'] = key;
                              if ((controller.bankDetails['bank_code'] ?? '')
                                          .trim()
                                          .length >
                                      0 &&
                                  (controller.bankDetails['account_name'] ?? '')
                                          .trim()
                                          .length >
                                      0 &&
                                  (controller.bankDetails['account_number'] ??
                                              '')
                                          .trim()
                                          .length >
                                      0) {
                                controller.isChanged.value = true;
                              } else {
                                controller.isChanged.value = false;
                              }
                              controller.isChanged.refresh();
                              navigator?.pop();
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Colors.black.withOpacity(0.05)))),
                              child: Text(
                                controller.banks[key],
                                style:
                                    TextStyle(fontSize: 15.5, color: textColor),
                              ),
                            ),
                          );
                        })),
                  )
                ],
              ),
            ),
            context: context)
        .show();
    Future.delayed(Duration(milliseconds: 50)).then((value) {
      List _banks = controller.banks.entries.map((entry) => entry.key).toList();
      int _activeIndex = _banks.indexOf(controller.bankDetails['bank_code']);
      if (_activeIndex > 0) {
        if (_activeIndex > controller.banks.entries.length - 14) {
          _activeIndex = controller.banks.entries.length - 14;
        }
        _scrollController.jumpTo(48.0 * _activeIndex);
      }
    });
  }

  _openCashoutForm(context) {
    controller.insufficient.value = false;
    FocusNode amountFocus = new FocusNode();
    PlatformBottomsheetModal(
            child: Container(
              color: Color(0xFFF9F9F9),
              padding: EdgeInsets.only(top: 15),
              child: Scaffold(
                  appBar: CustomAppBar(
                    leading: InkWell(
                      onTap: () => {
                        controller.submittingCashout.value
                            ? null
                            : navigator?.pop()
                      },
                      child: Obx(() => Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(
                                        controller.submittingCashout.value
                                            ? 0.25
                                            : 1.0)),
                          )),
                    ),
                    title: 'Request Cashout',
                  ).build(),
                  body: Container(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      padding: EdgeInsets.all(7.5),
                      child: KeyboardActions(
                        disableScroll: true,
                        config: KeyboardActionsConfig(
                          keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
                          actions: [
                            KeyboardActionsItem(
                              focusNode: amountFocus,
                              displayArrows: false,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount (minimum of ₱100.00)',
                              style: TextStyle(fontSize: 15.5),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                Text(
                                  '₱ ',
                                  style: TextStyle(fontSize: 28, height: 1.4),
                                ),
                                Expanded(
                                  child: TextField(
                                    autofocus: true,
                                    focusNode: amountFocus,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          (RegExp("[0-9]")))
                                    ],
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontSize: 28),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                          fontSize: 28, color: Colors.black26),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                    ),
                                    onChanged: (String value) {
                                      if (value != '' && value.length > 0) {
                                        double parsedValue =
                                            double.parse(value);
                                        if (parsedValue >
                                            controller.availableBalance.value) {
                                          controller.insufficient.value = true;
                                        } else {
                                          controller.insufficient.value = false;
                                        }
                                        controller.insufficient.refresh();
                                        controller.cashoutRequest.value =
                                            parsedValue;
                                      } else {
                                        controller.cashoutRequest.value = 0.0;
                                      }
                                      controller.cashoutRequest.refresh();
                                    },
                                  ),
                                )
                              ]),
                            ),
                            SizedBox(height: 6),
                            Obx(() => controller.insufficient.value == true
                                ? Container(
                                    margin: EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      'Insufficient balance',
                                      style: TextStyle(
                                          fontSize: 15.5, color: Colors.red),
                                    ),
                                  )
                                : SizedBox.shrink()),
                            SizedBox(height: 6),
                            Obx(() => CustomButton(
                                  onPressed: () =>
                                      {controller.requestCashout()},
                                  loading: controller.submittingCashout.value,
                                  disabled: controller.loading.value ||
                                      controller.cashoutRequest.value < 1.0 ||
                                      controller.insufficient.value,
                                  label: 'Submit',
                                )),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
            context: context,
            enableDrag: false,
            isDismissible: false)
        .show();
  }
}

class _MonetizationController extends GetxController {
  RxBool loading = false.obs;
  RxBool cashoutsLoading = false.obs;
  RxBool isChanged = false.obs;
  RxBool insufficient = false.obs;
  RxBool submittingCashout = false.obs;
  RxList<dynamic> cashouts = [].obs;
  RxMap<String, dynamic> bankDetails = <String, dynamic>{}.obs;
  RxMap<String, dynamic> banks = <String, dynamic>{}.obs;
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  RxDouble availableBalance = 0.0.obs;
  RxInt bariasEarned = 0.obs;
  RxDouble cashoutRequest = 0.0.obs;
  RxString idType = 'file'.obs;
  RxBool updatingBank = false.obs;
  RxBool bankLoading = false.obs;
  RxBool isAffiliate = false.obs;
  RxDouble affiliateBalance = 0.0.obs;

  requestCashout() async {
    submittingCashout.value = true;
    Map<String, dynamic>? response = await ApiService().request(
        'auth/cashouts', {'amount': cashoutRequest.value}, 'POST',
        withToken: true);
    if (response != null) {
      cashouts.add(response['cashout']);
      cashouts.refresh();
      availableBalance.value =
          double.parse(response['available_balance'].toString());
      availableBalance.refresh();
      navigator?.pop();
    }
    submittingCashout.value = false;
  }

  updateBank(AuthController authController, context) async {
    loading.value = true;
    updatingBank.value = true;
    loading.refresh();
    updatingBank.refresh();

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String randomString = Helpers.randomString();
    String validIdSourceName = Helpers.randomString();
    validIdSourceName = 'validIdSourceName.jpg';

    Directory tempDir = await getTemporaryDirectory();
    String idTmpPath = '${tempDir.path}/$timestamp-validID.jpg';

    bankDetails['valid_id'] = await FlutterImageCompress.compressAndGetFile(
        bankDetails['valid_id'].path, idTmpPath,
        autoCorrectionAngle: true, quality: 50, minWidth: 1200, keepExif: true);

    String s3Path = 'banks/${authController.user?.id}-$randomString-$timestamp';
    String sourcePath = await S3.uploadFile(
      s3Path,
      {'file': bankDetails['valid_id'], 'filename': '$validIdSourceName'},
    );
    Map<String, dynamic> data = {
      'bank_code': bankDetails['bank_code'],
      'account_number': bankDetails['account_number'],
      'account_name': bankDetails['account_name'],
      'valid_id': sourcePath
    };

    Map<String, dynamic>? response =
        await ApiService().request('auth/bank', data, 'POST', withToken: true);
    if (response != null) {
      bankDetails.value = response;
    }
    loading.value = false;
    updatingBank.value = false;
    loading.refresh();
    updatingBank.refresh();
  }

  getBank() async {
    bankLoading.value = true;
    Map<String, dynamic> response =
        await ApiService().request('auth/bank', {}, 'GET', withToken: true);
    bankDetails.value = response;
    bankLoading.value = false;
    bankLoading.refresh();
    bankDetails.refresh();
  }

  getBanks() async {
    Map<String, dynamic>? response =
        await ApiService().request('banks', {}, 'GET', withToken: true);
    if (response != null) {
      idType.value = 's3';
      banks.value = response;
    }
  }

  getCashouts() async {
    if (bankDetails['id'] != null) {
      cashoutsLoading.value = true;
      cashoutsLoading.refresh();
      Map<String, dynamic>? response = await ApiService()
          .request('auth/cashouts', {}, 'GET', withToken: true);
      if (response != null) {
        availableBalance.value =
            double.parse(response['available_balance'].toString());
        bariasEarned.value = response['barias'];
        cashouts.value = response['cashouts'];
        isAffiliate.value = response['is_affiliate'];
        affiliateBalance.value =
            double.parse(response['affiliate_balance'].toString());

        availableBalance.refresh();
        bariasEarned.refresh();
        cashouts.refresh();
        isAffiliate.refresh();
        affiliateBalance.refresh();
      }
    }
  }
}
