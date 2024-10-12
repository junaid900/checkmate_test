import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

import '../../constraints/helpers/helper.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../modals/User.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  User? user;

  int enteredPin = 0;
  String? _verId;
  int? _resendToken;
  bool initialized = false;
  bool returnToLogin = true;
  bool isLoginByPhone = false;
  bool forgetPassword = false;


  getPageData() async {
    var data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      Map dataMap = data as Map;
      if (dataMap["phone_number"] != null) {
        if(dataMap["forget_password"] != null){
          if(dataMap["forget_password"] as bool == true){
            forgetPassword = true;
          }
        }
        isLoginByPhone = true;
        setState(() {
          user = new User(phoneNumber: dataMap["phone_number"]);
        });
        sendOtp();
        return;
      }
    }
    var userProfile = context.read<ProfileProvider>();
    var userData = userProfile.profile;
    // if (routeData != null) {
    user = userData;
    if (user!.phoneNumber == null) {
      Navigator.pushReplacementNamed(context, JRoutes.phoneNumberScreen);
      return;
    }
    if (user!.phoneNumber!.isEmpty) {
      Navigator.pushReplacementNamed(context, JRoutes.phoneNumberScreen);
      return;
    }
    // returnToLogin = routeData['returnToLogin'];
    print('userData: ${user!.toJson()}');
    if (!initialized) {
      sendOtp();
      initialized = true;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _verificationCompleted(auth.PhoneAuthCredential credential) {
    print('authCredentials in Verification Completed: $credential');
  }

  _verificationFailed(auth.FirebaseAuthException e) {
    print('Error message: ${e.message}');
    print('Error code: ${e.code}');
    print('Stack trace: ${e.stackTrace}');
    showToast("Cannot send otp please try again later");
    if(e.code == 'internal-error'){
      showAlertDialog(context, "Error", "An Internal Error occur please try again later", type: AlertType.ERROR);
    }else{
      showAlertDialog(context, "Error", e.message, type: AlertType.ERROR);
    }
  }

  _codeSent(String verificationId, int? resendToken) {
    _verId = verificationId;
    _resendToken = resendToken;
    showToast("message sent successfully");
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    print('verificationId in timeout: $verificationId');
  }

  sendOtp() async {
    // print(user!.phoneNumber);
    // auth.FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: false);
    showProgressDialog(context, "Sending Otp...", isDismissable: true);
    await auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '${user!.phoneNumber}',
      // user!.phoneNumber!,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      forceResendingToken: _resendToken,
      timeout: Duration(seconds: 120),
    ).onError((error, stackTrace) => {
      showAlertDialog(context, "Error", "Cannot get otp please try again later", type: AlertType.ERROR)
    }).then((value) {
      hideProgressDialog(context);
      print("then result otp");
    });
  }

  verifyOtp() async {
    print('myTag in verifyOtp');
    final auth.PhoneAuthCredential credential =
        auth.PhoneAuthProvider.credential(
            verificationId: _verId ?? '', smsCode: _pinPutController.text);

    try {
      showProgressDialog(context, "Verifying One Time Passscode",
          isDismissable: false);
      //show progress dialogue
      await auth.FirebaseAuth.instance.signInWithCredential(credential).then(
          (auth.UserCredential verifiedUser) async {
        hideProgressDialog(context);
        try {
          if (verifiedUser != null) {
            if (isLoginByPhone) {
              loginByPhone();
            } else {
              updateProfile();
            }
          }
        } catch (e) {}
      }, onError: (error) {
        print(error);
        hideProgressDialog(context);
      });
    } catch (e) {
      hideProgressDialog(context);
    }
  }

  loginByPhone() async {
    JApiService apiService = JApiService();
    showProgressDialog(context, "Please wait...");
    var loginResponse = await apiService
        .postRequest(JApi.LOGIN_BY_PHONE, {"phone_number": user!.phoneNumber});
    hideProgressDialog(context);
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
          showToast("Successfully Login");
          if (profileProvider.profile.isPhoneVerified != null) {
            if (profileProvider.profile.isPhoneVerified == 'No') {
              Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
              return;
            }
            if(this.forgetPassword){
              var res = await Navigator.pushNamed(context, JRoutes.changePasswordScreen);
              Navigator.pushReplacementNamed(context, JRoutes.main);
            }else{
              Navigator.pushReplacementNamed(context, JRoutes.main);
            }
          } else {
            Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
          }
          return;
        }
      }
    }
  }

  updateProfile() async {
    JApiService apiService = JApiService();
    dynamic paylaod = {
      "is_phone_verified": "Yes",
      "id": user!.id,
    };
    print('myTag in before calling api, payload: $paylaod');
    showProgressDialog(context, "Updating....");
    dynamic response =
        await apiService.postRequest(JApi.UPDATE_PROFILE, paylaod);
    print('response in OTP screen: ${response}');
    print(response['username'].toString());

    hideProgressDialog(context);

    if (response != null) {
      try {
        print('response status: ' + response['status'].toString());
        User _user = User.fromJson(response);
        if (_user.id != null) {
          context.read<ProfileProvider>().profile = _user;
          Navigator.pushReplacementNamed(context, JRoutes.main);
          return;
        } else {
          Navigator.pushReplacementNamed(context, JRoutes.login);
          return;
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardAppeared = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 60,
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
                              'Verify One Time Passcode',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Sent to ${user?.phoneNumber}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      buildPinPut(
                          // controller: _pinPutController,
                          // label: 'ENTER OTP',
                          // icon: Icons.verified_outlined,
                          ),
                      SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await verifyOtp();

                          /////
                        },
                        child: SizedBox(
                          width: 260,
                          height: 35,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  // radius: 5,

                                  stops: [0.5, 0.99],
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Colors.lightGreen,
                                  ],
                                )),
                            child: Center(
                              child: Text(
                                'Verify',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t get OTP?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: () async {
                              print("resending");
                              await sendOtp();
                            },
                            child: Text(
                              'Resend',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: JColor.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      isLoginByPhone?
                      TextButton(
                        onPressed: () async {
                          if (await logout()) {
                            // context.read<CartHelper>().clearCart();
                            // clearVendorData(context);
                            // showToast("You are now logged out");
                            Navigator.pushReplacementNamed(
                                context, JRoutes.login);
                          }
                        },
                        child: Text(
                          'Go To Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            // color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ):
                      Column(
                        children: [
                          Text(
                            'Or',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 20,
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
                                decoration: TextDecoration.underline,
                                // color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // if (await logout()) {
                              // context.read<CartHelper>().clearCart();
                              // clearVendorData(context);
                              // showToast("You are now logged out");
                              Navigator.pushReplacementNamed(
                                  context, JRoutes.phoneNumberScreen);
                              // } else {
                              //   showToast("Cannot logout right now");
                              // }
                            },
                            child: Text(
                              'Change Number',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                // color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: -35,
            top: -85,
            child: CircleAvatar(
              radius: 60,
              // backgroundColor: Theme.of(context).accentColor,
            ),
          ),
          Positioned(
            left: -95,
            top: -30,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          if (!isKeyboardAppeared)
            Positioned(
              right: -30,
              bottom: -105,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: JColor.accentColor,
              ),
            ),
          if (!isKeyboardAppeared)
            Positioned(
              right: -95,
              bottom: -65,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPinPut() {
    final defaultPinTheme = PinTheme(
      // margin: EdgeInsets.all(5),
      width: 40,
      height: 43,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(200, 200, 200, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      controller: _pinPutController,
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: false),
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      showCursor: true,
      onCompleted: (pin) {
        print(pin);
      },
    );
  }
}
