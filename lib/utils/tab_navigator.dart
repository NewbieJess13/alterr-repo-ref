import 'package:alterr/screens/conversations.dart';
import 'package:alterr/screens/feed.dart';
import 'package:alterr/screens/profile.dart';
import 'package:alterr/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alterr/controllers/auth.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? tabItem;

  TabNavigator({Key? key, this.navigatorKey, this.tabItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    switch (tabItem) {
      case 'Feed':
        child = FeedScreen();
        break;
      case 'Search':
        child = SearchScreen();
        break;
      case 'Conversations':
        child = ConversationsScreen();
        break;
      case 'Profile':
        child = ProfileScreen(user: Get.find<AuthController>().user!);
        break;
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
