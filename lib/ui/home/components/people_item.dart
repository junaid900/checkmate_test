import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constraints/enum_values.dart';
import '../../../constraints/helpers/helper.dart';
import '../../../constraints/j_var.dart';
import '../../../constraints/jcolor.dart';
import '../../../modals/User.dart';
import '../../../modals/conversation.dart';
import '../../../providers/chat/conversation_provider.dart';
import '../../../providers/user/profile_provider.dart';
import '../../../utils/route/route_names.dart';
import '../../common/app_color_button.dart';
import '../../common/placeholder_image.dart';

class PeopleItem extends StatefulWidget {
  User userData;

  PeopleItem({super.key, required this.userData});

  @override
  State<PeopleItem> createState() => _PeopleItemState();
}

class _PeopleItemState extends State<PeopleItem> {
  bool isFollowLoading = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(widget.userData.id);
        Navigator.of(context).pushNamed(JRoutes.viewProfileScreen,
            arguments: convertNumber(widget.userData.id));
      },
      child: AnimatedContainer(
        duration: Duration(seconds: 5),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: JColor.primaryColor),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: ImageWithPlaceholder(
                        image: '${widget.userData.profileImage}',
                        prefix:
                            "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/",
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      )),
                )),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.userData.fname}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  SizedBox(
                    width: 240,
                    child: Text(
                      "@${widget.userData.username}",
                      maxLines: 1,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<ProfileProvider>(builder: (key, provider, child) {
              if (provider.profile.id == widget.userData.id) return SizedBox();
              // if ((provider.profile.id != widget.personProfile.id) && !widget.userData.isFollowing)

              return SizedBox(
                width: 110,
                child: AppColorButton(
                  elevation: 0,
                  fontSize: 12,
                  name: widget.userData.isFollowing?"Unfollow":"Follow",
                  isLoading: isFollowLoading,
                  color: widget.userData.isFollowing? Colors.red: JColor.primaryColor,
                  onPressed: () async {
                    var profile = widget.userData;;
                    if (provider.isFollowLoading) {
                      return;
                    }
                    bool result = false;
                    setState(() {
                      isFollowLoading = true;
                    });
                    if (widget.userData.isFollowing) {
                      result =
                          await provider.follow("unfollow", profile.id);
                    } else {
                      result =
                          await provider.follow("follow", profile.id);
                    }
                    setState(() {
                      isFollowLoading = false;
                    });

                    if (result) {
                      setState(() {
                        if (widget.userData.isFollowing) {
                          widget.userData.isFollowing = false;
                        } else {
                          widget.userData.isFollowing = true;
                        }
                      });
                    }
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
