import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/cmsupport.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupportItem extends StatelessWidget {
  final CMSupport support;
  const SupportItem({super.key, required this.support});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${support.title}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),),
                  Text("${support.description}",
                    style: TextStyle(
                        fontSize: 14,
                        color: JColor.greyTextColor,
                        fontWeight: FontWeight.normal
                    ),),
                ],
              )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: JColor.primaryColor
                ),
                child: Text(
                 "${support.status}",
                 style: TextStyle(
                   color: JColor.white,
                 ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
