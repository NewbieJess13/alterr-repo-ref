import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/feed.dart';
import 'package:alterr/controllers/notification.dart';
import 'package:alterr/controllers/profile.dart';
import 'package:alterr/controllers/search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:alterr/screens/auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  return Future<void>.value();
}

void main() async {
  CustomImageCache();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HttpOverrides.global =
      new MyHttpOverrides(); // should only run in  test/local
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  if (Platform.isAndroid) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      AuthController authController = Get.find<AuthController>();
      if (authController.user != null) {
        try {
          Get.find<FeedController>().getFeedPosts();
        } catch (e) {}
        try {
          Get.find<SearchController>().getPopularPosts();
        } catch (e) {}
        try {
          Get.find<ConversationsController>().getConversations();
        } catch (e) {}
        try {
          Get.find<ProfileController>(tag: 'profile_${authController.user?.id}')
              .getProfile(authController.user!.id);
        } catch (e) {}
        try {
          Get.find<NotificationController>().refreshNotifications();
        } catch (e) {}
      }
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(27, 150, 250, .1),
      100: Color.fromRGBO(27, 150, 250, .2),
      200: Color.fromRGBO(27, 150, 250, .3),
      300: Color.fromRGBO(27, 150, 250, .4),
      400: Color.fromRGBO(27, 150, 250, .5),
      500: Color.fromRGBO(27, 150, 250, .6),
      600: Color.fromRGBO(27, 150, 250, .7),
      700: Color.fromRGBO(27, 150, 250, .8),
      800: Color.fromRGBO(27, 150, 250, .9),
      900: Color.fromRGBO(27, 150, 250, 1),
    };
    MaterialColor primaryColor = MaterialColor(0xFF1b96fa, color);
    Widget? refreshIndicator;
    if (Platform.isAndroid) {
      refreshIndicator = SizedBox(
        height: 17,
        width: 17,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
        ),
      );
    } else if (Platform.isIOS) {
      refreshIndicator = CupertinoActivityIndicator();
    }
    refreshIndicator =
        Transform.translate(offset: Offset(7, 0), child: refreshIndicator);

    return RefreshConfiguration(
        enableScrollWhenRefreshCompleted: true,
        headerBuilder: () => ClassicHeader(
              refreshingText: '',
              idleText: '',
              releaseText: '',
              completeText: '',
              idleIcon: Transform.translate(
                offset: Offset(7, 0),
                child: Icon(
                  FeatherIcons.arrowDown,
                  color: Colors.black26,
                ),
              ),
              releaseIcon: refreshIndicator,
              refreshingIcon: refreshIndicator,
              completeIcon: refreshIndicator,
              failedIcon: null,
              failedText: '',
            ),
        footerBuilder: () {
          return ClassicFooter(
            idleText: '',
            idleIcon: Transform.translate(
              offset: Offset(7, 0),
              child: Icon(
                FeatherIcons.arrowUp,
                color: Colors.black26,
              ),
            ),
            canLoadingText: 'Load more..',
            canLoadingIcon: null,
            loadingText: '',
            loadingIcon: refreshIndicator,
            noMoreIcon: null,
            noDataText: '',
            failedIcon: null,
            failedText: '',
          );
        },
        child: GetMaterialApp(
          enableLog: false,
          title: 'Alterr',
          initialRoute: '/auth',
          getPages: [
            GetPage(name: '/auth', page: () => AuthScreen()),
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColorBrightness: Brightness.light,
              fontFamily: 'Helvetica Neue',
              splashColor: Colors.transparent,
              //highlightColor: Colors.transparent,
              primaryTextTheme: TextTheme(
                  headline6: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w700)),
              scaffoldBackgroundColor: Colors.white,
              primarySwatch: primaryColor,
              dialogTheme:
                  DialogTheme(backgroundColor: const Color(0xFFF3F8FE)),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: AppBarTheme(
                  elevation: 0,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  iconTheme: IconThemeData(
                    color: Colors.black87,
                    size: 20,
                  ))),
        ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    imageCache.maximumSizeBytes = 1024 * 1024 * 200; // 200 MB
    return imageCache;
  }
}
