import 'package:carousel_slider/carousel_slider.dart';
import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/cmpost.dart';
import 'package:checkmate/modals/post_comment.dart';
import 'package:checkmate/providers/post/post_comment_provider.dart';
import 'package:checkmate/providers/post/post_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:checkmate/ui/common/jempty_layout.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/post_detail/components/post_comment_item.dart';
import 'package:checkmate/ui/post_detail/components/post_info_tab.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../constraints/helpers/app_methods.dart';
import '../../constraints/j_var.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  TabController? tabController;
  CMPost? post;
  int currentTab = 1;
  var comment = TextEditingController();
  int _currentIndex = 0;
  CarouselController carouselController = CarouselController();
  PostComment? replyComment = null;

  void getPageData() async {
    setState(() {
      tabController = TabController(length: 2, vsync: this);
    });
    var data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      try {
        post = data as CMPost;
        if (post == null) {
          showAlertDialog(context, "Invalid Post", "Cannot get post data",
              type: AlertType.ERROR, onPress: () {
            Navigator.of(context).pop();
          });
          return;
        }
        if (post!.id == null) {
          showAlertDialog(context, "Invalid Post", "Cannot get post data",
              type: AlertType.ERROR, onPress: () {
            Navigator.of(context).pop();
          });
          return;
        }
      } catch (e) {
        showAlertDialog(context, "Invalid Post", "Cannot get post data",
            type: AlertType.ERROR, onPress: () {
          Navigator.of(context).pop();
        });
      }
      // return;
    }
    var commentProvider = context.read<PostCommentProvider>();
    commentProvider.reset(post!.id);
    setState(() {});
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
        toolbarHeight: 0,
        elevation: 0,
      ),
        body: post == null
            ? JEmptyLayout(
                text: "Cennot find post",
              )
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverList(
                        delegate: SliverChildListDelegate([
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 420.0,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                                items: [
                                  Images(
                                      image: post!.profileImage,
                                      type: "profile_image"),
                                  ...post!.images!
                                ].map((img) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return ImageWithPlaceholder(
                                        image: '${img.image}',
                                        prefix:
                                            '${JVar.FILE_URL}${img.type == "profile_image" ? JVar.imagePaths.postProfileImage : JVar.imagePaths.postDocument}/',
                                        width: getWidth(context),
                                        height: 420,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                width: getWidth(context),
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        JColor.black.withOpacity(.6),
                                        JColor.black.withOpacity(.3),
                                        JColor.black.withOpacity(0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: PostDetailHeaderButton(
                                              image: "assets/icons/back.png",
                                              onTap: () {
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Row(
                                          children: [
                                            Consumer<PostProvider>(builder:
                                                (key, provider, child) {
                                              return provider.isSaving
                                                  ? CircularProgressIndicator()
                                                  : PostDetailHeaderButton(
                                                      image:
                                                          "assets/icons/save.png",
                                                      active: post!.isSaved,
                                                      onTap: () async {
                                                        int saveStatus =
                                                            await provider
                                                                .save(post!.id);
                                                        if (saveStatus == 1) {
                                                          post!.isSaved = true;
                                                        }
                                                        if (saveStatus == 2) {
                                                          post!.isSaved = false;
                                                        }
                                                        setState(() {});
                                                      });
                                            }),
                                            // SizedBox(
                                            //   width: 8,
                                            // ),
                                            // PostDetailHeaderButton(
                                            //     image: "assets/icons/share.png",
                                            //     onTap: () {}),
                                            // SizedBox(
                                            //   width: 6,
                                            // ),
                                            // PopupMenuButton<String>(
                                            //   onSelected: (index) {},
                                            //   icon: IgnorePointer(
                                            //     child: PostDetailHeaderButton(
                                            //         image:
                                            //             "assets/icons/dots_menu.png",
                                            //         onTap: () {
                                            //
                                            //         }),
                                            //   ),
                                            //   itemBuilder:
                                            //       (BuildContext context) {
                                            //     return {
                                            //       'Report',
                                            //     }.map((String choice) {
                                            //       return PopupMenuItem<String>(
                                            //         value: choice,
                                            //         child: Text(choice),
                                            //       );
                                            //     }).toList();
                                            //   },
                                            // ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                right: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Images(
                                        image: post!.profileImage,
                                        type: "profile_image"),
                                    ...post!.images!
                                  ].asMap().entries.map((entry) {
                                    return Container(
                                      width: 10.0,
                                      height: 10.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentIndex == entry.key
                                            ? Colors.white
                                            : Colors.grey.withOpacity(.9),
                                        // borderRadius: BorderRadius.circular(50)
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: JColor.grey.withOpacity(.5),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: JColor.white,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: JColor.grey.withOpacity(.5),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          transform: Matrix4.translationValues(0, -20, 99),
                          decoration: BoxDecoration(),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: JColor.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: JColor.grey.withOpacity(.6),
                                            blurRadius: 4),
                                      ],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${post!.name}",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/star.png",
                                                  width: 18,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  "${calculateAvgRating(communicationRating: convertDouble(post!.ratingCommunication), behaviourRating: convertDouble(post!.ratingBehaviour), timeRating: convertDouble(post!.ratingTime), loyaltyRating: convertDouble(post!.ratingLoyalty)).toString()}",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      TouchableOpacity(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              JRoutes.attachmentScreen,
                                              arguments: post);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                              color:
                                                  JColor.grey.withOpacity(.2),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: Text("See All Attachments"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                                if (tabController != null)
                                  TabBar(
                                      controller: tabController,
                                      isScrollable: true,
                                      padding: EdgeInsets.zero,
                                      indicatorPadding:
                                          EdgeInsets.only(top: 18),
                                      labelPadding:
                                          EdgeInsets.only(left: 0, right: 10),
                                      tabAlignment: TabAlignment.start,
                                      onTap: (index) {
                                        setState(() {
                                          currentTab = index + 1;
                                        });
                                      },
                                      tabs: const [
                                        Text(
                                          "Info",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text("Comments",
                                            style: TextStyle(fontSize: 18)),
                                      ]),
                              ])),
                    ]))
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                  child: Builder(builder: (context) {
                    if (currentTab == 1) {
                      return PostInfoTab(post: post!);
                    } else if (currentTab == 2) {
                      return Consumer<PostCommentProvider>(
                          builder: (key, provider, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            if (replyComment != null)
                              Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: JColor.primaryColor.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          'Replying to @${replyComment!.user!.username}'),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          comment.text = '';
                                          replyComment = null;
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                              ),
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  child: AppInputField(
                                    hintText: "Enter Comment",
                                    controller: comment,
                                    maxLength: 130,
                                    maxLines: 2,
                                  ),
                                ),
                                provider.isSending
                                    ? CircularProgressIndicator()
                                    : IconButton(
                                        onPressed: () async {
                                          if (comment.text.isEmpty) {
                                            showToast(
                                                "cannot send empty comment");
                                          }
                                          var userProvider =
                                              context.read<ProfileProvider>();

                                          if(replyComment != null){
                                            await provider.replyComment(PostComment(
                                              id: generateRandomId(),
                                              user: userProvider.profile,
                                              postId: post!.id.toString(),
                                              comment: comment.text,
                                            ), replyComment!, replyComment!.commentId);
                                          }else{
                                            await provider.send(PostComment(
                                              id: generateRandomId(),
                                              user: userProvider.profile,
                                              postId: post!.id.toString(),
                                              comment: comment.text,
                                            ));
                                          }
                                          comment.text = '';
                                          if (replyComment != null) {
                                            replyComment = null;
                                          }
                                          setState(() {});
                                        },
                                        color: JColor.primaryColor,
                                        icon: Icon(
                                          Icons.send,
                                          size: 30,
                                        ))
                              ],
                            ),
                            Flexible(
                              child: SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: true,
                                controller: provider.refreshController,
                                onLoading: () async {
                                  bool res = await provider.loadMoreData();
                                },
                                onRefresh: () async {
                                  bool res = await provider.reset(post!.id);
                                  provider.refreshController.refreshCompleted();
                                  provider.refreshController =
                                      provider.refreshController;
                                },
                                footer: ClassicFooter(),
                                child: ListView(
                                  children: [
                                    ...provider.list.map((e) => CommentItem(
                                        commentItem: e,
                                        onReplyClick:
                                            (PostComment commentItem) {
                                          setState(() {
                                            replyComment = commentItem;
                                            replyComment!.commentId = e.id;
                                          });
                                        }))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                    } else {
                      return SizedBox();
                    }
                  }),
                )));
  }
}

class PostDetailHeaderButton extends StatelessWidget {
  final String image;
  final bool active;
  final Function onTap;

  const PostDetailHeaderButton(
      {super.key,
      required this.image,
      required this.onTap,
      this.active = false});

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: () {
        this.onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Color.fromRGBO(154, 153, 153, 0.6)),
        child: Center(
          child: Image.asset(
            this.image,
            width: 26,
            color: active ? JColor.primaryColor : JColor.white,
          ),
        ),
      ),
    );
  }
}
