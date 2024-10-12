import 'package:flutter/material.dart';

class AppSettingProvider extends ChangeNotifier{
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  set scaffoldKey(GlobalKey<ScaffoldState> value) {
    _scaffoldKey = value;
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
    notifyListeners();
  }
}