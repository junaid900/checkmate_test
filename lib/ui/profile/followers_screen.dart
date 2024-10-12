import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/functional_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../constraints/enum_values.dart';
import '../../constraints/j_var.dart';
import '../../constraints/jcolor.dart';
import '../../modals/User.dart';
import '../../modals/conversation.dart';
import '../../providers/chat/conversation_provider.dart';
import '../../providers/main/app_setting_provider.dart';
import '../../utils/route/route_names.dart';
import '../common/placeholder_image.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with TickerProviderStateMixin {
  TabController? tabController;
  int selectedTab = 0;
  bool isLoading = false;
  var userId;
  List<User> followers = [];
  List<User> following = [];
  User? profile;
  String screen = "profile";

  getPageData() async {
    setState(() {});
    try {
      var data = ModalRoute.of(context)!.settings.arguments;
      Map pageData = data as Map;
      if (pageData["type"] != "followers") {
        selectedTab = 1;
      }
      if (pageData["user_id"] != null) {
        userId = pageData["user_id"];
      }
      if (pageData["screen"] != null) {
        screen = pageData["screen"];
      }
      if (pageData["user"] != null) {
        var user = pageData["user"] as User;
        setState(() {
          profile = user;
        });
      }
    } catch (e) {
      print(e);
    }
    tabController =
        TabController(length: 2, vsync: this, initialIndex: selectedTab);
    tabController!.addListener(() {
      if (tabController!.indexIsChanging) {
        print("tab chanaged");
        if (selectedTab != tabController!.index) {
          selectedTab = tabController!.index;
          loadFollowers();
        } else {
          if (!isLoading) {
            loadFollowers();
          }
        }
      }
    });
    loadFollowers();
  }

  loadFollowers() async {
    if (profile == null) {
      return;
    }
    var profileProvider = context.read<ProfileProvider>();
    var type = selectedTab == 0 ? "followers" : "following";
    setState(() {
      isLoading = true;
    });
    List<User>? data =
        await profileProvider.loadFollowers("$type", profile!.id.toString());
    setState(() {
      isLoading = false;
    });
    print(data);
    if (data != null) {
      print(type);
      if (type == "followers") {
        followers.clear();
        followers.addAll(data);
      } else if (type == "following") {
        following.clear();
        following.addAll(data);
      }
      setState(() {});
    }
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
        leading: BackButton(),
        title: screen == "conversation"?Text(
           "Start Conversation",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)) : Text(
          profile != null ? "${profile!.fname}" : "Followers",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        bottom: tabController == null || profile == null
            ? null
            : TabBar(
                controller: tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.only(top: 18),
                labelPadding: EdgeInsets.only(left: 0, right: 20),
                tabAlignment: TabAlignment.center,
                tabs: [
                    Tab(
                      text: "${profile!.followersCount} Followers",
                    ),
                    Tab(
                      text: "${profile!.followingCount} Following",
                    )
                  ]),
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
      body: tabController == null
          ? SizedBox()
          : TabBarView(controller: tabController, children: [
              Container(
                width: getWidth(context),
                height: getHeight(context),
                child: SingleChildScrollView(
                  child: Column(
                    children: isLoading && followers.length < 1
                        ? List.generate(10, (index) => followerItemShimmer())
                        : followers
                            .map((e) => FollowerItemWidget(
                                  userData: e,
                                  personProfile: profile!,
                                  shouldPop: screen == "conversation",
                                ))
                            .toList(),
                  ),
                ),
              ),
              Container(
                width: getWidth(context),
                height: getHeight(context),
                child: SingleChildScrollView(
                  child: Column(
                    children: isLoading && following.length < 1
                        ? List.generate(10, (index) => followerItemShimmer())
                        : following
                            .map((e) => FollowerItemWidget(
                                  userData: e,
                                  personProfile: profile!,
                                  shouldPop: screen == "conversation",
                                ))
                            .toList(),
                  ),
                ),
              ),
            ]),
    );
  }
}

class FollowerItemWidget extends StatefulWidget {
  User userData;
  User personProfile;
  bool shouldPop = false;

  FollowerItemWidget(
      {super.key,
      required this.userData,
      required this.personProfile,
      this.shouldPop = false});

  @override
  State<FollowerItemWidget> createState() => _FollowerItemWidgetState();
}

class _FollowerItemWidgetState extends State<FollowerItemWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(widget.userData.id);
        Navigator.of(context).pushNamed(JRoutes.viewProfileScreen,
            arguments: convertNumber(widget.userData.id));
      },
      child: AnimatedContainer(
        duration: Duration(seconds: 5),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: JColor.primaryColor),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: ImageWithPlaceholder(
                        image: '${widget.userData.profileImage}',
                        prefix:
                            "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/",
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      )),
                )),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      "${widget.userData.fname}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  SizedBox(
                    width: 240,
                    child: Text(
                      "@${widget.userData.username}",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<ProfileProvider>(builder: (key, provider, child) {
              if (provider.profile.id == widget.userData.id) return SizedBox();
              // if ((provider.profile.id != widget.personProfile.id) && !widget.userData.isFollowing)

              return SizedBox(
                width: 90,
                child: AppColorButton(
                  elevation: 0,
                  fontSize: 12,
                  name: "Message",
                  onPressed: () async {
                    var currentUser = provider.profile;
                    if (currentUser.id == widget.userData.id) {
                      showAlertDialog(context, "Warning!",
                          "Cannot start chat with your self.",
                          okButtonText: 'Ok', onPress: () {
                        Navigator.of(context).pop();
                      }, type: AlertType.WARNING);
                      return;
                    }
                    Conversation? conversation = await context
                        .read<ConversationProvider>()
                        .checkChat(
                            context: context,
                            userId: currentUser.id,
                            otherUserId: widget.userData.id,
                            selfId: currentUser.id);
                    // if(conversation == null)

                    if (conversation == null) {
                      showAlertDialog(context, "Warning!",
                          "Cannot start chat right now please try again later",
                          okButtonText: 'Ok', onPress: () {
                        Navigator.of(context).pop();
                      }, type: AlertType.WARNING);
                      return;
                    }
                    bool isExist = true;
                    if (conversation.id == null) {
                      isExist = false;
                    }
                    print("isExist");
                    // print(isExist);

                    await Navigator.pushNamed(context, JRoutes.conversationDetail,
                        arguments: {
                          "user": widget.userData,
                          "conversation": conversation,
                          "type": "profile",
                          "isExist": isExist
                        });
                    if (widget.shouldPop) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              );

              return SizedBox(
                width: 90,
                child: AppColorButton(
                  elevation: 0,
                  fontSize: 12,
                  name: "Message",
                  onPressed: () async {
                    var currentUser = provider.profile;
                    if (currentUser.id == widget.userData.id) {
                      showAlertDialog(context, "Warning!",
                          "Cannot start chat with your self.",
                          okButtonText: 'Ok', onPress: () {
                        Navigator.of(context).pop();
                      }, type: AlertType.WARNING);
                      return;
                    }
                    Conversation? conversation = await context
                        .read<ConversationProvider>()
                        .checkChat(
                            context: context,
                            userId: currentUser.id,
                            otherUserId: widget.userData.id,
                            selfId: currentUser.id);
                    // if(conversation == null)

                    if (conversation == null) {
                      showAlertDialog(context, "Warning!",
                          "Cannot start chat right now please try again later",
                          okButtonText: 'Ok', onPress: () {
                        Navigator.of(context).pop();
                      }, type: AlertType.WARNING);
                      return;
                    }
                    bool isExist = true;
                    if (conversation.id == null) {
                      isExist = false;
                    }
                    print("isExist");
                    print(isExist);
                    Navigator.pushNamed(context, JRoutes.conversationDetail,
                        arguments: {
                          "user": widget.userData,
                          "conversation": conversation,
                          "type": "profile",
                          "isExist": isExist
                        });
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
