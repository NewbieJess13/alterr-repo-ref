import 'package:alterr/controllers/auth.dart';
import 'package:alterr/controllers/conversations.dart';
import 'package:alterr/controllers/nav.dart';
import 'package:alterr/utils/profile_picture.dart';
import 'package:alterr/utils/tab_navigator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:alterr/utils/create_post.dart';

class MainScreen extends StatelessWidget {
  final controller = Get.put(NavController());
  final ConversationsController conversationsController =
      Get.find<ConversationsController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => WillPopScope(
        child: Scaffold(
          body: Stack(
            children: [
              _buildOffstageNavigator(
                'Feed',
              ),
              _buildOffstageNavigator(
                'Search',
              ),
              _buildOffstageNavigator(
                'Empty',
              ),
              _buildOffstageNavigator(
                'Conversations',
              ),
              _buildOffstageNavigator(
                'Profile',
              ),
            ],
          ),
          bottomNavigationBar: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              unselectedIconTheme: IconThemeData(color: Colors.black),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    FeatherIcons.home,
                    size: 26,
                  ),
                  tooltip: 'Home',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FeatherIcons.search,
                    size: 26,
                  ),
                  tooltip: 'Search',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Transform.scale(
                    scale: 1.8,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Icon(
                        FeatherIcons.plus,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  tooltip: 'Create Post',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        FeatherIcons.messageSquare,
                        size: 26,
                      ),
                      Obx(() => conversationsController.newMessage > 0
                          ? Positioned(
                              top: -5,
                              right: -5,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  conversationsController.newMessage.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink())
                    ],
                  ),
                  tooltip: 'Messages',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: controller.currentPage.value == 'Profile'
                                ? Theme.of(context).primaryColor
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: Obx(() => ProfilePicture(
                            source: authController.profilePicture.value,
                            radius: 16,
                          )),
                    ),
                  ),
                  tooltip: 'Profile',
                  label: '',
                ),
              ],
              currentIndex: controller.screenIndex.value,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.black54,
              onTap: (index) {
                if (index == 2) {
                  return CreatePost().open();
                }
                controller.selectTab(controller.pageKeys[index], index);
              },
            ),
          ),
        ),
        onWillPop: () async {
          final isFirstRouteInCurrentTab = await controller
                  .navigatorKeys[controller.currentPage.value]?.currentState
                  ?.maybePop() ==
              false;
          if (isFirstRouteInCurrentTab &&
              controller.currentPage.value != 'Feed') {
            controller.selectTab('Feed', 0);
            return false;
          }
          return isFirstRouteInCurrentTab;
        }));
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: controller.currentPage.value != tabItem,
      child: TabNavigator(
        navigatorKey: controller.navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
