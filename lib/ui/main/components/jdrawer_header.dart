import 'package:flutter/material.dart';

class JDrawerHeader extends StatefulWidget {
  final Function onCloseHandle;

  JDrawerHeader({super.key, required this.onCloseHandle});

  @override
  State<JDrawerHeader> createState() => _JDrawerHeaderState();
}

class _JDrawerHeaderState extends State<JDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
          child: Row(
            children: [
              Image.asset(
                "assets/icons/app_icon_small.png",
                height: 70,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
              onPressed: () {
                widget.onCloseHandle();
              },
              icon: Icon(
                Icons.close,
                size: 34,
              )),
        )
      ],
    );
  }
}
