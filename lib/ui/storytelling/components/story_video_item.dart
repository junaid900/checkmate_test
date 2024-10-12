import 'dart:developer';

import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../constraints/helpers/helper.dart';
import '../../../constraints/j_var.dart';
import '../../../modals/story.dart';
import '../../common/placeholder_image.dart';

class StoryVideoItem extends StatefulWidget {
  final Story story;
  final Function onLoad;
  final bool isVisible;
  final Function(VideoPlayerController) onControllerChanged;
  final Function() onCommentClick;

  const StoryVideoItem(
      {super.key,
      required this.story,
      required this.onLoad,
      required this.isVisible,
      required this.onControllerChanged,
      required this.onCommentClick});

  @override
  State<StoryVideoItem> createState() => _StoryVideoItemState();
}

class _StoryVideoItemState extends State<StoryVideoItem>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool isLoading = false;
  late final AppLifecycleListener listener;

  @override
  void setState(VoidCallback fn) {
    if (this.mounted) super.setState(fn);
  }

  initPlayerUrl() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        '${JVar.FILE_URL}${JVar.imagePaths.storyVideo}/${widget.story.video}'))
      ..initialize().then((_) {
        _controller!.addListener(() {
          // _controller!.setLooping(true);
          setState(() {
            isLoading = _controller!.value.isBuffering;
          });
        });
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          aspectRatio: _controller!.value.aspectRatio,
          // autoPlay: true,
          looping: false,
          showControls: false,
          showOptions: true,
        );
        _chewieController!.addListener(() {

        });
        // _controller!.play();
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(StoryVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible) {
      _chewieController?.pause();
    }
    if (widget.isVisible) {
      // _chewieController?.play();
      if (_controller != null) widget.onControllerChanged(_controller!);
    } else {
      // _chewieController?.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _chewieController?.pause();
    }
  }

  playPause() {
    print("Play/Pause");
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else if (!_controller!.value.isPlaying) {
        if (_controller!.value.isCompleted) {
          _controller!.seekTo(Duration.zero);
        }
        _controller!.play();
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onLoad();
      initPlayerUrl();
    });
    // listener = WidgetLifeC(
    //   onShow: () => log('=>show'),
    //   onResume: () {
    //     log('onResume');
    //   },
    //   onHide: () => log('=>hide'),
    //   onInactive: () {
    //     log('inactive');
    //   },
    //   onPause: () => log('=>pause'),
    //   onDetach: () => log('=>detach'),
    //   onRestart: () => log('restart'),
    // );
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
    if (_chewieController != null) {
      _chewieController?.removeListener(() { });
      _chewieController?.dispose();
      _chewieController = null;
    }
    // TODO: implement dispose
    // listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(

      onFocusGained: () {
        print("Focus Gained");
        if (_controller != null) _controller!.play();
        // print(val);
      },
      onFocusLost: () {
        if (_controller != null) _controller!.pause();
        print("Focus Lost");
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              TouchableOpacity(
                onTap: () {
                  playPause();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (_controller != null)
                      Expanded(
                        child: Container(
                          width: getWidth(context),
                          child: _controller!.value.isInitialized
                              ? Chewie(
                                  controller: _chewieController!,
                                )
                              : Center(
                                  child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Initializing",
                                        style: TextStyle(color: JColor.white),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: LinearProgressIndicator(),
                                      )
                                    ],
                                  ),
                                )),
                        ),
                      ),
                  ],
                ),
              ),
              if (_controller != null && _chewieController != null)
                isLoading
                    ? SizedBox(
                        width: 140,
                        // height: 100,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: JColor.grey.withOpacity(.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Buffering...",
                                style: TextStyle(color: JColor.white),
                              ),
                              LinearProgressIndicator(),
                            ],
                          ),
                        ),
                      )
                    : AnimatedOpacity(
                        opacity: _chewieController!.isPlaying ? 0 : 1,
                        duration: Duration(milliseconds: 1000),
                        child: GestureDetector(
                          onTap: () {
                            playPause();
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: JColor.black.withOpacity(.4),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Icon(
                                Icons.play_arrow,
                                size: 50,
                                color: Colors.white,
                              )),
                        ),
                      ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      playPause();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          // color: Colors.grey.withOpacity(.7)
                          ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "@${widget.story.user!.username}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: JColor.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(.3),
                                        offset: Offset(3, 3),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8,),
                              InkWell(
                                onTap: (){
                                  handleFollow();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6,vertical: 2),
                                  decoration: BoxDecoration(
                                    color: JColor.black.withOpacity(.7),
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(6)

                                  ),
                                  child: Text(widget.story.user!.isFollowing? "Unfollow":"Follow",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),),
                                ),
                              )
                            ],
                          ),
                          Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              if (widget.story.tags != null)
                                ...widget.story.tags!
                                    .map((e) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3.0),
                                          child: Text(
                                            "#$e",
                                            style: TextStyle(
                                              color: JColor.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.grey
                                                      .withOpacity(.3),
                                                  offset: Offset(3, 3),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList()
                            ],
                          ),
                          Text(
                            "${widget.story.caption}.",
                            maxLines: 2,
                            style: TextStyle(
                              color: JColor.white,
                              overflow: TextOverflow.fade,
                              shadows: [
                                Shadow(
                                  color: Colors.grey.withOpacity(.3),
                                  offset: Offset(3, 3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _controller == null
                        ? SizedBox()
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              TouchableOpacity(
                                onTap: () {
                                  if (_controller != null) _controller!.pause();
                                  Navigator.of(context).pushNamed(
                                      JRoutes.viewProfileScreen,
                                      arguments:
                                          convertNumber(widget.story.user!.id));
                                },
                                child: Container(
                                  height: 74,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: ImageWithPlaceholder(
                                          prefix:
                                              "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/",
                                          image:
                                              "${widget.story.user!.profileImage}",
                                          width: 64,
                                          height: 64,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: TouchableOpacity(
                                  onTap: () async {
                                      handleFollow();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: JColor.white),
                                    child: Icon(
                                      widget.story.user!.isFollowing
                                          ? Icons.check_circle
                                          : Icons.add_circle_sharp,
                                      color: JColor.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                    SizedBox(
                      height: 12,
                    ),
                    TouchableOpacity(
                      onTap: () {
                        var storyProvider = context.read<StoryProvider>();
                        storyProvider.like(widget.story.id);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: JColor.black.withOpacity(.6),
                            ),
                            child: Image.asset("assets/icons/heart.png",
                                width: 22,
                                height: 22,
                                color: widget.story.isLiked
                                    ? JColor.primaryColor
                                    : JColor.white),
                          ),
                          SizedBox(height: 2,),
                          Text("${widget.story.likeCount ?? 0}",
                          style: TextStyle(
                            color: Colors.white
                          ),)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    TouchableOpacity(
                      onTap: () {
                        widget.onCommentClick();
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: JColor.black.withOpacity(.6),
                            ),
                            child: Image.asset("assets/icons/comment.png",
                                width: 22, height: 22),
                          ),
                          SizedBox(height: 2,),
                          Text("${widget.story.commentsCount ?? 0}",
                            style: TextStyle(
                                color: Colors.white
                            ),)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    TouchableOpacity(
                      onTap: () {
                        var storyProvider = context.read<StoryProvider>();
                        storyProvider.save(widget.story.id);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: JColor.black.withOpacity(.6),
                            ),
                            child: Image.asset("assets/icons/save.png",
                                width: 22,
                                height: 22,
                                color: widget.story.isSaved
                                    ? JColor.primaryColor
                                    : JColor.white),
                          ),
                          SizedBox(height: 2,),
                          Text("${widget.story.saveCount ?? 0}",
                            style: TextStyle(
                                color: Colors.white
                            ),)
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  handleFollow() async {
    print(widget.story.user!.isFollowing);
    var profile = widget.story.user;
    bool? result = false;
    var profileProvider = context.read<ProfileProvider>();
    showProgressDialog(context, "Please wait..");
    if (profile!.isFollowing) {
      result = await profileProvider.follow(
          "unfollow", profile!.id);
      if(result){
        setState(() {
          widget.story.user!.isFollowing = false;
        });
      }
    } else {
      result = await profileProvider.follow(
          "follow", profile!.id);
      if(result){
        setState(() {
          widget.story.user!.isFollowing = true;
        });
      }
    }
    hideProgressDialog(context);
  }
}
