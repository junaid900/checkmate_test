import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constraints/helpers/helper.dart';
import '../../constraints/jcolor.dart';

Widget appBarTitleShimmer(){
  return Shimmer.fromColors(
    baseColor: JColor.greyTextColor,
    highlightColor: JColor.white,
    child: Container(
      width: 150,
      height: 20,
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6)
      ),
    ),
  );
}
Widget followerItemShimmer() {
  return Shimmer.fromColors(
    baseColor: JColor.greyTextColor,
    highlightColor: JColor.white,
    child: Container(
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
                      image: '',
                      prefix:
                      "",
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
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(3)),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(8)),
          )
        ],
      ),
    ),
  );
}
Widget postItemShimmer(context){
  return Shimmer.fromColors(
    baseColor: JColor.greyTextColor,
    highlightColor: JColor.white,
    child: Stack(
      children: [
        Container(
          width: getWidth(context),
          height: getWidth(context),
          color: Colors.red.withOpacity(.4),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                JColor.blackTextColor.withOpacity(.7),
                Colors.transparent
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: ImageWithPlaceholder(
                    image: "",
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
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    SizedBox(height: 4,),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ],
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Image.asset(
                  "assets/icons/dots_menu.png",
                  height: 20,
                  width: 20,
                ),
              ),

              // Icon(Icons)
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            width: getWidth(context),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  JColor.blackTextColor.withOpacity(.7),
                  Colors.transparent
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6)),
                ),
                SizedBox(height: 4,),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/star.png",
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 4,
                      height: 4,
                    ),
                    Text(
                      "5.0",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                SizedBox(height: 4,),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6)),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}