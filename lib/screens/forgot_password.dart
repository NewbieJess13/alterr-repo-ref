import 'package:alterr/utils/custom_button.dart';
import 'package:alterr/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/validate_email.dart';
import 'package:alterr/services/api.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _ForgotPasswordController controller =
      Get.put(_ForgotPasswordController());
  final FocusNode emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 65,
        leading: controller.success.value == true
            ? Container()
            : IconButton(
                splashRadius: 15.0,
                color: Colors.black87,
                icon: Transform.translate(
                  offset: Offset(0, -1),
                  child: Icon(FeatherIcons.arrowLeft),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: Obx(() => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: controller.success.value == true
                  ? _successContent(context)
                  : _form(context),
            ),
          )),
    );
  }

  Widget _successContent(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor.withOpacity(0.15),
              ),
              child: Transform.translate(
                offset: Offset(0, -2),
                child: Icon(
                  FeatherIcons.inbox,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Check your mailbox',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'We have sent a password reset instructions to your email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.5, color: Colors.black54),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: CustomButton(
                label: 'Open email app',
                onPressed: () async {
                  var result = await OpenMailApp.openMailApp();

                  if (!result.didOpen && !result.canOpen) {
                    PlatformAlertDialog(
                      title: 'Open Mail App',
                      content: 'No mail apps installed on this device.',
                      actions: [
                        PlatformAlertDialogAction(
                          child: Text('OK'),
                          isDefaultAction: true,
                          onPressed: () => navigator?.pop(),
                        )
                      ],
                    ).show();
                  } else if (!result.didOpen && result.canOpen) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return MailAppPickerDialog(
                          mailApps: result.options,
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: CustomButton(
                color: Colors.black54,
                theme: 'bordered',
                label: 'Skip, I\'ll confirm later',
                onPressed: () {
                  controller.success.value = false;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Forgot password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Enter the email associated with your account and we\'ll send an email with instructions to reset your password.',
              style: TextStyle(fontSize: 15.5, color: Colors.black54),
            ),
            SizedBox(height: 40),
            CustomTextField(
              title: 'Email address',
              autofocus: true,
              focusNode: emailFocus,
              textInputType: TextInputType.emailAddress,
              onChanged: (value) {
                controller.email.value = value.trim();
              },
            ),
            SizedBox(height: 10),
            CustomButton(
              loading: controller.loading.value,
              disabled: controller.loading.value ||
                  controller.email.value.trim().length == 0,
              label: 'Send password reset link',
              onPressed: () {
                if (controller.email.value.trim().length == 0 ||
                    !EmailValidator.validate(controller.email.value.trim())) {
                  return emailFocus.requestFocus();
                }
                controller.sendPasswordResetLink(context);
              },
            ),
            SizedBox(height: 50)
          ]),
    );
  }
}

class _ForgotPasswordController extends GetxController {
  Rx<bool> loading = false.obs;
  Rx<bool> success = false.obs;
  RxString email = ''.obs;

  sendPasswordResetLink(context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    Map<String, dynamic>? response = await ApiService()
        .request('auth/password_reset', {'email': email.value}, 'POST');
    if (response != null) {
      success.value = true;
    }
    loading.value = false;
  }
}
