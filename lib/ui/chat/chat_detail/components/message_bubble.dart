import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.message,
    required this.userName,
    required this.isOther,
    this.key,
    required this.url,
    required this.type,
    required this.timestamp,
  });

  final Key? key;
  final String message;
  final String userName;
  final String url;
  final String type;
  final dynamic timestamp;
  final bool isOther;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isOther ? MainAxisAlignment.start : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          // width: getWidth(context) * .7,
          decoration: BoxDecoration(
            color: isOther ? JColor.secondaryColor : JColor.primaryExtraLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isOther ? Radius.circular(0) : Radius.circular(12),
              bottomRight: !isOther ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          // width: 160,
          constraints: BoxConstraints(maxWidth: getWidth(context) * .7),
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            right: 16,
            left: 16,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment:
                isOther ? CrossAxisAlignment.start : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // Text(
              //   userName,
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     color: isOther ? Colors.white : Colors.white,
              //   ),
              // ),
              if (type == 'image')
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ImageWithPlaceholder(
                    image: "${url}",
                    prefix: "${JVar.FILE_URL}${JVar.imagePaths.chatImages}/",
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (type != 'file')
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          message,
                          style: TextStyle(
                              // color: isOther ? Colors.white : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlign:
                              isOther ? TextAlign.start : TextAlign.start,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 22,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      // convertTimestampToAgo(timestamp),
                      "${timeAgo(timestamp)}",
                      // getTimeSinceUpload(timestamp),
                      style:
                          TextStyle(color: JColor.greyTextColor, fontSize: 12),
                      textAlign: isOther ? TextAlign.end : TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String timeAgo(int timestampInMicroseconds) {
    DateTime now = DateTime.now();
    DateTime dateTime =
        DateTime.fromMicrosecondsSinceEpoch(timestampInMicroseconds);

    Duration difference = now.difference(dateTime);
    try {
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${(difference.inDays / 365).floor()} years ago';
      }
    } catch (e) {
      return '';
    }
  }
}
