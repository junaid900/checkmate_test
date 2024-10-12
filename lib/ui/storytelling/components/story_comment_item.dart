import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constraints/j_var.dart';
import '../../../modals/post_comment.dart';
import '../../../modals/story_comment.dart';
import '../../../providers/story/story_comment_provider.dart';
import '../../common/touchable_opacity.dart';

class StoryCommentItem extends StatefulWidget {
  final StoryComment commentItem;
  final Function(StoryComment) onReplyClick;
  bool isReply = false;
  StoryCommentItem({super.key,  required this.commentItem,
    required this.onReplyClick,
    this.isReply = false});

  @override
  State<StoryCommentItem> createState() => _StoryCommentItemState();
}

class _StoryCommentItemState extends State<StoryCommentItem> {
  bool isLikeLoading = false;
  @override
  Widget build(BuildContext context) {
    return  AnimatedContainer(
      width: getWidth(context),
      duration: Duration(seconds: 5),
      padding: EdgeInsets.symmetric(
          horizontal: 10, vertical: widget.isReply ? 0 : 10),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        // color: Colors.transparent,
      ),
      child: Column(
        children: [
          Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 2, color: JColor.accentColor),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        // radius: 25,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: ImageWithPlaceholder(
                                image:
                                '${widget.commentItem.user!.profileImage}',
                                prefix:
                                "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/",
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              )),
                        )),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              var profileProvider =
                              context.read<ProfileProvider>();
                              if (profileProvider.profile.id.toString() ==
                                  widget.commentItem.userId.toString()) {
                                _commentActionSheet(
                                    context, widget.commentItem);
                              } else {}
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.commentItem.user!.fname}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                RichText(
                                    text: TextSpan(
                                        text: widget.commentItem.repliedTo !=
                                            null
                                            ? "${widget.commentItem.repliedTo!.username ?? ''} "
                                            : null,
                                        style: TextStyle(
                                            color: JColor.primaryColor),
                                        children: [
                                          TextSpan(
                                            text: "${widget.commentItem.comment}",
                                            style:
                                            TextStyle(color: Colors.blueGrey),
                                          ),
                                        ])),
                                // Text(
                                //   ,
                                //
                                // ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "${DateFormat('hh:mm a - MMM dd, yyyy').format(DateTime.parse(widget.commentItem.createdAt!))}",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TouchableOpacity(
                            onTap: () {
                              widget.onReplyClick(widget.commentItem);
                            },
                            child: Text(
                              "Reply",
                              style: TextStyle(
                                  color: JColor.primaryColor, fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isLikeLoading
                  ? SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.3,
                  ))
                  : TouchableOpacity(
                onTap: () async {
                  var commentProvider =
                  context.read<StoryCommentProvider>();
                  setState(() {
                    isLikeLoading = true;
                  });
                  var res = await commentProvider.commentLike(
                      widget.commentItem.id,
                      widget.commentItem.commentId);
                  setState(() {
                    isLikeLoading = false;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.commentItem.isLike
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      size: 20,
                      color: widget.commentItem.isLike
                          ? Colors.red
                          : JColor.grey,
                    ),
                    Text(
                      "${widget.commentItem.commentLikesCount}",
                      style: TextStyle(
                        fontSize: 12,
                        color: JColor.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          widget.commentItem.repliesCount > 0 && !widget.isReply
              ? Column(
            children: [
              if ( widget.commentItem.viewReplies)
                InkWell(
                  onTap: () async {
                    var postCommentProvider = context.read<StoryCommentProvider>();
                    postCommentProvider.setViewReplies(widget.commentItem.id, false);
                  },
                  child: Text(
                    "Hide Replies",
                    style: TextStyle(
                        fontSize: 10, color: JColor.greyTextColor),
                  ),
                ),
              if (!widget.isReply && widget.commentItem.viewReplies)
                AnimatedContainer(
                  duration: Duration(
                    milliseconds: 600,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        color: JColor.lighterGrey,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      ...widget.commentItem.replies.map((e) {
                        return StoryCommentItem(
                            commentItem: e,
                            onReplyClick: (e) {
                              widget.onReplyClick(e);
                            },
                            isReply: true);
                      }).toList(),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        color: JColor.lighterGrey,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      print("load more");
                      if (!widget.commentItem.viewReplies) {
                        await context
                            .read<StoryCommentProvider>()
                            .loadCommentReplies(widget.commentItem.id);
                      } else {
                        await context
                            .read<StoryCommentProvider>()
                            .loadMoreRepliesData(widget.commentItem.id);
                      }

                      var postCommentProvider = context.read<StoryCommentProvider>();
                      postCommentProvider.setViewReplies(widget.commentItem.id, true);
                    },
                    child: Text(
                      widget.commentItem.viewReplies && widget.commentItem.noMore
                          ? "No More"
                          : widget.commentItem.viewReplies
                          ? "View More"
                          : "View all ${widget.commentItem.repliesCount} Replies",
                      style: TextStyle(
                          fontSize: 10, color: JColor.greyTextColor),
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  widget.commentItem.isReplyLoading
                      ? SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  )
                      : SizedBox()
                ],
              ),
            ],
          )
              : SizedBox()
        ],
      ),
    );
  }
}
void _commentActionSheet(BuildContext context, StoryComment comment) {
  TextEditingController commentController = TextEditingController(text: comment.comment);
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Comment Actions'),
      message: const Text('Edit/Delete'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would be a default
          /// default behavior, turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Edit Comment'),
                  content: TextField(
                    minLines: 2,
                    maxLines: 2,
                    controller: commentController,
                    // controller: _textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: "Enter your new comment."),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text('Update'),
                      onPressed: () async {
                        var storyCommentProvider = context.read<StoryCommentProvider>();
                        var storyProvider = context.read<StoryProvider>();
                        showProgressDialog(context, "Updating....");
                        var res = await storyCommentProvider.editComment(comment.id, commentController.text);
                        hideProgressDialog(context);
                        if(res == 1){

                        }else{
                          showToast("cannot edit comment right now");
                        }
                        Navigator.pop(context);

                      },
                    ),
                  ],
                );
              },
            );
            Navigator.pop(context);
          },
          child: const Text('Edit Comment'),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            var storyCommentProvider = context.read<StoryCommentProvider>();
            var storyProvider = context.read<StoryProvider>();
            showProgressDialog(context, "Deleting....");
            var res = await storyCommentProvider.deleteComment(comment);
            hideProgressDialog(context);
            if(res == 1){
              storyProvider.setCommentCount(comment.storyId.toString(), decrease: true);
              showToast("Deleted successfully");
            }else{
              showToast("cannot delete comment right now");
            }
            Navigator.pop(context);
          },
          child: const Text('Delete Comment',
            style: TextStyle(
                color: Colors.red
            ),),
        ),
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
