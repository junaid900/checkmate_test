import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/helpers/session_helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../providers/user/profile_provider.dart';
import '../../services/my_in_app_browser.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  submit({required payload}) async {
    var profileProvider = context.read<ProfileProvider>();

    var _payload = {"id": profileProvider.profile.id, ...payload};
    showProgressDialog(context, "Please wait");
    await profileProvider.updateProfile(_payload);
    hideProgressDialog(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TouchableOpacity(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/circle_blur_black.png",
                width: 35,
                height: 35,
              ),
            ],
          ),
        ),
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TouchableOpacity(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(JRoutes.notificationSettingScreen);
                },
                child: SettingItem(
                    icon: "assets/icons/notification_blue.png",
                    title: "Notifications"),
              ),
              TouchableOpacity(
                  onTap: () {
                    Navigator.of(context).pushNamed(JRoutes.editProfileScreen);
                  },
                  child: SettingItem(
                      icon: "assets/icons/user_blue.png",
                      title: "Edit Account Details")),
              TouchableOpacity(
                onTap: () {
                  Navigator.of(context).pushNamed(JRoutes.changePasswordScreen);
                },
                child: SettingItem(
                    icon: "assets/icons/key_blue.png",
                    title: "Change Password"),
              ),
              TouchableOpacity(
                onTap: () {
                  Navigator.of(context).pushNamed(JRoutes.blockedUsersScreen);
                },
                child: SettingItem(
                    icon: "assets/icons/cross_blue.png",
                    title: "Blocked Accounts"),
              ),
              TouchableOpacity(
                onTap: () {
                  final browser = MyInAppBrowser();

                  final settings = InAppBrowserClassSettings(
                      browserSettings: InAppBrowserSettings(hideUrlBar: false),
                      webViewSettings: InAppWebViewSettings(
                          javaScriptEnabled: true, isInspectable: kDebugMode));
                  browser.openUrlRequest(
                      urlRequest: URLRequest(url: WebUri("https://www.freeprivacypolicy.com/live/7665729a-0609-47ab-be66-6544c5a1829d")),
                      settings: settings);
                },
                child: SettingItem(
                    icon: "assets/icons/privacy_blue.png",
                    title: "Privacy Policy"),
              ),
              TouchableOpacity(
                  onTap: (){
                    Navigator.pushNamed(context, JRoutes.helpScreen);
                  },
                  child: SettingItem(icon: "assets/icons/info_blue.png", title: "Help")),
              // SettingItem(
              //     icon: "assets/icons/file_blue.png", title: "Notifications"),
              TouchableOpacity(
                onTap: () {
                  showAlertDialog(context, "Warning!",
                      "Are your you want to delete your account? this will delete your account completely.",
                      onPress: () async {
                    await logout();
                    await submit(payload: {
                      "is_deleted": "1",
                    });
                    Navigator.popUntil(context, (route) => false);
                    Navigator.pushNamed(context, JRoutes.welcomeAuth);
                  }, okButtonText: "Yes", showCancelButton: true);

                },
                child: SettingItem(
                    icon: "assets/icons/trash_blue.png",
                    title: "Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String icon;
  final String title;

  const SettingItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
          color: JColor.lighterGrey.withOpacity(.2),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "${icon}",
            width: 22,
            height: 22,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "${title}",
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
