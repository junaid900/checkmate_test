import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/app_methods.dart';
import '../../constraints/helpers/session_helper.dart';
import '../../modals/User.dart';
import '../../providers/settings/language_provider.dart';
import '../../providers/user/profile_provider.dart';
import '../../utils/route/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  onPageLoad() async {

    if(await isLogin()){
      String? token = await getSession();
      if(token != null){
        JApiService apiService = JApiService();
        var profileResponse = await apiService.getRequest(JApi.PROFILE);
        if(profileResponse != null){
          var profileProvider = context.read<ProfileProvider>();
          profileProvider.profile = User.fromJson(profileResponse);
          if(profileProvider.profile.isPhoneVerified != null){
            if(profileProvider.profile.isPhoneVerified == 'No'){
              Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
              return;
            }
            Navigator.pushReplacementNamed(context, JRoutes.main);
          }else{
            Navigator.pushReplacementNamed(context, JRoutes.otpScreen);
          }
          // Navigator.pushReplacementNamed(context, JRoutes.main);
          return;
        }
      }
    }
    await Future.delayed(Duration(milliseconds: 1000));
    goToLogin();

  }
  @override
  void initState() {
    onPageLoad();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: JColor.primaryColor,
      body: Center(
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.asset(
              "assets/icons/app_icon_small.png",
              width: 60,
            ),
          ),
        ),
      ),
    );
  }
}
