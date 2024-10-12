import 'dart:io';

import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:checkmate/ui/common/japp_bar.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/enum_values.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../constraints/j_var.dart';
import '../../constraints/jcolor.dart';
import '../../modals/User.dart';
import '../../providers/user/profile_provider.dart';
import '../../utils/route/route_names.dart';
import '../common/app_color_button.dart';
import '../common/shadow_input_field.dart';
import '../common/touchable_opacity.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool isEmail = true;
  CountryCode countryCode = CountryCode(code: "US", dialCode: "+1");
  bool rememberMe = true;

  void login() async {
    if (email.text.isEmpty) {
      showAlertDialog(context, "Error!".tr(), "Email cannot be empty",
          type: AlertType.ERROR);
      return;
    } else if (password.text.isEmpty) {
      showAlertDialog(context, "Error!", "Password cannot be empty",
          type: AlertType.ERROR);
    } else {
      JApiService apiService = JApiService();
      showProgressDialog(context, "Please wait...");
      var loginResponse = await apiService.postRequest(
          JApi.LOGIN, {"email": email.text, "password": password.text});
      hideProgressDialog(context);
      print("===>");
      logInfo(loginResponse);
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
            showToast("Successfully LoggedIn");
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
        showAlertDialog(context, "Error", "Cannot login please try again".tr(),
            type: AlertType.ERROR);
      } else {}
    }
  }

  loginByPhone() async {
    if (phone.text.isEmpty) {
      showAlertDialog(context, "error".tr(), "Phone Number cannot be empty",
          type: AlertType.ERROR);
      return;
    } else {
      JApiService apiService = JApiService();
      showProgressDialog(context, "Please wait...");
      String _phone = countryCode.dialCode! + phone.text;
      if (!RegExp(r'^\+\d{1,3}\d{9,13}$').hasMatch(_phone)) {
        showAlertDialog(context, "Error!",
            "Invalid phone number format \nplease enter valid phone number format \neg. +1xxxxxxxxxx",
            type: AlertType.ERROR);
        return;
      }
      var loginResponse = await apiService
          .postRequest(JApi.CHECK_PHONE_NUMBER, {"phone_number": _phone});
      hideProgressDialog(context);
      logInfo(loginResponse);
      if (loginResponse != null) {
        if (loginResponse["phone_number"] != null) {
          Navigator.pushReplacementNamed(context, JRoutes.otpScreen,
              arguments: {"phone_number": loginResponse["phone_number"]});
          return;
        }
        showAlertDialog(context, "error".tr(), "login_failed".tr(),
            type: AlertType.ERROR);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Login to see our new collections!",
                    style: TextStyle(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    // width: getWidth(context)*.8,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TouchableOpacity(
                            onTap: () {
                              setState(() {
                                isEmail = true;
                              });
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 6, bottom: 6, left: 6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              decoration: isEmail
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: JColor.brightWhite,
                                    )
                                  : BoxDecoration(),
                              child: Center(
                                  child: Text(
                                "Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isEmail
                                        ? JColor.blackTextColor
                                        : JColor.greyTextColor),
                              )),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TouchableOpacity(
                            onTap: () {
                              setState(() {
                                isEmail = false;
                              });
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 6, bottom: 6, right: 6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              decoration: !isEmail
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: JColor.brightWhite,
                                    )
                                  : BoxDecoration(),
                              child: Center(
                                  child: Text(
                                "Phone",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: !isEmail
                                        ? JColor.blackTextColor
                                        : JColor.greyTextColor),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  (isEmail)
                      ? Column(
                          children: [
                            SizedBox(
                                width: getWidth(context),
                                child: AppInputField(
                                    controller: email, hintText: tr("email"))),
                            SizedBox(
                              height: 18,
                            ),
                            SizedBox(
                                width: getWidth(context),
                                child: AppInputField(
                                  controller: password,
                                  hintText: tr("password").toString(),
                                  obscureText: true,
                                )),
                            SizedBox(
                              height: 22,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (val) {
                                        setState(() {
                                          rememberMe = val!;
                                        });
                                      },
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.black),
                                    ),
                                    Text("Remember me"),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                        context, JRoutes.forgetPasswordScreen);
                                  },
                                  child: Text(
                                    "Forget Password?",
                                    style: TextStyle(
                                      // decoration: TextDecoration.underline,
                                      color: JColor.greyTextColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Enter Phone"),
                            SizedBox(
                                width: getWidth(context),
                                child: Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (value) {
                                        print(value);
                                        setState(() {
                                          countryCode = value;
                                        });
                                      },
                                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                      initialSelection: countryCode.code,

                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                    ),
                                    Expanded(
                                      child: AppInputField(
                                        controller: phone,
                                        hintText: "123456890",
                                        inputType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                  SizedBox(height: 30),
                  TouchableOpacity(
                    onTap: () {
                      if (isEmail) {
                        login();
                      } else {
                        loginByPhone();
                      }
                      // Navigator.pushReplacementNamed(context, JRoutes.main);
                    },
                    child: SizedBox(
                      height: 50,
                      child: AppColorButton(
                        name: "Login",
                        color: JColor.primaryColor,
                        elevation: 0,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                  SizedBox(height: 20),
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Text(
                        "Dont’t have an account?",
                        style: TextStyle(color: JColor.greyTextColor),
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      TouchableOpacity(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, JRoutes.signup);
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    if (googleUser != null) {
      // final GoogleSignInAuthentication? googleAuth =
      //     await googleUser.authentication;
      var payload = {
        "name": googleUser.displayName ?? '',
        "email": googleUser.email,
        "profile": googleUser.photoUrl ?? '',
        "google_id": googleUser.id.toString()
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
            showToast("Successfully Login");
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
        showAlertDialog(
            context, "Error!", "Cannot login please try again later".tr(),
            type: AlertType.ERROR);
      }
    } else {
      // showToast("Cannot login please try again");
    }
  }
}
