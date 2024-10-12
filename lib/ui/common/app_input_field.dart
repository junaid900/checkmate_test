import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constraints/jcolor.dart';

class AppInputField extends StatefulWidget {
  final String hintText;
  bool obscureText = false;
  final TextEditingController? controller;
  Function? onChange;
  int minLines;
  int maxLines;
  String? Function(String?)? validator;
  TextInputType inputType = TextInputType.text;
  List<TextInputFormatter>? inputFormatters;
  int? maxLength;

  AppInputField(
      {super.key,
      required this.hintText,
      this.controller,
      this.obscureText = false,
      this.onChange = null,
      this.minLines = 1,
      this.maxLines = 1,
      this.validator,
      this.inputType = TextInputType.text,
      this.maxLength = null,
      this.inputFormatters  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: (value) {
        if (widget.onChange != null) widget.onChange!(value);
      },
      validator: widget.validator,
      keyboardType: widget.inputType,
      inputFormatters: widget.inputFormatters ?? [],
      maxLength: widget.maxLength,

      decoration: InputDecoration(
        // prefix: Text("1"),
          hintText: widget.hintText,
          // hintText:"",
          hintStyle: TextStyle(
            color: JColor.greyTextColor,
          ),
          // border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: JColor.greyTextColor))),
    );
  }
}
