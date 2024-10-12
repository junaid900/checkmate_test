import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/jproviders.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/functional_widgets.dart';
import 'package:checkmate/ui/common/jempty_layout.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/home/components/post_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/enum_values.dart';
import '../../constraints/helpers/app_methods.dart';
import '../../modals/User.dart';
import '../../modals/cmpost.dart';
import '../../modals/common/jfile.dart';
import '../../modals/conversation.dart';
import '../../providers/chat/conversation_provider.dart';
import '../../providers/post/create_post_provider.dart';
import '../../utils/route/route_names.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool isMyProfile = false;
  User? profile;
  JFile selectedProfileImage = JFile(uid: "selected_profile");
  JFile selectedCoverImage = JFile(uid: "selected_cover");
  RefreshController refreshController = RefreshController();
  List<CMPost> list = [];
  int maxPages = 0;
  int currentPage = 0;
  bool isLoading = false;

  loadImage(XFile? file, {type = 'profile'}) async {
    if (file != null) {
      print("uploading");
      var urlResponse = '';
      var profileProvider = context.read<ProfileProvider>();

      if (type == "profile") {
        selectedProfileImage.isUploading = true;
        selectedProfileImage.file = File(file.path);
        setState(() {
          selectedProfileImage = selectedProfileImage;
        });
        urlResponse = await CreatePostProvider().uploadFiles(
            "${JVar.imagePaths.userProfileImage}", File(file.path));
        print(urlResponse);
        if (urlResponse.isNotEmpty) {
          selectedProfileImage.isUploading = false;
          selectedProfileImage.fileUrl = urlResponse;
          setState(() {
            this.profile!.profileImage = urlResponse;
            selectedProfileImage = selectedProfileImage;
          });
          profileProvider.updateProfile(
              {"id": profileProvider.profile.id, "profile_image": urlResponse});
        }
      } else if (type == "cover") {
        selectedCoverImage.isUploading = true;
        selectedCoverImage.file = File(file.path);
        setState(() {
          selectedCoverImage = selectedCoverImage;
        });
        urlResponse = await CreatePostProvider().uploadFiles(
            "${JVar.imagePaths.userProfileCover}", File(file.path));
        if (urlResponse.isNotEmpty) {
          selectedCoverImage.isUploading = false;
          selectedCoverImage.fileUrl = urlResponse;
          setState(() {
            this.profile!.coverImage = urlResponse;
            selectedCoverImage = selectedCoverImage;
          });
          profileProvider.updateProfile(
              {"id": profileProvider.profile.id, "cover_image": urlResponse});
        }
      }

      return;
    }
    showToast("cannot pick file");
  }

  getUserData(userId, {loadPosts = true}) async {
    var profileProvider = context.read<ProfileProvider>();
    profile = await profileProvider.getProfileData(userId);
    if (profile != null) {
      setState(() {
        profile = profile;
        if (profile!.id != null) {
          if (profile!.id == profileProvider.profile.id &&
              profile!.id!.isNotEmpty) {
            isMyProfile = true;
          }
        }
      });
      if(loadPosts)
      reset(profile!.id!);
    }
  }

  getPageData() async {
    try {
      var data = ModalRoute.of(context)!.settings.arguments;
      if (data != null) {
        var user_id = data as int?;
        if (user_id != null) {
          if (user_id > 0) {
            getUserData(user_id);
            return;
          }
        }
      }
    } catch (e) {}
    var profileProvider = context.read<ProfileProvider>();
    var _profile = profileProvider.profile;
    getUserData(_profile.id);
    setState(() {
      isMyProfile = true;
    });
    // if(profile != null){
    // profileProvider.reset(_profile.id!);
    // }
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
        body: profile == null
            ? Consumer<ProfileProvider>(builder: (key, provider, child) {
                return Center(
                  child: provider.isLoading
                      ? SizedBox(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            JEmptyLayout(
                              width: 80,
                              height: 80,
                              text: "Cannot get user profile.",
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: getWidth(context) * .4,
                              child: AppColorButton(
                                elevation: 0,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                name: "Back",
                              ),
                            )
                          ],
                        ),
                );
              })
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverList(
                        delegate: SliverChildListDelegate([
                      Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: 250,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isMyProfile) {
                                        pickFileSheet(type: "cover");
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: selectedCoverImage.isUploading
                                          ? Center(
                                              child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator()),
                                            )
                                          : ImageWithPlaceholder(
                                              image: '${profile!.coverImage}',
                                              prefix:
                                                  "${JVar.FILE_URL}${JVar.imagePaths.userProfileCover}/",
                                              width: getWidth(context),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 60,
                                child: Container(
                                    width: 36,
                                    height: 36,
                                    margin: EdgeInsets.only(left: 10),
                                    child: TouchableOpacity(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Image.asset(
                                        "assets/icons/circle_blur_white.png",
                                        color: Colors.white,
                                        width: 42,
                                      ),
                                    )),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  // margin: EdgeInsets.only(bottom: 10),
                                  margin: EdgeInsets.only(left: 13),
                                  height: 80,
                                  width: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isMyProfile) {
                                        pickFileSheet(type: "profile");
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: selectedProfileImage.isUploading
                                          ? Center(
                                              child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator()),
                                            )
                                          : ImageWithPlaceholder(
                                              image: '${profile!.profileImage}',
                                              prefix:
                                                  '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            transform: Matrix4.translationValues(0, -20, 0),
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: getWidth(context) * .6,
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    JRoutes.followersScreen,
                                                    arguments: {
                                                      "type": "followers",
                                                      "user_id": profile!.id,
                                                      "user": profile,
                                                    });
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${profile!.followersCount}",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    "Followers",
                                                    style: TextStyle(
                                                        color: JColor
                                                            .greyTextColor,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: (){
                                                Navigator.pushNamed(context,
                                                    JRoutes.followersScreen,
                                                    arguments: {
                                                      "type": "following",
                                                      "user_id": profile!.id,
                                                      "user": profile,
                                                    });
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${profile!.followingCount}",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    "Following",
                                                    style: TextStyle(
                                                        color:
                                                            JColor.greyTextColor,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${profile!.postsCount}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  "Posts",
                                                  style: TextStyle(
                                                      color:
                                                          JColor.greyTextColor,
                                                      fontSize: 10),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  transform:
                                      Matrix4.translationValues(0, -14, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${profile!.fname}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "@${profile!.username}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: JColor.lighterGrey,
                                        ),
                                      ),
                                      Text("${profile!.about}.")
                                    ],
                                  ),
                                ),
                                if (isMyProfile)
                                  SizedBox(
                                    height: 50,
                                    width: getWidth(context),
                                    child: TouchableOpacity(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, JRoutes.editProfileScreen);
                                      },
                                      child: AppColorButton(
                                        elevation: 0,
                                        name: "Edit Profile",
                                        color: JColor.black,
                                      ),
                                    ),
                                  ),
                                if (!isMyProfile)
                                  Consumer<ProfileProvider>(
                                      builder: (key, profileProvider, child) {
                                    return SizedBox(
                                      height: 50,
                                      width: getWidth(context),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: TouchableOpacity(
                                                onTap: () async {
                                                  if (profileProvider
                                                      .isFollowLoading) {
                                                    return;
                                                  }
                                                  bool result = false;
                                                  if (profile!.isFollowing) {
                                                    result =
                                                        await profileProvider
                                                            .follow("unfollow",
                                                                profile!.id);
                                                  } else {
                                                    result =
                                                        await profileProvider
                                                            .follow("follow",
                                                                profile!.id);
                                                  }
                                                  if (result) {
                                                    setState(() {
                                                      if (profile!
                                                          .isFollowing) {
                                                        profile!.isFollowing =
                                                            false;
                                                      } else {
                                                        profile!.isFollowing =
                                                            true;
                                                      }
                                                      getUserData(profile!.id, loadPosts: false);
                                                    });
                                                  }
                                                },
                                                child: AppColorButton(
                                                  elevation: 0,
                                                  name: profile!.isFollowing
                                                      ? "Unfollow"
                                                      : "Follow",
                                                  color: JColor.black,
                                                  isLoading: profileProvider
                                                      .isFollowLoading,
                                                  // isLoading: provi,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: TouchableOpacity(
                                                onTap: () async {
                                                  var currentUser = context
                                                      .read<ProfileProvider>()
                                                      .profile;
                                                  Conversation? conversation =
                                                      await context
                                                          .read<
                                                              ConversationProvider>()
                                                          .checkChat(
                                                              context: context,
                                                              userId:
                                                                  currentUser
                                                                      .id,
                                                              otherUserId:
                                                                  profile!.id,
                                                              selfId:
                                                                  currentUser
                                                                      .id);
                                                  // if(conversation == null)

                                                  if (conversation == null) {
                                                    showAlertDialog(
                                                        context,
                                                        "Warning!",
                                                        "Cannot start chat right now please try again later",
                                                        okButtonText: 'Ok',
                                                        onPress: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }, type: AlertType.WARNING);
                                                    return;
                                                  }
                                                  bool isExist = true;
                                                  if (conversation.id == null) {
                                                    isExist = false;
                                                  }
                                                  print("isExist");
                                                  print(isExist);
                                                  Navigator.pushNamed(
                                                      context,
                                                      JRoutes
                                                          .conversationDetail,
                                                      arguments: {
                                                        "user": profile,
                                                        "conversation":
                                                            conversation,
                                                        "type": "profile",
                                                        "isExist": isExist
                                                      });
                                                },
                                                child: AppColorButton(
                                                  elevation: 0,
                                                  name: "Chat",
                                                  color: JColor.black,
                                                  // isLoading: provi,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Timeline",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ]))
                  ];
                },
                body:
                    Consumer<ProfileProvider>(builder: (key, provider, child) {
                  return SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: refreshController,
                    onLoading: () async {
                      bool res = await loadMoreData(profile!.id!);
                    },
                    onRefresh: () async {
                      bool res = await reset(profile!.id!);
                      refreshController.refreshCompleted();
                      refreshController = refreshController;
                    },
                    footer: ClassicFooter(),
                    child: ListView(
                        children: isLoading
                            ? List.generate(
                                10, (index) => postItemShimmer(context))
                            : list
                                .map(
                                  (e) => PostItem(
                                    post: e,
                                    profileImage:
                                        "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/${e.user!.profileImage}",
                                    profileUserName: "${e.user!.fname}",
                                    date: postFormatDateString(e.createdAt),
                                    postImage:
                                        "${JVar.FILE_URL}${JVar.imagePaths.postProfileImage}/${e.profileImage}",
                                    desc: "${e.description}",
                                    rating: calculateAvgRating(
                                            communicationRating: convertDouble(
                                                e.ratingCommunication),
                                            behaviourRating: convertDouble(
                                                e.ratingBehaviour),
                                            timeRating:
                                                convertDouble(e.ratingTime),
                                            loyaltyRating:
                                                convertDouble(e.ratingLoyalty))
                                        .toString(),
                                    onProfileTap: () {
                                      // Navigator.of(context)
                                      //     .pushNamed(JRoutes.viewProfileScreen);
                                    },
                                    onPostTap: () {
                                      Navigator.of(context).pushNamed(
                                          JRoutes.postDetail,
                                          arguments: e);
                                    },
                                    postTitle: '${e.name}',
                                    userId: '${e.userId}',
                                  ),
                                )
                                .toList()),
                  );
                }),
              ));
  }

  pickFileSheet({type = "profile"}) async {
    showModalBottomSheet(
        context: context,
        builder: (__) {
          return Container(
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    "Choose File",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.camera);
                    file = await cropImage(file,type);
                    if(file != null){
                      loadImage(file, type: type);
                    }
                  },
                  title: Text("Camera"),
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.gallery);
                    file = await cropImage(file,type);
                    if(file != null){
                      loadImage(file, type: type);
                    }
                    // loadImage(file, type: type);
                  },
                  title: Text("Gallery"),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }

  Future<bool> load(userId) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response =
        await apiService.getRequest(JApi.GET_POSTS + "?user_id=${userId}");
    isLoading = false;
    list = [];
    setState(() {});
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response['data'].length; i++) {
          list.add(CMPost.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        setState(() {});
      }
    } else {
      // showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadMoreData(userId) async {
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService()
        .getRequest(JApi.GET_POSTS + "?page=${page}&user_id=${userId}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<CMPost> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(CMPost.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
      setState(() {});
    }
    return true;
  }

  addMore(List<CMPost> moreList) {
    list.addAll(moreList);
    setState(() {});
  }

  reset(userId) async {
    currentPage = 0;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load(userId);
    return res;
  }


}
cropImage(imageFile,type) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper Checkmate',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          type == "profile"?
          CropAspectRatioPresetCustom():CropAspectRatioPresetCover()
        ],
      ),
      IOSUiSettings(
        title: 'Cropper Checkmate',
        aspectRatioPickerButtonHidden: false,
        rotateButtonsHidden: true,
        resetButtonHidden: true,
        aspectRatioLockEnabled: true,
        aspectRatioLockDimensionSwapEnabled: false,
        resetAspectRatioEnabled: false,
        aspectRatioPresets: [
          // CropAspectRatioPreset.original,
          // CropAspectRatioPreset.square,
          type == "profile"?
          CropAspectRatioPresetCustom():CropAspectRatioPresetCover(),
          // IMPORTANT: iOS supports only one custom aspect ratio in preset list
        ],
      ),
      // WebUiSettings(
      //   context: context,
      // ),
    ],
  );
  if(croppedFile != null){
    return XFile(croppedFile.path);
  }
  return null;

}
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (3, 3);

  @override
  String get name => '3x3 (customized)';
}

class CropAspectRatioPresetCover implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (3, 2);

  @override
  String get name => '3x3 (customized)';
}
