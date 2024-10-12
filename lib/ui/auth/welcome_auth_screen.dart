import 'dart:io';

import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../constraints/enum_values.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../modals/User.dart';
import '../../providers/user/profile_provider.dart';
import '../../utils/route/route_names.dart';

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    if (googleUser != null) {
      // final GoogleSignInAuthentication? googleAuth =
      //     await googleUser.authentication;
      var payload = {
        "name": googleUser.displayName ?? '',
        "email": googleUser.email ?? '',
        "profile": googleUser.photoUrl ?? '',
        "google_id": googleUser.id ?? ''
      };
      print(payload);
      JApiService apiService = JApiService();
      showProgressDialog(context, "Logging in.....");
      var loginResponse =
          await apiService.postRequest(JApi.GOOGLE_LOGIN, payload);
      hideProgressDialog(context);
      if (loginResponse != null) {
        logInfo(loginResponse["token"]);
        if (loginResponse["token"] != null) {
          await setSession(loginResponse["token"]);
          showProgressDialog(context, "Getting User Profile...");
          var profileResponse = await apiService.getRequest(JApi.PROFILE);
          hideProgressDialog(context);
          if (profileResponse != null) {
            var profileProvider = context.read<ProfileProvider>();
            profileProvider.profile = User.fromJson(profileResponse);
            showToast("successfully_login");
            // Navigator.pushReplacementNamed(context, JRoutes.main);
            if (profileProvider.profile.isPhoneVerified != null) {
              if (profileProvider.profile.isPhoneVerified == 'No') {
                Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
                return;
              }
              Navigator.pushReplacementNamed(context, JRoutes.main);
            } else {
              Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
            }
            return;
          }
        }
        showAlertDialog(context, "Error!", "Login Failed",
            type: AlertType.ERROR);
      }
    } else {
      // showToast("Cannot login please try again");
    }

    // Create a new credential
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: getHeight(context) * .2,
            ),
            Container(
              width: getWidth(context),
              padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/app_icon_small.png",
                    height: 76,
                    width: 76,
                  ),
                  SizedBox(height: 20),
                  Text("Welcome Back, Checkmate",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    "Welcome back! Please enter your details.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    // width: getWidth(context) * .8,
                    height: 52,
                    child: TouchableOpacity(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, JRoutes.login);
                      },
                      child: AppColorButton(
                        fontSize: 18,
                        name: "Login",
                        color: JColor.primaryColor,
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    // width: getWidth(context) * .8,
                    height: 52,
                    child: TouchableOpacity(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, JRoutes.signup);
                      },
                      child: AppColorButton(
                        fontSize: 18,
                        name: "Signup",
                        color: Colors.white,
                        borderColor: JColor.lightGreyBorderColor,
                        fontColor: JColor.blackTextColor,
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: getWidth(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            endIndent: 10.0,
                            thickness: 1,
                            color: JColor.greyTextColor,
                          ),
                        ),
                        Text(
                          "Or",
                          style: TextStyle(color: JColor.greyTextColor),
                        ),
                        Expanded(
                          child: Divider(
                            indent: 10.0,
                            thickness: 1,
                            color: JColor.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    // width: getWidth(context) * .8,
                    height: 52,
                    child: TouchableOpacity(
                      onTap: () {
                        signInWithGoogle();
                      },
                      child: AppColorButton(
                        fontSize: 18,
                        name: "Continue with Google",
                        iconImage: Image.asset("assets/icons/google.png"),
                        color: Colors.white,
                        borderColor: JColor.lightGreyBorderColor,
                        fontColor: JColor.blackTextColor,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
