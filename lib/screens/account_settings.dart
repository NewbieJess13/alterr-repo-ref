import 'dart:io';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/models/user.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:alterr/utils/custom_toggle.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/services/api.dart';
import 'package:intl/intl.dart';
import 'package:alterr/utils/validate_email.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class AccountSettingsScreen extends StatelessWidget {
  final _EditAccountController controller = new _EditAccountController();
  final AuthController authController = Get.put(AuthController());
  Widget contentScreen = Container();

  @override
  Widget build(BuildContext context) {
    controller.emailController.text = authController.user!.email!;
    controller.newEmail.value = authController.user!.email!;
    controller.newBirthdate.value = authController.user!.birthdate!;

    return _accountSettings(context);
  }

  Widget _accountSettings(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
          title: 'Settings',
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

        /* Account Information */
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 15),
          child: Text(
            'Account Information',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _editEmail(context)));
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(fontSize: 15.5, height: 1),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Obx(() => Text(
                              authController.user!.email!,
                              style: TextStyle(
                                  fontSize: 15.5,
                                  color: Colors.black54,
                                  height: 1),
                            ))
                      ],
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
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _editBirthdate(context)));
            showDatePicker(context);
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birthdate',
                          style: TextStyle(fontSize: 15.5, height: 1),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Obx(() => Text(
                              DateFormat('MMMM dd, y').format(DateTime.parse(
                                  authController.user!.birthdate!)),
                              style: TextStyle(
                                  fontSize: 15.5,
                                  color: Colors.black54,
                                  height: 1),
                            ))
                      ],
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                  )
                ],
              )),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 7.5, color: Colors.black.withOpacity(0.075)))),
        ),

        /* Security */
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 15, top: 15),
          child: Text(
            'Security',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _editPassword(context)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.05)),
              )),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Password',
                      style: TextStyle(fontSize: 15.5, height: 1),
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                  )
                ],
              )),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 7.5, color: Colors.black.withOpacity(0.075)))),
        ),

        /* Notification Settings */
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 15, top: 15),
          child: Text(
            'Notification Settings',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _notifications(context)));
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
                      'Manage notifications',
                      style: TextStyle(fontSize: 15.5, height: 1),
                    ),
                  ),
                  Icon(
                    FeatherIcons.chevronRight,
                  )
                ],
              )),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 7.5, color: Colors.black.withOpacity(0.075)))),
        ),

        /* Account Management */
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 15, top: 15),
          child: Text(
            'Account Management',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _deactivate(context)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.05)),
              )),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Deactive account',
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
            Navigator.of(context).push<void>(
                SwipeablePageRoute(builder: (_) => _blocking(context)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.05)),
              )),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Blocking',
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

  Widget spinner() {
    Widget spinner = CupertinoActivityIndicator(
      radius: 9,
    );
    if (Platform.isAndroid) {
      spinner = SizedBox(
        height: 15,
        width: 15,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
        ),
      );
    }
    return spinner;
  }

  Widget _editEmail(context) {
    return Scaffold(
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
            title: 'Update email',
            action: Obx(() => controller.loading.value == true
                ? spinner()
                : InkWell(
                    onTap: controller.isChanged.value == false ||
                            controller.newEmail.trim().length == 0
                        ? null
                        : () =>
                            controller.updateAccount(authController, context),
                    child: Opacity(
                      opacity: controller.isChanged.value == false ||
                              controller.newEmail.trim().length == 0
                          ? 0.5
                          : 1,
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ))).build(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Email',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        autofocus: true,
                        focusNode: controller.emailFocus,
                        readOnly: controller.loading.value,
                        controller: controller.emailController,
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
                          controller.newEmail.value = value.trim();
                          controller.isChanged.value = true;
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
          ],
        ));
  }

  Widget _editBirthdate(context) {
    return Scaffold(
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
            title: 'Update birthdate',
            action: Obx(() => controller.loading.value == true
                ? spinner()
                : InkWell(
                    onTap: controller.isChanged.value == false ||
                            controller.newEmail.trim().length == 0
                        ? null
                        : () =>
                            controller.updateAccount(authController, context),
                    child: Opacity(
                      opacity: controller.isChanged.value == false ||
                              controller.newEmail.trim().length == 0
                          ? 0.5
                          : 1,
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ))).build(),
        body: Column(
          children: [
            InkWell(
              onTap: () => showDatePicker(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Birthdate',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Obx(() => Text(
                            DateFormat('MMMM dd, y').format(
                                DateTime.parse(controller.newBirthdate.value)),
                            style: TextStyle(fontSize: 15.5))),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
            ),
          ],
        ));
  }

  showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      currentTime: DateTime.parse(controller.newBirthdate.value),
      showTitleActions: true,
      minTime: DateTime(1940),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        controller.newBirthdate.value = DateFormat('yyyy-MM-dd').format(date);
        controller.newBirthdate.refresh();
        controller.isChanged.value = true;
      },
      theme: DatePickerTheme(
        cancelStyle:
            TextStyle(fontWeight: FontWeight.w300, color: Colors.black87),
        doneStyle: TextStyle(fontWeight: FontWeight.w700),
        itemStyle: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _editPassword(context) {
    return Scaffold(
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
            title: 'Update password',
            action: Obx(() => controller.loading.value == true
                ? spinner()
                : InkWell(
                    onTap: controller.isChanged.value == false ||
                            controller.newEmail.trim().length == 0
                        ? null
                        : () =>
                            controller.updateAccount(authController, context),
                    child: Opacity(
                      opacity: controller.isChanged.value == false ||
                              controller.newEmail.trim().length == 0
                          ? 0.5
                          : 1,
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ))).build(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      'Current password',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        autofocus: true,
                        focusNode: controller.currentPasswordFocus,
                        readOnly: controller.loading.value,
                        obscureText: true,
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
                          controller.currentPassword.value = value;
                          if (controller.currentPassword.value.length > 0 &&
                              controller.newPassword.value.length > 0 &&
                              controller.confirmPassword.value.length > 0) {
                            controller.isChanged.value = true;
                          } else {
                            controller.isChanged.value = false;
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 10, color: Colors.black.withOpacity(0.075)))),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      'New password',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        autofocus: false,
                        focusNode: controller.newPasswordFocus,
                        readOnly: controller.loading.value,
                        obscureText: true,
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
                          controller.newPassword.value = value;
                          if (controller.currentPassword.value.length > 0 &&
                              controller.newPassword.value.length > 0 &&
                              controller.confirmPassword.value.length > 0) {
                            controller.isChanged.value = true;
                          } else {
                            controller.isChanged.value = false;
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      'Confirm password',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        autofocus: false,
                        focusNode: controller.confirmPasswordFocus,
                        readOnly: controller.loading.value,
                        obscureText: true,
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
                          controller.confirmPassword.value = value;
                          if (controller.currentPassword.value.length > 0 &&
                              controller.newPassword.value.length > 0 &&
                              controller.confirmPassword.value.length > 0) {
                            controller.isChanged.value = true;
                          } else {
                            controller.isChanged.value = false;
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
          ],
        ));
  }

  Widget _deactivate(context) {
    return Scaffold(
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
          title: 'Deactivate',
        ).build(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(bottom: 15, top: 15),
              child: Text(
                'What deactivating your account means',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15.5, height: 1),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                'You will no longer receive notifications from us.',
                style: TextStyle(
                    fontSize: 15.5, height: 1.3, color: Colors.black54),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                'You will not be able to log back into the site or app.',
                style: TextStyle(
                    fontSize: 15.5, height: 1.3, color: Colors.black54),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                'You current earnings will be credited to your bank.',
                style: TextStyle(
                    fontSize: 15.5, height: 1.3, color: Colors.black54),
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(top: 15),
              child: Text(
                'Please provide your password below to confirm the deactivation of your account:',
                style: TextStyle(fontSize: 15.5, height: 1.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: CustomTextField(
                title: 'Password',
                isPassword: true,
                onChanged: (value) {
                  controller.deletePassword.value = value;
                  if (controller.deletePassword.value.length > 0) {
                    controller.isChanged.value = true;
                  } else {
                    controller.isChanged.value = false;
                  }
                },
              ),
            ),
            Obx(() => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: CustomButton(
                    disabled: controller.deletePassword.value.length == 0 ||
                        controller.loading.value == true,
                    loading: controller.loading.value == true,
                    onPressed: () =>
                        {controller.deactivateAccount(context, authController)},
                    label: 'Deactivate account',
                    color: Colors.white,
                    theme: 'danger',
                  ),
                )),
          ],
        ));
  }

  Widget _notifications(context) {
    final Rx<Settings> userSettings =
        Get.find<AuthController>().user!.settings!.obs;
    return Scaffold(
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
        title: 'Manage Notifications',
      ).build(),
      body: Obx(() => Column(
            children: [
              ListTile(
                title: Text(
                  'New message',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: CustomToggleSwitch(
                  value: userSettings.value.newMessage == '1',
                  onChanged: (isToggled) {
                    userSettings
                      ..value.newMessage = isToggled ? '1' : '0'
                      ..refresh();
                    Get.find<AuthController>().user?.settings =
                        userSettings.value;
                    controller.updateNotifications();
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Post like',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: CustomToggleSwitch(
                  value: userSettings.value.postLike == '1',
                  onChanged: (isToggled) {
                    userSettings
                      ..value.postLike = isToggled ? '1' : '0'
                      ..refresh();
                    Get.find<AuthController>().user?.settings =
                        userSettings.value;
                    controller.updateNotifications();
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Post comment',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: CustomToggleSwitch(
                  value: userSettings.value.postComment == '1',
                  onChanged: (isToggled) {
                    userSettings
                      ..value.postComment = isToggled ? '1' : '0'
                      ..refresh();
                    Get.find<AuthController>().user?.settings =
                        userSettings.value;
                    controller.updateNotifications();
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Post unlock',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: CustomToggleSwitch(
                  value: userSettings.value.postUnlock == '1',
                  onChanged: (isToggled) {
                    userSettings
                      ..value.postUnlock = isToggled ? '1' : '0'
                      ..refresh();
                    Get.find<AuthController>().user?.settings =
                        userSettings.value;
                    controller.updateNotifications();
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Comment like',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: CustomToggleSwitch(
                  value: userSettings.value.commentLike == '1',
                  onChanged: (isToggled) {
                    userSettings
                      ..value.commentLike = isToggled ? '1' : '0'
                      ..refresh();
                    Get.find<AuthController>().user?.settings =
                        userSettings.value;
                    controller.updateNotifications();
                  },
                ),
              ),
              Divider(),
            ],
          )),
    );
  }

  Widget _blocking(context) {
    controller.getBlockedAccounts();
    return Scaffold(
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
          title: 'Blocked Accounts',
        ).build(),
        body: Obx(
          () => controller.blockingLoading.value == true
              ? Center(
                  child: PlatformSpinner(
                    width: 20,
                    height: 20,
                  ),
                )
              : controller.blockedUsers.length > 0
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        Map<String, dynamic> blockedUser =
                            controller.blockedUsers[index];
                        return Container(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                blockedUser['blocked_user']
                                                ['profile_picture'] !=
                                            null &&
                                        blockedUser['blocked_user']
                                                ['profile_picture'] !=
                                            ''
                                    ? CachedNetworkImage(
                                        fadeInDuration: Duration(seconds: 0),
                                        placeholderFadeInDuration:
                                            Duration(seconds: 0),
                                        fadeOutDuration: Duration(seconds: 0),
                                        imageUrl: blockedUser['blocked_user']
                                            ['profile_picture'],
                                        imageBuilder: (context,
                                                imageProvider) =>
                                            CircleAvatar(
                                                radius: 18,
                                                backgroundImage: imageProvider,
                                                backgroundColor:
                                                    Colors.grey[200]),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                                radius: 18,
                                                backgroundImage: AssetImage(
                                                    'assets/images/profile-placeholder.png')),
                                        placeholder: (context, string) =>
                                            CircleAvatar(
                                                radius: 18,
                                                backgroundImage: AssetImage(
                                                    'assets/images/profile-placeholder.png')),
                                      )
                                    : CircleAvatar(
                                        radius: 18,
                                        backgroundImage: AssetImage(
                                            'assets/images/profile-placeholder.png')),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        blockedUser['blocked_user']['username'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.5),
                                      ),
                                      blockedUser['blocked_user']['bio'] != null
                                          ? Text(
                                              blockedUser['blocked_user']
                                                  ['bio'],
                                              style: TextStyle(
                                                  fontSize: 15.5, height: 1.35),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(7.5)),
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.blockedUsers.removeAt(index);
                                      controller.unblockUser(blockedUser);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 10),
                                      child: Text(
                                        'Unblock',
                                        style: TextStyle(
                                            fontSize: 15.5, height: 1.1),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ));
                      },
                      itemCount: controller.blockedUsers.length,
                    )
                  : Center(
                      child: Text(
                        'No blocked accounts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black26, fontSize: 17),
                      ),
                    ),
        ));
  }
}

class _EditAccountController extends GetxController {
  RxBool isChanged = false.obs;
  RxString newEmail = ''.obs;
  RxString newBirthdate = ''.obs;
  RxString currentPassword = ''.obs;
  RxString newPassword = ''.obs;
  RxString confirmPassword = ''.obs;
  RxString deletePassword = ''.obs;
  RxBool loading = false.obs;
  FocusNode emailFocus = FocusNode();
  FocusNode currentPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();
  RxBool blockingLoading = true.obs;
  RxList<dynamic> blockedUsers = [].obs;

  unblockUser(blockedUser) {
    ApiService().request(
        'users/${blockedUser['blocked_user']['username']}/block',
        {'is_blocked': false},
        'PUT',
        withToken: true);
  }

  getBlockedAccounts() async {
    blockingLoading.value = true;
    List<dynamic> response = await ApiService()
        .request('users/blocked_users', {}, 'GET', withToken: true);
    blockedUsers.value = response;
    blockingLoading.value = false;
  }

  deactivateAccount(pageController, authController) async {
    loading.value = true;

    Map<String, dynamic> response = await ApiService().request(
        'auth/deactivate', {'password': deletePassword.value}, 'POST',
        withToken: true);
    if (response != null) {
      await authController.signOut();
      navigator?.pop();
      navigator?.pop();
      pageController.animateToPage(0,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
    loading.value = false;
    loading.refresh();
  }

  updateAccount(authController, context) async {
    if (newEmail.value.trim().length == 0 ||
        !EmailValidator.validate(newEmail.value)) {
      return emailFocus.requestFocus();
    }

    loading.value = true;

    Map<String, dynamic> data = {};
    data['email'] = newEmail.value.trim();
    data['birthdate'] = newBirthdate.value;

    if (currentPassword.value.length > 0 &&
        newPassword.value.length > 0 &&
        confirmPassword.value.length > 0) {
      data['old_password'] = currentPassword.value;
      data['password'] = newPassword.value;
      data['password_confirmation'] = confirmPassword.value;
    }

    Map<String, dynamic> response =
        await ApiService().request('auth/update', data, 'PUT', withToken: true);
    if (response != null) {
      authController.user.value.email = response['email'];
      authController.user.value.birthdate = response['birthdate'];
      authController.user.refresh();

      Navigator.pop(context);
    }

    loading.value = false;
    loading.refresh();
  }

  updateNotifications() async {
    await ApiService().request('auth/user_settings',
        Get.find<AuthController>().user!.settings!.toJson(), 'PUT',
        withToken: true);
  }
}
