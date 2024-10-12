import 'dart:developer';
import 'dart:io';

import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/cmpost.dart';
import 'package:checkmate/ui/common/japp_bar.dart';
import 'package:checkmate/ui/common/jempty_layout.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../constraints/enum_values.dart';
import '../../constraints/helpers/helper.dart';

class PostAttachmentScreen extends StatefulWidget {
  const PostAttachmentScreen({super.key});

  @override
  State<PostAttachmentScreen> createState() => _PostAttachmentScreenState();
}

class _PostAttachmentScreenState extends State<PostAttachmentScreen>
    with TickerProviderStateMixin {
  TabController? tabController;
  CMPost? post;

  void loadThumbnails() async {
    print("Thumnailes");
    try {
      for (int i = 0; i < post!.videos!.length; i++) {
        final fileName = await VideoThumbnail.thumbnailFile(
          video:
              "${JVar.FILE_URL}${JVar.imagePaths.videoDocument}/${post!.videos![i].video}",
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 64,
          quality: 75,
        );
        post!.videos![i].thumbnail = fileName;
        log(fileName.toString());
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  getPageData() async {
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
        loadThumbnails();
      } catch (e) {
        showAlertDialog(context, "Invalid Post", "Cannot get post data",
            type: AlertType.ERROR, onPress: () {
          Navigator.of(context).pop();
        });
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
        title: Text("Attachments"),
        bottom: tabController == null
            ? null
            : TabBar(
                controller: tabController,
                tabs: [
                  Text(
                    "Images",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text("Videos", style: TextStyle(fontSize: 18)),
                ],
              ),
      ),
      body: tabController == null || post == null
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBarView(
                controller: tabController,
                children: [
                  post!.images!.isEmpty
                      ? JEmptyLayout(
                          text: "No images with this post",
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          children: post!.images!
                              .map((e) => ImageWithPlaceholder(
                                  image: e.image,
                                  prefix:
                                      "${JVar.FILE_URL}${JVar.imagePaths.postDocument}/"))
                              .toList(),
                        ),
                  post!.videos!.isEmpty
                      ? JEmptyLayout(
                          text: "No videos with this post",
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          children: post!.videos!
                              .map((e) => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: getWidth(context),
                                        height: getWidth(context),
                                        child: e.thumbnail != null
                                            ? Image.file(
                                                File(e.thumbnail!),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                "assets/images/placeholder_image.png"),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: JColor.lighterGrey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  JRoutes.videoPlayerScreen,
                                                  arguments:
                                                      "${JVar.FILE_URL}${JVar.imagePaths.videoDocument}/${e.video}");
                                            },
                                            icon: Icon(Icons.play_arrow)),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
