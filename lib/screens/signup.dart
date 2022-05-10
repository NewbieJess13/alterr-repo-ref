import 'package:alterr/controllers/signup.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:alterr/utils/validate_email.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  final controller = Get.put(SignupController());
  final FocusNode usernameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode birthdateFocus = FocusNode();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: AppBar(
            leading: IconButton(
              splashRadius: 15.0,
              color: Colors.black87,
              icon: Transform.translate(
                  offset: Offset(0, -1), child: Icon(FeatherIcons.arrowLeft)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            leadingWidth: 65,
            automaticallyImplyLeading: false,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
          )),
      body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            top: false,
            child: _signUpForm(context),
          )),
    );
  }

  _signUp(context) async {
    if (!EmailValidator.validate(controller.email.value)) {
      return emailFocus.requestFocus();
    }

    if (controller.username.value.trim().length == 0) {
      return usernameFocus.requestFocus();
    }

    if (controller.password.value.trim().length == 0) {
      return passwordFocus.requestFocus();
    }

    if (controller.birthdate.value.text.trim().length == 0) {
      return birthdateFocus.requestFocus();
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await controller.signUp({
      'username': controller.username.value,
      'email': controller.email.value,
      'password': controller.password.value,
      'birthdate': controller.birthdateFormat.value,
      'firebase_token': await FirebaseMessaging.instance.getToken(),
    });
  }

  Widget _signUpForm(context) {
    return Obx(() => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).viewInsets.bottom == 0 ? 100 : 0,
                ),
                Text(
                  'Create an account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  title: 'Username',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
                  ],
                  onChanged: (e) {
                    controller.username.value =
                        e.toString().trim().toLowerCase();
                    usernameController.text = controller.username.value;
                    usernameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.username.value.length));
                  },
                ),
                SizedBox(height: 10),
                CustomTextField(
                  focusNode: emailFocus,
                  textInputAction: TextInputAction.next,
                  title: 'Email',
                  textInputType: TextInputType.emailAddress,
                  onChanged: (e) {
                    controller.email.value = e.toString().trim();
                  },
                ),
                SizedBox(height: 10),
                Stack(
                  children: [
                    CustomTextField(
                      padding: EdgeInsets.only(right: 26),
                      title: 'Password',
                      isPassword: !controller.showPassword.value,
                      onChanged: (e) => {controller.password.value = e},
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            controller.showPassword.value =
                                !controller.showPassword.value;
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0, color: Colors.transparent)),
                            height: 48,
                            width: 35,
                            child: Icon(
                              controller.showPassword.value
                                  ? FeatherIcons.eyeOff
                                  : FeatherIcons.eye,
                              size: 20,
                              color: Colors.black45,
                            ),
                          ),
                        ))
                  ],
                ),
                SizedBox(height: 10),
                CustomTextField(
                  readOnly: true,
                  focusNode: birthdateFocus,
                  controller: controller.birthdate,
                  textInputAction: TextInputAction.next,
                  title: 'Birthdate',
                  textInputType: TextInputType.emailAddress,
                  onTap: () {
                    showDatePicker(context);
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13.5, color: Colors.black54),
                    text: 'By creating an account, you agree to our ',
                    children: [
                      TextSpan(
                          style: TextStyle(
                              fontSize: 13.5,
                              color: Theme.of(context).primaryColor),
                          text: 'Terms and Conditions',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showTAC()),
                      TextSpan(
                        style: TextStyle(fontSize: 13.5, color: Colors.black54),
                        text: ' and ',
                      ),
                      TextSpan(
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Theme.of(context).primaryColor),
                        text: 'Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPolicy(),
                      ),
                      TextSpan(
                        style: TextStyle(fontSize: 13.5, color: Colors.black54),
                        text: '.',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Obx(() => CustomButton(
                      loading: controller.loading.value,
                      disabled: controller.username.value.trim().length == 0 ||
                          controller.email.value.trim().length == 0 ||
                          controller.password.value.trim().length == 0 ||
                          controller.birthdateFormat.value.trim().length == 0 ||
                          controller.loading.value,
                      label: 'Create account',
                      onPressed: () => _signUp(context),
                    )),
              ],
            ),
          ),
        ));
  }

  showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1940),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        controller.birthdate.text = DateFormat('MMMM d, y').format(date);
        controller.birthdateFormat.value =
            DateFormat('yyyy-MM-dd').format(date);
      },
      theme: DatePickerTheme(
        cancelStyle:
            TextStyle(fontWeight: FontWeight.w300, color: Colors.black87),
        doneStyle: TextStyle(fontWeight: FontWeight.w700),
        itemStyle: TextStyle(fontSize: 15),
      ),
    );
  }

  _showTAC() {
    navigator?.push(new MaterialPageRoute<Null>(
        fullscreenDialog: true,
        builder: (context) => Material(
                child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => {Navigator.pop(context)},
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: WebView(
                      gestureNavigationEnabled: false,
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: 'https://alterr.app/terms-and-conditions',
                    ),
                  )
                ],
              ),
            ))));
  }

  _showPolicy() {
    navigator?.push(new MaterialPageRoute<Null>(
        fullscreenDialog: true,
        builder: (context) => Material(
                child: SafeArea(
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => {Navigator.pop(context)},
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: WebView(
                      gestureNavigationEnabled: false,
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: 'https://alterr.app/privacy-policy',
                    ),
                  )
                ],
              ),
            ))));
  }
}
