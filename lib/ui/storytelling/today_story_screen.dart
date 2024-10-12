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

class TodayStoryScreen extends StatefulWidget {
  const TodayStoryScreen({super.key});

  @override
  State<TodayStoryScreen> createState() => _TodayStoryScreenState();
}

class _TodayStoryScreenState extends State<TodayStoryScreen> {
  GlobalKey listKey = GlobalKey();
  int _activeIndex = 0;
  List<VideoPlayerController> _controllers = [];
  final ScrollController _scrollController = ScrollController();
  TextEditingController comment = TextEditingController();
  List viewers = [];
  List<Story> list = [];
  double itemHeight = 0;
  StoryComment? replyComment = null;
  getPageData() async {
    var data = ModalRoute.of(context)!.settings.arguments;
    if(data is Map){
      print("it is map");
      var nData  = data as Map;
      if(nData["type"] == "story_detail"){
        List<Story> stories = nData["stories"];
        list.clear();
        list.addAll(stories);
        setState(() {});
        // return;
      }
    }else{
      var todayStoryProvider = context.read<TodayStoryProvider>();
      list = todayStoryProvider.list;
      setState(() {});
    }

    await Future.delayed(Duration(milliseconds: 800));
    scrollToIndex();
    // todayStoryProvider.reset();
    // var liveStreamProvider = context.read<LiveStreamProvider>();
    // liveStreamProvider.load();
  }
  void scrollToIndex() {
    // double itemHeight = item;
    if(itemHeight < 1){
      return;
    }
    int index = 0;
    try{
      var data = ModalRoute.of(context)!.settings.arguments;
      if(data != null){
        if(data is Story){
          Story story = data as Story;
          index = list.indexWhere((element) => story.userId == element.userId);
        }
      }
    }catch(e){
      print(e);
    }

    // Calculate the scroll offset
    double scrollOffset = itemHeight * index;
    _scrollController.animateTo(
      scrollOffset,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
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
      backgroundColor: JColor.black,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: JColor.black,
      ),
      body: Stack(
        children: [
          ListView(
            key: listKey,
            controller: _scrollController,
            physics: PageScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: [
              ...List.generate(list.length,
                      (index) {
                    var e = list[index];
                    var boxContext = listKey.currentContext;
                    var height = getHeight(context);
                    if (boxContext != null) {
                      var box = boxContext.findRenderObject()
                      as RenderBox;
                      height = box.size.height - 36;
                      itemHeight = height;
                    }
                    log("ActiveIndex ${_activeIndex} - ${index}");
                    return VisibilityDetector(
                      key: Key('today_video_$index'),
                      onVisibilityChanged:
                          (VisibilityInfo info) {
                        _onVisibilityChanged(info, index);
                      },
                      child: Container(
                          height: height,
                          color: JColor.black.withOpacity(1),
                          child: StoryVideoItem(
                            // key: UniqueKey(),
                              story: e,
                              onLoad: () {
                                setState(() {});
                              },
                              isVisible: _activeIndex == index,
                              onControllerChanged:
                              _onControllerChanged,
                              onCommentClick: () {
                                _showCommentsModal(e);
                              })),
                    );
                  }),
              SizedBox(height: 50,),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TouchableOpacity(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Image.asset("assets/icons/circle_blur_white.png",width: 40),
            ),
          )
        ],
      )
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
                                        (e) => StoryCommentItem(commentItem: e,onReplyClick: (commentItem){
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
              });
            }
          );
        });
  }
}
