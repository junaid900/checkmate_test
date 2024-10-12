import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constraints/enum_values.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../providers/user/profile_provider.dart';
import '../../utils/route/route_names.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  TextEditingController phone = TextEditingController();
  CountryCode countryCode = CountryCode(code: "US", dialCode: "+1");
  submit() async {
    var profileProvider = context.read<ProfileProvider>();
    if (phone.text.isEmpty) {
      showToast("Invalid phone number");
    }
    String _phone = countryCode.dialCode! + phone.text;
    if (!RegExp(r'^\+\d{1,3}\d{9,13}$').hasMatch(_phone)) {
      showAlertDialog(context, "Error!",
          "Invalid phone number format \nplease enter valid phone number format \neg. +1xxxxxxxxxx",
          type: AlertType.ERROR);
      return;
    }
    var payload = {"phone": _phone, "id": profileProvider.profile.id};
    showProgressDialog(context, "Please wait...");
    var response = await profileProvider.updateProfile(payload);
    hideProgressDialog(context);
    if (response) {
      // Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed(JRoutes.otpScreen);
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
                                  submit();
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
                                  'Logout Now',
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
