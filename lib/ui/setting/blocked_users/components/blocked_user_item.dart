import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/blocked_user.dart';
import 'package:checkmate/providers/blocked_user/blocked_user_provider.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedUserItem extends StatelessWidget {
  final BlockedUser blockedUser;

  const BlockedUserItem({super.key, required this.blockedUser});

  @override
  Widget build(BuildContext context) {
    if(blockedUser.user == null){
      return SizedBox();
    }
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${blockedUser.user!.fname}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${blockedUser.user!.username}",
                    style: TextStyle(
                        fontSize: 14,
                        color: JColor.greyTextColor,
                        fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 6,),
                  TouchableOpacity(
                    onTap: () async {
                      var provider = context.read<BlockedUserProvider>();
                      showProgressDialog(context, "Unblocking...");
                      await provider.block(
                          userId: blockedUser.blockedUserId, type: 'unblock');
                      await provider.load();
                      hideProgressDialog(context);

                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text("Unblock",
                        style: TextStyle(
                          color: JColor.white
                        ),)),
                  )
                ],
              )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: ImageWithPlaceholder(
                    prefix: '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                    image: blockedUser.user!.profileImage,
                    width: 80,
                    height: 80,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
