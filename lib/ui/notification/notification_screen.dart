import 'dart:convert';

import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/cmpost.dart';
import 'package:checkmate/providers/main/app_setting_provider.dart';
import 'package:checkmate/providers/notification/notification_provider.dart';
import 'package:checkmate/providers/post/post_provider.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/notification/components/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../modals/story.dart';
import '../../utils/route/route_names.dart';
import '../common/jempty_layout.dart';

class NotificationScreen extends StatefulWidget {
  Function onBackPressed;

  NotificationScreen({super.key, required this.onBackPressed});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  getPageData() async {
    var notificationProvider = context.read<NotificationProvider>();
    // if (notificationProvider.list.length < 1) {
    notificationProvider.load();
    readNotifications();
    // }
  }
  readNotifications(){
    JApiService().getRequest(JApi.READ_NOTIFICATION).then((value) {
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/circle_border_back.png",
              width: 66,
            ),
            onPressed: () {
              widget.onBackPressed();
              // context.read<AppSettingProvider>().toggleDrawer();
            },
          ),
          title: Text(
            "Notifications",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // IconButton(
            //   icon: Image.asset(
            //     "assets/icons/circle_dots.png",
            //     height: getHeight(context),
            //   ),
            //   onPressed: () {},
            // ),
          ],
        ),
        body: Consumer<NotificationProvider>(builder: (key, provider, child) {
          return !provider.isLoading && provider.list.isEmpty
              ? JEmptyLayout(
                  text: "No Notifications",
                  width: 120,
                  height: 120,
                )
              : Container(
                  height: getHeight(context),
                  width: getWidth(context),
                  child: provider.isLoading && provider.list.length < 1
                      ? Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()),
                        )
                      : SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          controller: provider.refreshController,
                          onLoading: () async {
                            bool res = await provider.loadMoreData();
                          },
                          onRefresh: () async {
                            bool res = await provider.reset();
                            provider.refreshController.refreshCompleted();
                            provider.refreshController =
                                provider.refreshController;
                          },
                          footer: ClassicFooter(),
                          child: ListView(
                            children: [
                              ...provider.list.map(
                                (e) {
                                  return TouchableOpacity(
                                    onTap: () async {
                                      print("here ${e.click}");
                                      var postProvider =
                                          context.read<PostProvider>();
                                      try {
                                        if (e.click == 'Post') {
                                          if (e.data != null) {
                                            var data = jsonDecode(e.data!);
                                            data = jsonDecode(data);
                                            if (data != null &&
                                                data["id"] != null) {
                                              showProgressDialog(
                                                  context, "Please wait...",
                                                  isDismissable: false);
                                              List<CMPost>? list =
                                                  await postProvider
                                                      .getPostById(data["id"]
                                                          .toString());
                                              hideProgressDialog(context);
                                              if (list != null) {
                                                if (list.length > 0) {
                                                  CMPost post = list.first;
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          JRoutes.postDetail,
                                                          arguments: post);
                                                  return;
                                                }
                                              }
                                            }
                                            showAlertDialog(context, "Info!",
                                                "Cannot find post in live posts.");
                                          }
                                        }else if (e.click == 'Story') {
                                          var storyProvider = context.read<StoryProvider>();

                                          if (e.data != null) {
                                            var data = jsonDecode(e.data!);
                                            data = jsonDecode(data);
                                            if (data != null &&
                                                data["id"] != null) {
                                              showProgressDialog(
                                                  context, "Please wait...",
                                                  isDismissable: false);
                                              List<Story>? list =
                                              await storyProvider
                                                  .getStoryById(data["id"]
                                                  .toString());
                                              hideProgressDialog(context);
                                              if (list != null) {
                                                if (list.length > 0) {
                                                  // Story post = list.first;
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                      JRoutes.todayStoriesScreen,
                                                      arguments: {
                                                        "type": "story_detail",
                                                        "stories": list
                                                      } as Map);
                                                  return;
                                                }
                                              }
                                            }
                                          }
                                          showAlertDialog(context, "Info!",
                                              "Cannot find story in live stories.");
                                        }
                                      } catch (e) {
                                        print(e);
                                        showAlertDialog(context, "Error!",
                                            "Operation failed action doesn't exist.");
                                      }
                                      // if(postProvider)
                                    },
                                    child: NotificationItem(notification: e),
                                  );
                                },
                              ).toList(),
                            ],
                          ),
                        ),
                );
        })
        // SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       SizedBox(height: 10,),
        //
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //       SizedBox(height: 10,),
        //       NotificationItem(),
        //
        //     ],
        //   ),
        // ),
        );
  }
}
