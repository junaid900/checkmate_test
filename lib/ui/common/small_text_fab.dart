import 'package:flutter/material.dart';

import '../../constraints/jcolor.dart';

class SmallTextFAB extends StatelessWidget {
  final String toolTip;
  final String text;
  final Function? onPressed;
  SmallTextFAB({super.key, required this.toolTip, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(110)),
      child: Text(
        this.text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: JColor.primaryColor,
        ),
      ),
      tooltip: 'Change Language',
      onPressed: () {
        if(onPressed != null)
          onPressed!();
      },
    );
  }
}
