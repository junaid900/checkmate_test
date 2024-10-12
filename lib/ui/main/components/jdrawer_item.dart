import 'package:flutter/material.dart';

import '../../../constraints/jcolor.dart';

class JDrawerItem extends StatelessWidget {
  final String title;
  final String icon;
  final Function onTap;
  bool isSelected = false;
  JDrawerItem({super.key, required this.title, required this.icon, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected? JColor.primaryColor.withOpacity(.1): Colors.transparent
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon,
            width: 24,height: 24,),
            SizedBox(width: 12,),
            Text(title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500
            ),),
          ],
        ),
      ),
    );
  }
}
