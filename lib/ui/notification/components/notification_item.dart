import 'package:checkmate/modals/cmnotification.dart';
import 'package:flutter/material.dart';

import '../../../constraints/jcolor.dart';
import '../../common/placeholder_image.dart';

class NotificationItem extends StatelessWidget {
  final CMNotification notification;
  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageWithPlaceholder(
                image:
                '${notification.image}',
                prefix: "",
                width: 60,
                height: 60,
              ),
            ),
            SizedBox(width: 8,),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: "${notification.title}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: JColor.black,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                                text: " ${notification.description}.",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal
                                )
                            )
                          ]
                      )),
                  Text("${notification.timeAgo}",
                    style: TextStyle(
                        color: JColor.greyTextColor
                    ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
