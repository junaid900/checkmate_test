import 'dart:developer';

import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/modals/story_comment.dart';
import 'package:checkmate/providers/firebase/firebase_live_stream_provider.dart';
import 'package:checkmate/providers/live_stream/live_stream_provider.dart';
import 'package:checkmate/providers/story/story_comment_provider.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/providers/story/today_story_provider.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/storytelling/components/story_comment_item.dart';
import 'package:checkmate/ui/storytelling/components/story_status_item.dart';
import 'package:checkmate/ui/storytelling/components/story_video_item.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constraints/jcolor.dart';
import '../../modals/story.dart';
import '../../providers/user/profile_provider.dart';
import '../common/app_input_field.dart';
import '../common/jempty_layout.dart';
import '../common/placeholder_image.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  GlobalKey listKey = GlobalKey();
  int _activeIndex = 0;
  List<VideoPlayerController> _controllers = [];
  TextEditingController comment = TextEditingController();
  List viewers = [];
  TabController? tabController;
  int currentTab = 0;
  StoryComment? replyComment = null;

  getPageData() async {
    var storyProvider = context.read<StoryProvider>();
    var todayStoryProvider = context.read<TodayStoryProvider>();
    var profileProvider = context.read<ProfileProvider>();
    if (storyProvider.list.length < 1) {
      storyProvider.reset();
    }
    todayStoryProvider.reset(profileProvider.profile.id);
    // var liveStreamProvider = context.read<LiveStreamProvider>();
    // liveStreamProvider.load();
    var firebaseLiveStream = context.read<FirebaseLiveStreamProvider>();
    firebaseLiveStream.initLoadStreams(profileProvider.profile);
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    tabController!.addListener(() {
      if (tabController!.indexIsChanging) {
        print("tab chanaged");
        // currentTab = tabController!.index
        // setState(() {});
      }
    });
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

  void _onVisibilityChanged(VisibilityInfo info, int index) {
    if (info.visibleFraction > 0.5 && _activeIndex != index) {
      print("${index} visible");
      setState(() {
        _activeIndex = index;
      });
    }
  }

  void _pauseAllExceptActive() {
    for (int i = 0; i < _controllers.length; i++) {
      if (i != _activeIndex) {
        // _controllers[i].pause();
      } else {
        // if (!_controllers[i].value.isPlaying) _controllers[i].play();
      }
    }
  }

  void _onControllerChanged(VideoPlayerController controller) {
    if (!_controllers.contains(controller)) {
      _controllers.add(controller);
    }
    _pauseAllExceptActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Consumer<StoryProvider>(builder: (key, provider, child) {
        return Flex(
          direction: Axis.vertical,
          children: [
            Container(
              height: 90,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                // scrollDirection: Axis.horizontal,
                children: [
                  Consumer<ProfileProvider>(builder: (key, provider, child) {
                    return Consumer<TodayStoryProvider>(
                        builder: (key, todayStoryProvider, child) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          TouchableOpacity(
                            onTap: () {
                              if(todayStoryProvider.myStory != null){
                                Navigator.pushNamed(
                                    context, JRoutes.todayStoriesScreen,
                                    arguments: todayStoryProvider.myStory);
                              }else{
                                Navigator.pushNamed(context, JRoutes.createPost);
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      border: todayStoryProvider.myStory != null
                                          ? Border.all(
                                              color: JColor.accentColor,
                                              width: 2.5)
                                          : null,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: ImageWithPlaceholder(
                                      image: '${provider.profile.profileImage}',
                                      prefix:
                                          '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: TouchableOpacity(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, JRoutes.createPost);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  Icons.add_circle_rounded,
                                  color: JColor.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
                  }),
                  SizedBox(
                    width: getWidth(context) - 110,
                    child: Consumer<FirebaseLiveStreamProvider>(
                        builder: (key, provider, child) {
                      return Consumer<TodayStoryProvider>(builder:
                          (todayStoryKey, todayStoriesProvider,
                              todayStoryChild) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          children: [
                            ...provider.list
                                .map((e) => e.agoraUid == null
                                    ? SizedBox()
                                    : e.agoraUid!.isEmpty
                                        ? SizedBox()
                                        : TouchableOpacity(
                                            onTap: () {
                                              print(_activeIndex);
                                              if (_controllers.length <
                                                  _activeIndex) {
                                                _controllers[_activeIndex]
                                                    .pause();
                                              }
                                              var data = {
                                                "stream": e,
                                              };
                                              Navigator.pushNamed(context,
                                                  JRoutes.liveStreamScreen,
                                                  arguments: data);
                                            },
                                            child: StoryStatusItem(
                                              image:
                                                  "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/${e.user != null ? e.user!.profileImage : ''}",
                                              name: e.user!.fname!,
                                            ),
                                          ))
                                .toList(),
                            ...todayStoriesProvider.singlePersonList.map(
                              (e) => TouchableOpacity(
                                onTap: () {
                                  // Naviga
                                  Navigator.pushNamed(
                                      context, JRoutes.todayStoriesScreen,
                                      arguments: e);
                                },
                                child: StoryStatusItem(
                                  image:
                                      "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/${e.user != null ? e.user!.profileImage : ''}",
                                  isLive: false,
                                  name: e.user!.fname!,
                                ),
                              ),
                            )
                          ],
                        );
                      });
                    }),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: getHeight(context),
                      child: provider.isLoading && provider.list.length < 1
                          ? Center(
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator()),
                            )
                          : !provider.isLoading && provider.list.length < 1
                              ? JEmptyLayout(
                                  height: 120,
                                  width: 120,
                                  text: "No Story Found",
                                )
                              : SmartRefresher(
                                  enablePullDown: true,
                                  enablePullUp: true,
                                  controller: provider.refreshController,
                                  onLoading: () async {
                                    // bool res = await provider.loadMoreData();
                                    if (currentTab == 1) {
                                      provider.loadMoreData(
                                          currentTab: "following");
                                    } else {
                                      bool res = await provider.loadMoreData();
                                    }
                                  },
                                  onRefresh: () async {
                                    if (currentTab == 1) {
                                      provider.reset(currentTab: "following");
                                    } else {
                                      bool res = await provider.reset();
                                    }
                                    provider.refreshController
                                        .refreshCompleted();
                                    provider.refreshController =
                                        provider.refreshController;
                                  },
                                  footer: ClassicFooter(),
                                  child: ListView(
                                    key: listKey,
                                    physics: PageScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      ...List.generate(provider.list.length,
                                          (index) {
                                        var e = provider.list[index];
                                        var boxContext = listKey.currentContext;
                                        var height = getHeight(context) - 180;
                                        if (boxContext != null) {
                                          var box = boxContext
                                              .findRenderObject() as RenderBox;
                                          height = box.size.height;
                                        }
                                        log("ActiveIndex ${_activeIndex} - ${index}");
                                        return VisibilityDetector(
                                          key: Key('video_$index'),
                                          onVisibilityChanged:
                                              (VisibilityInfo info) {
                                            _onVisibilityChanged(info, index);
                                          },
                                          child: Container(
                                              height: height,
                                              color:
                                                  JColor.black.withOpacity(1),
                                              child: StoryVideoItem(
                                                  story: e,
                                                  onLoad: () {
                                                    setState(() {});
                                                  },
                                                  isVisible:
                                                      _activeIndex == index,
                                                  onControllerChanged:
                                                      _onControllerChanged,
                                                  onCommentClick: () {
                                                    _showCommentsModal(e);
                                                  })),
                                        );
                                      })
                                    ],
                                  ))),
                  if (tabController != null)
                    Container(
                      width: getWidth(context),
                      decoration: BoxDecoration(
                        color: JColor.black.withOpacity(.6),
                        // borderRadius: BorderRadius.circular(4),
                        // gradient: LinearGradient(
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        //   colors: [
                        //     JColor.black.withOpacity(.7),
                        //     Colors.transparent
                        //
                        //   ]
                        // )
                      ),
                      child: TabBar(
                          controller: tabController,
                          // splashBorderRadius: BorderRadius.circular(radius),
                          isScrollable: true,
                          // physics: S(),
                          // padding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.only(top: 4),
                          labelPadding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 4),
                          tabAlignment: TabAlignment.center,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[500],
                          labelStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          dividerColor: Colors.transparent,
                          indicator: DotIndicator(),
                          onTap: (index) {
                            if (currentTab == index) {
                              return;
                            }
                            setState(() {
                              currentTab = index;
                            });
                            var storyProvider = context.read<StoryProvider>();
                            if (index == 1) {
                              storyProvider.reset(currentTab: "following");
                            } else {
                              storyProvider.reset();
                            }
                          },
                          tabs: [
                            Tab(
                              text: "For You",
                            ),
                            Tab(
                              text: "Following",
                            ),
                          ]),
                    ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
  _showCommentsModal(Story story) {
    setState(() {
      replyComment = null;
    });
    context.read<StoryCommentProvider>().reset(story.id!);
    showModalBottomSheet(
        scrollControlDisabledMaxHeightRatio: .8,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateInDialog) {
              return Consumer<StoryCommentProvider>(
                  builder: (key, provider, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
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
                                    setStateInDialog(() {});
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
                              hintText: "Type Your Comment...",
                              controller: comment,
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
                                      await provider.replyComment(StoryComment(
                                        id: generateRandomId(),
                                        user: userProvider.profile,
                                        storyId: story.id.toString(),
                                        comment: comment.text,
                                      ), replyComment!, replyComment!.commentId);
                                    }else{
                                      await provider.send(StoryComment(
                                        id: generateRandomId(),
                                        user: userProvider.profile,
                                        storyId: story.id.toString(),
                                        comment: comment.text,
                                      ));
                                    }
                                    comment.text = '';
                                    if (replyComment != null) {
                                      replyComment = null;
                                    }
                                    setStateInDialog((){});

                                  },
                                  color: JColor.primaryColor,
                                  icon: Icon(
                                    Icons.send,
                                    size: 30,
                                  ))
                        ],
                      ),
                      Flexible(
                        child: provider.isLoading
                            ? Center(
                                child: SizedBox(
                                    width: 40,
                                    height: 40,
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
                                  bool res = await provider.reset(story.id!);
                                  provider.refreshController.refreshCompleted();
                                  provider.refreshController =
                                      provider.refreshController;
                                },
                                footer: ClassicFooter(),
                                child: ListView(
                                  children: [
                                    ...provider.list.map(
                                        (e) => StoryCommentItem(commentItem: e, onReplyClick: (StoryComment commentItem) {
                                          setStateInDialog(() {
                                            replyComment = commentItem;
                                            replyComment!.commentId = e.id;
                                          });
                                        },))
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                );
                ;
              });
            }
          );
        });
  }
}

class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(this, onChanged);
  }
}

class _DotPainter extends BoxPainter {
  final DotIndicator decoration;

  _DotPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = JColor.accentColor // Dot color
      ..style = PaintingStyle.fill;

    final double radius = 6.0; // Dot size
    final Offset circleOffset = Offset(
      configuration.size!.width / 2 + offset.dx,
      configuration.size!.height - radius, // Dot position at the bottom center
    );

    canvas.drawCircle(circleOffset, radius, paint);
  }
}
