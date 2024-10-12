import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '../jconfig.dart';

setSession(String? token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      JConfig.mj_session_token, token??"");
}

Future<String?> getSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    dynamic data = await prefs.getString(JConfig.mj_session_token);
    if (data == null || data.isEmpty) {
      return null;
    }
    log("success User In SESSION HELPER: $data");
    return data;
  } catch (e) {
    return null;
  }
}

Future<bool> isLogin() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? userData = await prefs.getString(JConfig.mj_session_token);
    if (userData == null) {
      return false;
    }
    if (userData == '' || userData.isEmpty) {
      return false;
    } else {
      return true;
    }
  } catch (e) {
    return false;
  }
}
logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    bool res = await prefs.remove(JConfig.mj_session_token);
    await prefs.remove("user_data");////temp
    if(res){
      return true;
    }else{
      return false;
    }
  } catch (e) {
    return false;
  }
}
