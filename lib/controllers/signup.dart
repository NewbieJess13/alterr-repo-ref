import 'package:alterr/controllers/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alterr/services/localstorage.dart';
import 'package:alterr/services/api.dart';

class SignupController extends GetxController {
  RxBool showPassword = false.obs;
  RxString username = ''.obs;
  RxString email = ''.obs;
  RxString password = ''.obs;
  TextEditingController birthdate = TextEditingController();
  RxBool setProfilePicture = false.obs;
  RxBool loading = false.obs;
  RxString birthdateFormat = ''.obs;

  Future signUp(Map<String, dynamic> signUpData) async {
    loading.value = true;
    Map<String, dynamic>? response = await ApiService().request(
      'auth/signup',
      signUpData,
      'POST',
    );
    if (response != null) {
      await LocalStorage.saveUserTokenSharedPref(response['access_token']);
      AuthController authController = Get.find<AuthController>();
      authController.getAuth();
    }
    loading.value = false;
    return response;
  }
}
