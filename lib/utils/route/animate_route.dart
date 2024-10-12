import 'package:flutter/material.dart';

PageRouteBuilder routeOne({@required settings,@required widget,@required routeName}){
  return PageRouteBuilder(
    settings: RouteSettings(
        name: routeName, arguments: settings.arguments),
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      var begin = 0.5;
      var end = 1.0;
      var curve = Curves.fastLinearToSlowEaseIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return ScaleTransition(
        scale: animation.drive(tween),
        child: page,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return widget;
    },
  );
}