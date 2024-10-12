import 'package:flutter/material.dart';

import '../../constraints/helpers/helper.dart';
import '../../constraints/jcolor.dart';

class CustomHeaderLayout extends StatelessWidget {
  const CustomHeaderLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 260,
            height: 140,
            padding: EdgeInsets.only(top: 20,bottom: 10, right: 10),
            decoration: BoxDecoration(
                color: JColor.primaryColor
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset("assets/icons/app_icon_small.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
