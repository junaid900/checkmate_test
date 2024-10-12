import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/helpers/session_helper.dart';
import 'package:checkmate/providers/main/app_setting_provider.dart';
import 'package:checkmate/providers/post/create_post_provider.dart';
import 'package:checkmate/ui/main/components/jdrawer_header.dart';
import 'package:checkmate/ui/main/components/jdrawer_item.dart';
import 'package:checkmate/ui/notification/notification_screen.dart';
import 'package:checkmate/ui/storytelling/story_screen.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../constraints/helpers/helper.dart';
import '../../constraints/jcolor.dart';
import '../../providers/user/profile_provider.dart';
import '../../services/notifications_service.dart';
import '../chat/conversation/conversation_screen.dart';
import '../common/touchable_opacity.dart';
import '../home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double iconSize = 27;
  int currentTab = 0;
  GlobalKey? currentKey;
  double? currentPosition;
  int previousTab = 0;
  bool isNotiLoading = false;
  List tabs = [
    {
      "icon": "assets/icons/home.png",
      "index": 0,
      "type": "icon",
      "key": GlobalKey(),
      "onTap": () {},
      "widget": HomeScreen(),
    },
    {
      "icon": "assets/icons/chat_bubble.png",
      "index": 1,
      "type": "icon",
      "key": GlobalKey(),
      "onTap": () {},
      "widget": ConversationScreen(),
    },
    {
      "icon": "assets/icons/chat_bubble.png",
      "index": 2,
      "type": "fab",
      "onTap": () {},
      "widget": Container(),
    },
    {
      "icon": "assets/icons/story_video.png",
      "index": 3,
      "type": "icon",
      "key": GlobalKey(),
      "onTap": () {},
      "widget": StoryScreen(),
    },
    {
      "icon": "assets/icons/notification.png",
      "index": 4,
      "type": "icon",
      "key": GlobalKey(),
      "onTap": () {},
      "widget": NotificationScreen(
        onBackPressed: () => {},
      ),
    },
  ];
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Timer? timer;
  final notificationCount = ValueNotifier(0);

  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  getPageData() async {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      getNotificationCount();
    });
    // Juga...r
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      onChangeTab(tabs[0]);
    });
  }

  getNotificationCount() async {
    if(isNotiLoading){
      return;
    }
    isNotiLoading = true;
    var value = await JApiService().getRequest(JApi.NOTIFICATION_COUNT);
    isNotiLoading = false;
    if (value != null) {
      if (value["count"] != null) {
        notificationCount.value = value["count"];
        // setState(() {});
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initNotifications();
      getPageData();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        // DeviceOrientation.landscapeRight,
        // DeviceOrientation.landscapeLeft
      ]);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  initNotifications() {
    _firebaseMessaging.requestPermission();
    getToken();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  getToken() async {
    _firebaseMessaging.getToken().then((value) async {
      print("=====>TOKEN<=====");
      if (!mounted) {
        return;
      }
      print(value);
      var profileProvider = context.read<ProfileProvider>();
      if (value!.isNotEmpty) {
        profileProvider.updateProfile({
          "fcm_token": value,
          "id": profileProvider.profile.id!,
        }, showToast: false);
      }
    });
  }

  convertMessage(RemoteMessage message) {
    // message["data"] = message;
    try {
      var notification = {
        "title": message.data['aps']['title'],
        "body": message.data['aps']['body'],
        "data": message.data,
      };

      return notification;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showFlutterNotification(RemoteMessage fcmMessage) {
    debugPrint("show flutter notification");
    try {
      var notification = fcmMessage.notification;
      var msg;
      debugPrint("======+>Before Converted message");
      debugPrint(msg.toString());
      // if (Platform.isIOS) {
      //
      //   // msg = convertMessage(fcmMessage);
      // } else {
      msg = {
        "title": notification?.title, //msg['notification']['title'],
        "body": notification?.body, //msg['notification']['body'],
        "data": "",
      };
      // }
      debugPrint("======+>Converted message");
      debugPrint(msg.toString());
      NotificationService().showFloatingNotification(
          Random().nextInt(10000), msg['title'], msg['body'], 01);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  onChangeTab(e) {
    tabs[4]["widget"] = NotificationScreen(onBackPressed: () {
      onChangeTab(tabs[previousTab]);
    });
    setState(() {
      previousTab = currentTab;
      currentTab = e["index"];
      currentKey = e["key"];
      RenderBox box =
          currentKey!.currentContext!.findRenderObject() as RenderBox;
      Offset position =
          box.localToGlobal(Offset.zero); //this is global position
      double x = position.dx;
      double width = currentKey!.currentContext!.size!.width;
      if (getWidth(context) < 600)
        currentPosition = x + (width * .30);
      else
        currentPosition = x + (width * .40);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingProvider>(
        builder: (key, appSettingProvider, child) {
      return Scaffold(
          key: appSettingProvider.scaffoldKey,
          body: tabs[currentTab]["widget"],
          drawerScrimColor: Colors.grey.shade900.withOpacity(.8),
          drawer: Container(
            margin: EdgeInsets.only(left: 14, top: 20),
            height: getHeight(context) * .91,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Drawer(
                // shape: ,
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      flex: 9,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            JDrawerHeader(onCloseHandle: () {
                              appSettingProvider.toggleDrawer();
                            }),
                            SizedBox(
                              height: 20,
                            ),
                            JDrawerItem(
                              title: "Home",
                              icon: "assets/icons/drawer_home.png",
                              onTap: () {
                                onChangeTab(tabs[0]);
                                appSettingProvider.toggleDrawer();
                              },
                              isSelected: currentTab == 0,
                            ),
                            JDrawerItem(
                              title: "Profile",
                              icon: "assets/icons/profile.png",
                              onTap: () {
                                Navigator.pushNamed(
                                    context, JRoutes.viewProfileScreen);
                                appSettingProvider.toggleDrawer();
                              },
                            ),
                            JDrawerItem(
                              title: "Saved Reviews",
                              icon: "assets/icons/saved_reviews.png",
                              onTap: () {
                                Navigator.pushNamed(
                                    context, JRoutes.savedReviews);
                                appSettingProvider.toggleDrawer();
                              },
                            ),
                            JDrawerItem(
                              title: "Go Live",
                              icon: "assets/icons/live_stream.png",
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(JRoutes.createLiveStreamScreen);
                                appSettingProvider.toggleDrawer();
                              },
                            ),
                            JDrawerItem(
                              title: "Saved Stories",
                              icon: "assets/icons/saved_stories.png",
                              onTap: () {
                                Navigator.pushNamed(
                                    context, JRoutes.savedStoryScreen);
                                appSettingProvider.toggleDrawer();
                              },
                            ),
                            JDrawerItem(
                              title: "Settings",
                              icon: "assets/icons/setting.png",
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(JRoutes.setting);
                                appSettingProvider.toggleDrawer();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          JDrawerItem(
                            title: "Logout",
                            icon: "assets/icons/exit.png",
                            onTap: () async {
                              // onChangeTab(tabs[0]);
                              await logout();
                              Navigator.pushReplacementNamed(
                                  context, JRoutes.welcomeAuth);
                            },
                            // isSelected: currentTab == 0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<CreatePostProvider>(
                builder: (key, provider, child) {
                  var count = provider.fileList
                      .where((element) => element.isUploading)
                      .length;
                  if (count < 1) {
                    return SizedBox();
                  }
                  return Column(
                    children: [
                      Text("Uploading Files ${count}"),
                      LinearProgressIndicator()
                    ],
                  );
                },
              ),
              Container(
                height: Platform.isIOS ? 90 : 80,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Stack(
                  children: [
                    Container(
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          ...tabs
                              .map(
                                (e) => e["type"] != "fab"
                                    ? Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            Builder(builder: (context) {
                                              if (currentTab == e["index"])
                                                return Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: JColor.accentColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                );
                                              else
                                                return Container(
                                                  width: 10,
                                                  height: 10,
                                                );
                                            }),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Container(
                                              child: TouchableOpacity(
                                                onTap: () {
                                                  onChangeTab(e);
                                                },
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.asset(
                                                      "${e["icon"]}",
                                                      key: e["key"],
                                                      color: currentTab ==
                                                              e["index"]
                                                          ? JColor
                                                              .blackTextColor
                                                          : JColor
                                                              .greyTextColor,
                                                      width: iconSize,
                                                      height: e["index"] == 3 ||
                                                              e["index"] == 0
                                                          ? iconSize + 2
                                                          : iconSize,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                    if (e["index"] == 4)
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              notificationCount,
                                                          builder: (context,
                                                              int count,
                                                              widget) {
                                                            return count < 1
                                                                ? SizedBox()
                                                                : Container(
                                                                    width: 8,
                                                                    height: 8,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                  );
                                                          }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Expanded(
                                        flex: 3,
                                        child: FloatingActionButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, JRoutes.createPost);
                                          },
                                          shape: CircleBorder(),
                                          elevation: 0,
                                          child: Icon(
                                            Icons.add,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                    // if (currentPosition != null && currentKey != null)
                    //   AnimatedPositioned(
                    //       top: 0,
                    //       left: currentPosition!,
                    //       child: Container(
                    //         width: 10,
                    //         height: 10,
                    //         decoration: BoxDecoration(
                    //             color: JColor.accentColor,
                    //             borderRadius: BorderRadius.circular(20)),
                    //       ),
                    //       duration: Duration(milliseconds: 200)),

                    // SizedBox(height: 20,),
                  ],
                ),
              ),
            ],
          ));
    });
  }
}
