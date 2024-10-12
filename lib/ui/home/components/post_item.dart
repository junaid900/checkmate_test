import 'package:checkmate/modals/cmpost.dart';
import 'package:checkmate/providers/blocked_user/blocked_user_provider.dart';
import 'package:checkmate/providers/home/home_post_provider.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constraints/helpers/helper.dart';
import '../../../constraints/jcolor.dart';
import '../../common/placeholder_image.dart';

class PostItem extends StatefulWidget {
  final CMPost post;
  final String profileImage;
  final String profileUserName;
  final String date;
  final String postImage;
  final String postTitle;
  final String desc;
  final String rating;
  final String userId;
  final Function onProfileTap;
  final Function onPostTap;

  const PostItem(
      {super.key,
      required this.post,
      required this.profileImage,
      required this.profileUserName,
      required this.date,
      required this.postImage,
      required this.desc,
      required this.rating,
      required this.onProfileTap,
      required this.onPostTap,
      required this.userId,
      required this.postTitle});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              TouchableOpacity(
                onTap: () {
                  widget.onPostTap();
                },
                child: Container(
                  width: getWidth(context),
                  height: getWidth(context),
                  child: ImageWithPlaceholder(
                      image: "${widget.postImage}", prefix: ""),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  JColor.blackTextColor.withOpacity(1),
                  Colors.transparent
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            widget.onProfileTap();
                          },
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: ImageWithPlaceholder(
                                image: "${widget.profileImage}",
                                prefix: "",
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.profileUserName}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: JColor.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${widget.date}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: JColor.white,
                                  ),
                                )
                              ],
                            ),
                          ]),
                        ),
                        TouchableOpacity(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: PopupMenuButton(
                              onSelected: (val) async {
                                if (val == "block") {
                                  showProgressDialog(context, "Please wait");
                                  var res = await context
                                      .read<BlockedUserProvider>()
                                      .block(userId: widget.userId, type: "block");
                                  if (res == true) {
                                    context
                                        .read<HomePostProvider>()
                                        .removePost(widget.post);
                                  }
                                  hideProgressDialog(context);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: "block",
                                    child: Text('Block User'),
                                  ),
                                ];
                              },
                              child: Image.asset(
                                "assets/icons/dots_menu.png",
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ),
                        ),

                        // Icon(Icons)
                      ],
                    ),
                    TouchableOpacity(
                        onTap: () {
                          widget.onPostTap();
                        },
                        child: SizedBox(height: 30,width: getWidth(context),)),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child:  TouchableOpacity(
                  onTap: () {
                    widget.onPostTap();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    width: getWidth(context),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      JColor.blackTextColor.withOpacity(1),
                      // JColor.blackTextColor.withOpacity(.5),
                      Colors.transparent
                    ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80,),
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: JColor.lighterGrey.withOpacity(.4),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/icons/star.png",
                                width: 16,
                                height: 16,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${widget.rating}",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 4,),
                        TouchableOpacity(
                          onTap: () {
                            widget.onPostTap();
                          },
                          child: Text(
                            "${widget.postTitle}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        Text(
                          "${widget.desc}",
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1),
          // SizedBox(height: 8),
        ],
      ),
    );
  }
}
