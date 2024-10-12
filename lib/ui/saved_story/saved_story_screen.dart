import 'dart:developer';

import 'package:checkmate/providers/story/saved_story_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constraints/helpers/helper.dart';
import '../../constraints/jcolor.dart';
import '../../modals/story.dart';
import '../../modals/story_comment.dart';
import '../../providers/story/story_comment_provider.dart';
import '../../providers/story/story_provider.dart';
import '../../providers/user/profile_provider.dart';
import '../common/app_input_field.dart';
import '../common/jempty_layout.dart';
import '../storytelling/components/story_comment_item.dart';
import '../storytelling/components/story_video_item.dart';

class SavedStoryScreen extends StatefulWidget {
  const SavedStoryScreen({super.key});

  @override
  State<SavedStoryScreen> createState() => _SavedStoryScreenState();
}

class _SavedStoryScreenState extends State<SavedStoryScreen> {
  GlobalKey listKey = GlobalKey();
  int _activeIndex = 0;
  List<VideoPlayerController> _controllers = [];
  TextEditingController comment = TextEditingController();
  StoryComment? replyComment = null;

  getPageData() async {
    var storyProvider = context.read<SavedStoryProvider>();
    var userProvider = context.read<ProfileProvider>();
    // if (storyProvider.list.length < 1) {
    bool res = await storyProvider.reset(userProvider.profile.id);
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
        _controllers[i].pause();
      } else {
        if (!_controllers[i].value.isPlaying) _controllers[i].play();
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
        title: Text("Saved Stories"),
      ),
      body: Consumer<SavedStoryProvider>(builder: (key, provider, child) {
        return Container(
            // height: getHeight(context) - 180,
            padding: EdgeInsets.only(bottom: 20),
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
                          var userProvider = context.read<ProfileProvider>();
                          bool res = await provider
                              .loadMoreData(userProvider.profile.id);
                        },
                        onRefresh: () async {
                          var userProvider = context.read<ProfileProvider>();
                          bool res =
                              await provider.reset(userProvider.profile.id);
                          provider.refreshController.refreshCompleted();
                          provider.refreshController =
                              provider.refreshController;
                        },
                        footer: ClassicFooter(),
                        child: ListView(
                          key: listKey,
                          physics: PageScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          children: [
                            ...List.generate(provider.list.length, (index) {
                              var e = provider.list[index];
                              var boxContext = listKey.currentContext;
                              var height = getHeight(context) - 180;
                              if (boxContext != null) {
                                var box =
                                    boxContext.findRenderObject() as RenderBox;
                                height = box.size.height;
                              }
                              log("ActiveIndex ${_activeIndex} - ${index}");
                              return VisibilityDetector(
                                key: Key('video_$index'),
                                onVisibilityChanged: (VisibilityInfo info) {
                                  _onVisibilityChanged(info, index);
                                },
                                child: Container(
                                    height: height,
                                    color: JColor.black.withOpacity(1),
                                    child: StoryVideoItem(
                                        story: e.story!,
                                        onLoad: () {
                                          setState(() {});
                                        },
                                        isVisible: _activeIndex == index,
                                        onControllerChanged:
                                            _onControllerChanged,
                                        onCommentClick: () {
                                          _showCommentsModal(e.story!);
                                        })),
                              );
                            })
                          ],
                        )));
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
                                    ...provider.list.map((e) => StoryCommentItem(
                                          commentItem: e,
                                          onReplyClick: (StoryComment commentItem) {
                                            setStateInDialog(() {
                                              replyComment = commentItem;
                                              replyComment!.commentId = e.id;
                                            });
                                          },
                                        ))
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
