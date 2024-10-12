import 'package:flutter/material.dart';

import '../../../constraints/jcolor.dart';
import '../../common/touchable_opacity.dart';

class HomeFilterItem extends StatefulWidget {
  final String title;
  final Function onTap;
  bool isAll = false;

  HomeFilterItem(
      {super.key,
      required this.title,
      required this.onTap,
      this.isAll = false});

  @override
  State<HomeFilterItem> createState() => _HomeFilterItemState();
}

class _HomeFilterItemState extends State<HomeFilterItem> {
  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
        onTap: () {
          widget.onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: JColor.black),
              color: widget.isAll ? JColor.black : JColor.white),
          child: Center(
              child: Text(
            widget.title,
            style: TextStyle(
                fontSize: 14,
                color: widget.isAll ? JColor.white : JColor.blackTextColor),
          )),
        ));
  }
}
