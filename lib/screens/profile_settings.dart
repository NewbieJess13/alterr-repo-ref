import 'dart:io';
import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/profile.dart';
import 'package:alterr/helpers/helpers.dart';
import 'package:alterr/utils/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:alterr/services/api.dart';
import 'package:image/image.dart' as ManipulateImage;
import 'package:path_provider/path_provider.dart';
import 'package:alterr/utils/s3.dart';
import 'package:alterr/utils/platform_spinner.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  ProfileSettingsScreenState createState() => ProfileSettingsScreenState();
}

class ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final AuthController authController = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isChanged = false;
  String newUsername = '';
  String newBio = '';
  File? image;
  bool loading = false;
  FocusNode usernameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    usernameController.text = authController.user!.username;
    bioController.text = authController.user!.bio!;
    newUsername = authController.user!.username;
    newBio = authController.user!.bio!;

    return Scaffold(
      appBar: CustomAppBar(
              leading: InkWell(
                onTap: () => {loading ? null : navigator?.pop()},
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(loading ? 0.25 : 1.0)),
                ),
              ),
              title: 'Edit Profile',
              action: loading == true
                  ? PlatformSpinner(
                      width: 15,
                      height: 15,
                    )
                  : InkWell(
                      onTap: isChanged == false
                          ? null
                          : () => updateUserProfile(authController),
                      child: Opacity(
                        opacity: isChanged == false ? 0.5 : 1,
                        child: Text(
                          'Save',
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ))
          .build(),
      body: Column(children: [
        const SizedBox(height: 20),

        /* Profile Picture */
        Stack(
          children: [
            Positioned(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(50)),
                child: PlatformSpinner(
                  width: 15,
                  height: 15,
                ),
              ),
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            image != null
                ? Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(50)))
                : authController.profilePicture.value != null &&
                        authController.profilePicture.value != ''
                    ? CachedNetworkImage(
                        imageUrl: authController.profilePicture.value!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        fadeInDuration: Duration(seconds: 0),
                        placeholderFadeInDuration: Duration(seconds: 0),
                        fadeOutDuration: Duration(seconds: 0),
                        placeholder: (context, url) => Container(
                            decoration: BoxDecoration(color: Colors.black12)),
                        height: 100,
                        width: 100,
                        errorWidget: (context, error, _) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(
                                'assets/images/profile-placeholder.png'),
                          );
                        },
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/profile-placeholder.png'),
                      ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => getImage(),
          child: Text(
            'Edit Profile Picture',
            style: TextStyle(
                fontSize: 15.5, color: Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          height: 30,
        ),

        /* Username */
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Username',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    focusNode: usernameFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                    ],
                    readOnly: loading,
                    controller: usernameController,
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
                      newUsername = value.trim().toLowerCase();
                      isChanged = true;
                      setState(() {});
                      usernameController.text = newUsername;
                      usernameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newUsername.length));
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        Divider(
          height: 30,
        ),

        /* Bio */
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Bio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    readOnly: loading,
                    controller: bioController,
                    maxLines: 2,
                    minLines: 1,
                    maxLength: 50,
                    decoration: new InputDecoration(
                      isDense: true,
                      counterText: '',
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
                      newBio = value.trim();
                      isChanged = true;
                      setState(() {});
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        Divider(
          height: 30,
        ),
      ]),
    );
  }

  Future getImage() async {
    PickedFile? pickedFile =
        await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      isChanged = true;
      setState(() {});
    }
  }

  updateUserProfile(authController) async {
    if (newUsername.trim().length == 0) {
      return usernameFocus.requestFocus();
    }

    loading = true;
    setState(() {});

    Map<String, dynamic> data = {};
    data['username'] = newUsername;
    data['bio'] = newBio;

    if (image != null) {
      Directory tempDir = await getTemporaryDirectory();
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String randomString = Helpers.randomString();
      String s3Path = 'profile-images/$randomString-$timestamp';

      String profileTmpPath = '${tempDir.path}/$timestamp-source.jpg';
      ManipulateImage.Image decodedImage =
          ManipulateImage.decodeJpg(image!.readAsBytesSync().toList());

      ManipulateImage.Image profileImage =
          ManipulateImage.copyResize(decodedImage, width: 600);
      File(profileTmpPath).writeAsBytesSync(
          ManipulateImage.encodeJpg(profileImage, quality: 75));

      String filename = '$timestamp-$newUsername.jpg';
      String profilePicturePath = await S3.uploadFile(
        s3Path,
        {'file': File(profileTmpPath), 'filename': filename},
      );
      data['profile_picture'] = profilePicturePath;
    }

    authController.user.value.username = data['username'];
    authController.user.value.bio = data['bio'];
    authController.user.refresh();

    Map<String, dynamic>? response =
        await ApiService().request('auth/update', data, 'PUT', withToken: true);
    if (response != null) {
      authController.user.value.username = response['username'];
      authController.user.value.bio = response['bio'];
      authController.user.value.profilePicture = response['profile_picture'];
      authController.user.refresh();
      authController.profilePicture.value = response['profile_picture'];
      authController.profilePicture.refresh();
      Get.find<ProfileController>(tag: 'profile_${response['id']}')
          .getProfile(response['id']);
      navigator?.pop();
    }
    loading = false;
    setState(() {});
  }
}
