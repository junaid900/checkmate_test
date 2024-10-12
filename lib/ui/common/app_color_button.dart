import 'package:checkmate/constraints/jcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constraints/helpers/helper.dart';

class AppColorButton extends StatefulWidget {
  String? name;
  final onPressed;
  bool isDisable = false;
  Color color = Colors.blue;
  bool isLoading = false;
  double elevation = 10;
  double fontSize = 16;
  Color fontColor = Colors.white;
  Color borderColor = Colors.transparent;
  Widget? iconImage;
  AppColorButton(
      {this.onPressed,
      this.name,
      this.color = Colors.blue,
      this.isDisable = false,
      this.isLoading = false,
      this.elevation = 10,
      this.fontSize = 16,
      this.borderColor = Colors.transparent,
      this.fontColor = Colors.white,
      this.iconImage});

  @override
  _AppColorButtonState createState() => _AppColorButtonState();
}

class _AppColorButtonState extends State<AppColorButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: !widget.isDisable
            ? widget.onPressed
            : () {
                print("In Button" + widget.isLoading.toString());
                print("In Button" + widget.isDisable.toString());
              },
        style: ButtonStyle(
            elevation:
                MaterialStateProperty.resolveWith((states) => widget.elevation),
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
            padding:
                MaterialStateProperty.all(EdgeInsets.fromLTRB(0, 0, 0, 0))),
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            width: getWidth(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(widget.iconImage != null)
                  Row(
                    children: [
                      widget.iconImage!,
                      SizedBox(width: 10,),
                    ],
                  ),
                Flexible(
                  child: Text(
                    widget.name!,
                    style: TextStyle(
                        color: widget.fontColor, fontSize: widget.fontSize),
                  ),
                ),
                SizedBox(
                  width: widget.isLoading ? 5 : 0,
                ),
                widget.isLoading
                    ? SizedBox(
                        height: 20.0,
                        width: 20,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 2.0))
                    : SizedBox(),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.borderColor),
                // boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                color: widget.color)));
  }
}
