import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constraints/jcolor.dart';
import '../../../../modals/User.dart';
import '../../../../modals/conversation.dart';
import '../../../../utils/route/route_names.dart';
import '../../../common/placeholder_image.dart';
import '../../../common/touchable_opacity.dart';

class ConversationItem extends StatefulWidget {
  Conversation conversation;
  Function? reset;

  ConversationItem({super.key, required this.conversation, this.reset});

  @override
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  @override
  Widget build(BuildContext context) {
    var profile = context.read<ProfileProvider>().profile;
    ChatData? otherUserChat = widget.conversation.getOtherUser(profile.id);
    ChatData? myChat = widget.conversation.getMyChat(profile.id);

    User? otherUser;
    if (otherUserChat == null) {
      return SizedBox();
    }
    otherUser = otherUserChat.user;
    if (otherUser == null) {
      return SizedBox();
    }
    return TouchableOpacity(
      onTap: () async {
        // Navigator.of(context).pushNamed(JRoutes.conversationDetail);
        var data = await Navigator.pushNamed(
            context, JRoutes.conversationDetail,
            arguments: {
              "other_user": otherUser,
              "conversation": widget.conversation,
              "type": "conversation",
            });
        if (widget.reset != null) widget.reset!();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageWithPlaceholder(
                prefix: '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                image: "${otherUser.profileImage}",
                width: 65,
                height: 65,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${otherUser.fname}",
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    "${widget.conversation.lastMsg}",
                    maxLines: 2,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: JColor.greyTextColor,
                        overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${widget.conversation.timeAgo}",
                  style: TextStyle(
                    color: JColor.greyTextColor,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                if (myChat != null)
                  if (convertNumber(myChat!.unreadCount) > 0)
                    Container(
                      width: 5,
                      height: 5,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: JColor.primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
              ],
            )
          ],
        ),
      ),
    );
  }
}
