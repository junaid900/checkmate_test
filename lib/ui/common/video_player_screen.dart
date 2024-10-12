import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../post_detail/post_detail_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  String videoUrl = '';
  bool isLoading = false;

  initPlayerUrl() {
    _controller = VideoPlayerController.networkUrl(Uri.parse('${videoUrl}'))
      ..initialize().then((_) {
        _controller!.addListener(() {
          setState(() {
            isLoading = _controller!.value.isBuffering;
          });
        });
        _controller!.play();
        setState(() {});
      });
  }

  initPlayerFile(File file) async {
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        _controller!.addListener(() {
          setState(() {
            isLoading = _controller!.value.isBuffering;
          });
        });
        _controller!.play();
        setState(() {});
      });
  }

  getPageData() async {
    var data = ModalRoute.of(context)!.settings.arguments;
    // await Future.delayed(Duration(milliseconds: 1000));
    try {
      if (data is String) {
        videoUrl = data as String;
        initPlayerUrl();
      } else if (data is Map) {
        if (data["type"] != null) {
          if (data["type"] == 'file') {
            initPlayerFile(data["video"] as File);
          }
        }
      }
    } catch (e) {
      print("cannot play video try again later");
      print(e);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        body: _controller == null
            ? SizedBox()
            : SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: _controller!.value.isInitialized
                          ? isLoading
                              ? Center(child: CircularProgressIndicator())
                              : AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!),
                                )
                          : Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PostDetailHeaderButton(
                          image: "assets/icons/back.png",
                          onTap: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ],
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _controller == null
            ? SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ));
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }
}
