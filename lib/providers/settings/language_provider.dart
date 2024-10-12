import 'package:flutter/cupertino.dart';

class LanguageProvider extends ChangeNotifier{
  String _currenLanguage = "en_US";
  List<Locale> langList = [
    Locale("en", "US"),
    Locale("ch")
  ];

  String get currenLanguage => _currenLanguage;

  set currenLanguage(String value) {
    _currenLanguage = value;
    print("changeing Language"+ value);
    notifyListeners();
  }
}