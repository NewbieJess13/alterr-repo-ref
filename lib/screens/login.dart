import 'package:alterr/controllers/auth.dart';
import 'package:alterr/screens/forgot_password.dart';
import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:alterr/screens/signup.dart';

class LoginScreen extends StatelessWidget {
  final bool isLoading = true;
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 35,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        focusNode: emailFocus,
                        textInputAction: TextInputAction.next,
                        title: 'Email or username',
                        controller: authController.emailController,
                      ),
                      const SizedBox(height: 15),
                      Obx(() => Stack(
                            children: [
                              CustomTextField(
                                padding: EdgeInsets.only(right: 26),
                                focusNode: passwordFocus,
                                title: 'Password',
                                isPassword: !authController.showPassword.value,
                                controller: authController.passwordController,
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      authController.showPassword.value =
                                          !authController.showPassword.value;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0,
                                              color: Colors.transparent)),
                                      height: 48,
                                      width: 35,
                                      child: Icon(
                                        authController.showPassword.value
                                            ? FeatherIcons.eyeOff
                                            : FeatherIcons.eye,
                                        size: 20,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ))
                            ],
                          )),
                      const SizedBox(height: 15),
                      Obx(() => CustomButton(
                            loading: authController.loginLoading.value,
                            disabled: authController.loginLoading.value,
                            onPressed: () {
                              login(context);
                            },
                            label: 'Login',
                          )),
                      const SizedBox(height: 15),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push<void>(SwipeablePageRoute(
                                builder: (_) => ForgotPasswordScreen()));
                          },
                          child: Text('Forgot password?',
                              style: TextStyle(
                                  letterSpacing: -0.2,
                                  color: Colors.black54,
                                  fontSize: 15.5))),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withOpacity(0.025),
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            letterSpacing: -0.2,
                            color: Colors.black54,
                            fontSize: 15.5),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push<void>(
                            SwipeablePageRoute(builder: (_) => SignUpScreen())),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 15.5,
                              color: Theme.of(context).primaryColor),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ])),
    );
  }

  void login(context) async {
    if (authController.emailController.text.trim().length == 0) {
      return emailFocus.requestFocus();
    }
    if (authController.passwordController.text.trim().length == 0) {
      return passwordFocus.requestFocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String?> loginCredential = {
      'emailOrUsername': authController.emailController.text.trim(),
      'password': authController.passwordController.text,
      'firebase_token': await FirebaseMessaging.instance.getToken(),
    };

    await authController.login(loginCredential);
  }
}
