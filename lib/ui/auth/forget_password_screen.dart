import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/enum_values.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../providers/user/profile_provider.dart';
import '../../utils/route/route_names.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController phone = TextEditingController();
  CountryCode countryCode = CountryCode(code: "US", dialCode: "+1");
  loginByPhone() async {
    if (phone.text.isEmpty) {
      showAlertDialog(context, "Error!", "Phone Number cannot be empty",
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
              arguments: {
                "phone_number": loginResponse["phone_number"],
                "forget_password": true
              });
          return;
        }
        showAlertDialog(context, "Error", "Cannot find number",
            type: AlertType.ERROR);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Phone"),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            width: getWidth(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/icons/app_icon_small.png',
                                    width: 30,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Enter phone number to verify',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 1, 12, 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CountryCodePicker(
                                    onChanged: (value){
                                      print(value);
                                      setState(() {
                                        countryCode = value;
                                      });
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: countryCode.code,
                                    // favorite: ['US'],
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                  ),
                                  Expanded(
                                    child: AppInputField(
                                      hintText: "123456789",
                                      controller: phone,
                                      inputType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              AppColorButton(
                                name: "Verify",
                                elevation: 0,
                                onPressed: (){
                                  loginByPhone();
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (await logout()) {
                                    // context.read<CartHelper>().clearCart();
                                    // clearVendorData(context);
                                    // showToast("You are now logged out");
                                    Navigator.pushReplacementNamed(
                                        context, JRoutes.login);
                                  } else {
                                    showToast("Cannot logout right now");
                                  }
                                },
                                child: Text(
                                  'Got Back To Login',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ])),
            ]),
      ),
    );
  }
}
