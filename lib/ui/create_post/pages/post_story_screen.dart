import 'dart:convert';
import 'dart:io';

import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../constraints/j_var.dart';
import '../../../providers/post/create_post_provider.dart';
import '../../../utils/route/route_names.dart';

class PostStoryScreen extends StatefulWidget {
  const PostStoryScreen({super.key});

  @override
  State<PostStoryScreen> createState() => _PostStoryScreenState();
}

class _PostStoryScreenState extends State<PostStoryScreen> {
  File? file;
  File? videoFile;
  VideoPlayerController? _playerController;
  List<String> tags = [];
  TextEditingController tagTextField = TextEditingController();
  TextEditingController caption = TextEditingController();

  getPageData() async {
    var data = ModalRoute
        .of(context)!
        .settings
        .arguments;
    precacheImage(AssetImage('assets/images/recording.png'), context);
    precacheImage(AssetImage('assets/images/stop_recording.png'), context);

    if (data != null) {
      videoFile = data as File;
      final fileName = await VideoThumbnail.thumbnailFile(
        video: videoFile!.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        // maxHeight: 64,
        // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );
      if (fileName != null) file = File(fileName!);
      // _playerController = VideoPlayerController.file(file!);
      setState(() {});
    }
  }

  addTag({type = 'add', index = -1}) {
    if(tags.length > 5){
      showToast("cannot enter more then 5 tags");
      return;
    }
    if (type == 'add') {
      tags.add(tagTextField.text);
      tagTextField.text = "";
    } else if (type == 'remove') {
      if (index < 0) return;
      tags.removeAt(index);
    }
    setState(() {});
  }
  submit() async {
    if(caption.text.isEmpty){
      showToast("caption cannot be empty");
      return;
    }
    if(tags.isEmpty){
      showToast("tags cannot be empty at least one tag needed");
      return;
    }
    if(videoFile == null){
      showToast("cannot get your video to post please try again later");
      return;
    }
    var profileProvider = context.read<ProfileProvider>();
    var user = profileProvider.profile;
    if(user.id == null){
      showToast("cannot get user detail");
      return;
    }
    showProgressDialog(context, "Uploading Video...");
    String urlResponse = await CreatePostProvider().uploadFiles(
        "${JVar.imagePaths.storyVideo}", videoFile!);
    hideProgressDialog(context);
    if(urlResponse.isEmpty){
      showToast("Error while upload video");
      return;
    }
    var storyProvider = context.read<StoryProvider>();
    showProgressDialog(context, "Posting story...");
    var res = await storyProvider.postStory({
      "tags": jsonEncode(tags),
      "caption": caption.text,
      "video": urlResponse,
    });
    hideProgressDialog(context);
    if(res){
      Navigator.of(context).popUntil((route) => route.settings.name == JRoutes.main);
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
        title: Text("Post Story"),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 120,
                            margin: EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: JColor.lighterGrey,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                (file == null)
                                    ? Image.asset(
                                    "assets/images/placeholder_image.png")
                                    : Image.file(
                                  file!,
                                  width: getWidth(context),
                                  // height: 300,
                                  fit: BoxFit.contain,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: JColor.lighterGrey.withOpacity(.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                      onPressed: () {
                                        if (videoFile == null) {
                                          return;
                                        }
                                        Navigator.of(context).pushNamed(
                                            JRoutes.videoPlayerScreen,
                                            arguments: {
                                              "type": "file",
                                              "video": videoFile,
                                            });
                                      },
                                      icon: Icon(Icons.play_arrow)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AppInputField(
                            controller: caption,
                            hintText: "Caption your story",
                            minLines: 4,
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter Tag",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                                flex: 5,
                                child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: AppInputField(
                                      hintText: "Eg. Rude",
                                      controller: tagTextField,
                                    ))),
                            Expanded(
                              flex: 2,
                              child: AppColorButton(
                                elevation: 0,
                                name: "Add",
                                color: JColor.primaryColor,
                                onPressed: () {
                                  if (tagTextField.text.isEmpty) {
                                    showToast("Tag cannot be empty");
                                    return;
                                  }
                                  RegExp regex = RegExp(r'[^a-zA-Z0-9]');
                                  if (regex.hasMatch(tagTextField.text)) {
                                    showToast(
                                        "Tag cannot contain space or any special character");
                                    return;
                                  }
                                  addTag();
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Wrap(
                          children: [
                            Container(
                              width: getWidth(context),
                            ),

                            ...tags
                                .asMap().map((i, e) =>
                                MapEntry(i, Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: JColor.lighterGrey,
                                      borderRadius:
                                      BorderRadius.circular(50)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("#${e}"),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      TouchableOpacity(
                                          onTap: () {
                                            addTag(type: "remove", index:i);
                                          },
                                          child: Icon(
                                              Icons.remove_circle_sharp))
                                    ],
                                  ),
                                )))
                                .values.toList()
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            height: 60,
            child: Row(
              children: [
                Flexible(
                  child: TouchableOpacity(
                    onTap: (){
                      submit();
                    },
                    child: AppColorButton(
                      elevation: 0,
                      color: JColor.primaryColor,
                      name: "Post Story",
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
