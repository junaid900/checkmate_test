import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool localNotifications = false;
  bool pushNotifications = false;

  getPageData() async {
    var profileProvider = context.read<ProfileProvider>();
    var user = profileProvider.profile;
    localNotifications = user.localNotifications == '1';
    pushNotifications = user.pushNotifications == '1';
    setState(() {});
  }

  submit({required type}) async {
    var profileProvider = context.read<ProfileProvider>();

    var payload = {
      "id": profileProvider.profile.id,
    };
    if (type == "local") {
      payload["local_notifications"] = localNotifications ? "1" : "0";
    } else if (type == "push") {
      payload["push_notifications"] = pushNotifications ? "1" : "0";
    }
    showProgressDialog(context, "Please wait");
    await profileProvider.updateProfile(payload);
    hideProgressDialog(context);
    var user = profileProvider.profile;
    localNotifications = user.localNotifications == '1';
    pushNotifications = user.pushNotifications == '1';
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notification Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Manage Notifications settings"),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: JColor.lighterGrey),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      "Local Notification",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )),
                    SizedBox(
                      width: 4,
                    ),
                    Switch(
                      value: localNotifications,
                      onChanged: (value) {
                        setState(() {
                          localNotifications = value;
                        });
                        submit(type: "local");
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: JColor.lighterGrey),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      "Push Notification",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )),
                    SizedBox(
                      width: 4,
                    ),
                    Switch(
                      value: pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          pushNotifications = value;
                        });
                        submit(type: "push");
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/icons/app_icon_small.png",
                width: getWidth(context),
              )
            ],
          ),
        ));
  }
}
