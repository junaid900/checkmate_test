import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../enum_values.dart';
import '../j_var.dart';
import '../jcolor.dart';

double getWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width;
}
double getHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).height;
}

int convertNumber(num) {
  try {
    if (num is int) {
      return num;
    }
    if (num != null) {
      int? a = int.tryParse(num);
      return a == null ? 0 : a;
    } else {
      return 0;
    }
  } catch (e) {
    print(e);
    return 0;
  }
}
double convertDouble(num) {
  try {
    if (num != null) {
      double? a = double.tryParse(num);
      return a == null ? 0 : a;
    } else {
      return 0;
    }
  } catch (e) {
    print(e);
    return 0;
  }
}
DateTime? convertDate(String? _dateTime){
  try{
    if(_dateTime == null){
      return null;
    }
    DateTime? dateTime = DateTime.parse(_dateTime);
  }catch(e){
    return null;
  }
  return null;
}
bool empty(String? data) {
  try {
    if (data == null) {
      return true;
    } else if (data == "null" || data.length < 1 || data == '') {
      return true;
    }
    return false;
  } catch (e) {
    print(e);
    return true;
  }
}

void showToast(String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0);
}

showProgressDialog(context, message, {isDismissable = false}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissable,
    builder: (buildContext) => AlertDialog(
      content: Container(
        child: Row(
          // direction: Axis.horizontal,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Image.asset(
                    JVar.appLogoIcon,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(child: Text("${message}")),
          ],
        ),
      ),
    ),
  );
}

showAlertDialog(context, title, message,
    {type = AlertType.INFO,
      okButtonText = 'Ok',
      onPress = null,
      showCancelButton = true,
      dismissible = true}) {
  String icon;

  switch (type) {
    case AlertType.INFO:
      icon = JVar.infoIcon;
      break;
    case AlertType.SUCCESS:
      icon = JVar.successIcon;
      break;
    case AlertType.WARNING:
      icon = JVar.warningIcon;
      break;
    case AlertType.ERROR:
      icon = JVar.errorIcon;
      break;
    default:
      icon = JVar.infoIcon;
  }

  showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: dismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) {
        var begin = 0.5;
        var end = 1.0;
        var curve = Curves.bounceOut;
        if (anim.status == AnimationStatus.reverse) {
          curve = Curves.fastLinearToSlowEaseIn;
        }
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return ScaleTransition(
          scale: anim.drive(tween),
          child: child,
        );
      },
      pageBuilder: (BuildContext alertContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(dismissible);
          },
          child: Center(
            child: Container(
              width: getDeviceType() == DeviceType.MOBILE? getWidth(context): getWidth(context) *.6,
              margin: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 4,
                          ),
                          Center(
                            child: Image.asset(
                              icon,
                              width: 50,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${title}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Text("$message"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (showCancelButton)
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(alertContext).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                              if (onPress != null)
                                TextButton(
                                  onPressed: onPress,
                                  child: Text("$okButtonText"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
hideProgressDialog(context) {
  Navigator.of(context).pop();
}
showSnakBar({required title, required message, onTab = null}) async {
  await Future.delayed(Duration(milliseconds: 1500));
  Get.snackbar(title, message,
      colorText: Colors.white,
      duration: Duration(milliseconds: 2000),
      backgroundColor: JColor.primaryColor.withOpacity(.8), onTap: (a) {
        print("on Notification tab");
        onTab();
      });
}
String trString(String key){
  return key.tr;
}

DeviceType getDeviceType() {
  final double width = Get.width;
  if (width <= 600) {
    return DeviceType.MOBILE;
  } else if (width <= 900) {
    return DeviceType.TABLET;
  } else {
    return DeviceType.LAPTOP;
  }
}

generateRandomId(){
  return DateTime
      .now()
      .microsecondsSinceEpoch
      .toString() +
      Random().toString();

}


void logInfo(msg) {
  debugPrint('\x1B[34m$msg\x1B[0m');
}

// Green text
void logSuccess(msg) {
  debugPrint('\x1B[32m$msg\x1B[0m');
}

// Yellow text
void logWarning(msg) {
  debugPrint('\x1B[33m$msg\x1B[0m');
}

// Red text
void logError(msg) {
  debugPrint('\x1B[31m$msg\x1B[0m');
}

