import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/enum_values.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/jcolor.dart';
import '../../services/my_in_app_browser.dart';
import '../../utils/route/route_names.dart';
import '../common/app_color_button.dart';
import '../common/app_input_field.dart';
import '../common/japp_bar.dart';
import '../common/touchable_opacity.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  CountryCode countryCode = CountryCode(code: "US", dialCode: "+1");
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isAgreeTerms = true;

  void signup() async {
    if (!isAgreeTerms) {
      showAlertDialog(context, "Error!", "Please agree terms and conditions",
          type: AlertType.ERROR);
      return;
    }
    if (name.text.trim().isEmpty) {
      showAlertDialog(context, "Error!", "Name cannot be empty",
          type: AlertType.ERROR);
    } else if (email.text.trim().isEmpty) {
      showAlertDialog(context, "Error!", "Invalid email",
          type: AlertType.ERROR);
      return;
    } else if (phone.text.trim().isEmpty) {
      showAlertDialog(context, "Error!", "Phone number cannot be empty",
          type: AlertType.ERROR);
      return;
    } else if (password.text.isEmpty) {
      showAlertDialog(context, "Error!", "Password cannot be empty",
          type: AlertType.ERROR);
    } else if (confirmPassword.text != password.text) {
      showAlertDialog(
          context, "Error!", "Password and confirm password must be same",
          type: AlertType.ERROR);
    } else {
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email.text)) {
        showAlertDialog(context, "Error!", "Invalid email format",
            type: AlertType.ERROR);
        return;
      }

      String _phone = countryCode.dialCode! + phone.text;
      if (!RegExp(r'^\+\d{1,3}\d{9,13}$').hasMatch(_phone)) {
        showAlertDialog(context, "Error!",
            "Invalid phone number format \nplease enter valid phone number format \neg. +1xxxxxxxxxx",
            type: AlertType.ERROR);
        return;
      }

      JApiService apiService = JApiService();
      showProgressDialog(context, "Please wait...");
      var signupResponse = await apiService.postRequest(
          JApi.SIGNUP,
          {
            "name": name.text,
            "email": email.text,
            "password": password.text,
            "phone_number": _phone
          });
      hideProgressDialog(context);
      if (signupResponse != null) {
        showToast("successfully signed up");
        Navigator.pushReplacementNamed(context, JRoutes.login);
      }
      // showAlertDialog(context, "error".tr(), "login_failed".tr(),
      //     type: AlertType.ERROR);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JAppBar(context,
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, JRoutes.login);
              },
              icon: Icon(Icons.arrow_back_ios))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up Now!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Login to see our new collections!",
                    style: TextStyle(),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                          controller: name, hintText: "Full Name")),
                  SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                        controller: email,
                        hintText: tr("email"),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[A-Za-z0-9@._%+,-]'))
                        ],
                      )),
                  SizedBox(
                    height: 14,
                  ),
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
                            // favorite: ['US'],
                            // locale: 'en',
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                          ),
                          Expanded(
                            child: AppInputField(
                              controller: phone,
                              hintText: "Phone",
                              inputType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'))
                              ],
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppInputField(
                              controller: password,
                              hintText: tr("password").toString(),
                              obscureText: !showPassword,
                            ),
                          ),
                          IconButton(onPressed: (){
                            setState(() {
                              showPassword = !showPassword;
                            });
                          }, icon: Icon(showPassword?Icons.remove_red_eye : Icons.remove_red_eye_outlined))
                        ],
                      )),
                  SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppInputField(
                              controller: confirmPassword,
                              hintText: "Confirm Password",
                              obscureText: !showConfirmPassword,
                            ),
                          ),
                          IconButton(onPressed: (){
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          }, icon: Icon(showConfirmPassword?Icons.remove_red_eye : Icons.remove_red_eye_outlined))
                        ],
                      )),
                  SizedBox(
                    height: 22,
                  ),
                  SizedBox(height: 30),
                  TouchableOpacity(
                    onTap: () {
                      // login();
                      signup();
                    },
                    child: SizedBox(
                      height: 50,
                      child: AppColorButton(
                        name: "Signup",
                        color: JColor.primaryColor,
                        elevation: 0,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: isAgreeTerms,
                          onChanged: (value) {
                            setState(() {
                              isAgreeTerms = value!;
                            });
                          },
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) => JColor.blackTextColor)),
                      Flexible(
                          child: RichText(
                        text: TextSpan(
                            text: "By signing up, you agree to our",
                            style: TextStyle(color: JColor.blackTextColor),
                            children: [
                              TextSpan(
                                  text: " privacy policy and user terms",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      final browser = MyInAppBrowser();

                                      final settings = InAppBrowserClassSettings(
                                          browserSettings: InAppBrowserSettings(hideUrlBar: false),
                                          webViewSettings: InAppWebViewSettings(
                                              javaScriptEnabled: true, isInspectable: kDebugMode));
                                      browser.openUrlRequest(
                                          urlRequest: URLRequest(url: WebUri("https://www.freeprivacypolicy.com/live/7665729a-0609-47ab-be66-6544c5a1829d")),
                                          settings: settings);
                                    })
                            ]),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Text(
                        "Already have account?",
                        style: TextStyle(color: JColor.greyTextColor),
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      TouchableOpacity(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, JRoutes.login);
                          },
                          child: Text(
                            "Login",
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
}
