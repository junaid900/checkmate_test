import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constraints/jcolor.dart';
import '../../common/placeholder_image.dart';

class StoryStatusItem extends StatefulWidget {
  final String image;
  bool isLive = true;
  String name;
  StoryStatusItem({super.key, required this.image, this.isLive = true, required this.name});

  @override
  State<StoryStatusItem> createState() => _StoryStatusItemState();
}

class _StoryStatusItemState extends State<StoryStatusItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 68,
                height: 68,
                padding: EdgeInsets.all(2),
                // margin: EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: JColor.primaryColor, width: 2.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: ImageWithPlaceholder(
                    prefix: "",
                    image: "${widget.image}",
                    height: 65,
                    width: 65,
                  ),
                ),
              ),
              if (widget.isLive)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  // margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: JColor.primaryColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    "Live",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: JColor.white),
                  ),
                )
            ],
          ),
        ),
        // SizedBox(height: 2,),
        // if (!widget.isLive)
        Center(
            child: Container(
              width: 60,
              margin: EdgeInsets.only(top: 1),
              child: Text(
                "${widget.name}",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ))
      ],
    );
  }
}
