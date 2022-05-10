import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/screens/main.dart';
import 'package:alterr/screens/login.dart';

class AuthScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => authController.loading.value
        ? Scaffold(
            body: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 35,
              ),
            ),
          )
        : authController.authenticated.value == true
            ? MainScreen()
            : Navigator(
                key: GlobalKey<NavigatorState>(),
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(builder: (context) => LoginScreen());
                },
              ));
  }
}
