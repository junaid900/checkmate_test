import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constraints/jcolor.dart';
import 'touchable_opacity.dart';

class JBackButton extends StatelessWidget {
  const JBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  TouchableOpacity(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: BoxDecoration(
          color: JColor.greyTextColor.withOpacity(.2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 30),
            SizedBox(width: 4,),
            Text(tr("go_back"), style: TextStyle(
              fontSize: 22,
              // fontWeight: FontWeight.bold
            ),),
          ],
        ),),
    );
  }
}
