import 'package:flutter/material.dart';

class JEmptyLayout extends StatelessWidget {
  double height = 80;
  double width = 80;
  String text = "";
  JEmptyLayout({super.key, this.height=80, this.width = 80, this.text=""});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/empty.gif",
          width: width,height: height,),
          Text(text)
        ],
      ),
    );
  }
}
