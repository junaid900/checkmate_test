import 'dart:io';

import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/services/notifications_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'constraints/jcolor.dart';
import 'providers/jproviders.dart';
import 'utils/route/routes.dart';

// New changes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  Future<FirebaseApp> firebaseApp = Firebase.initializeApp(
    options: Platform.isIOS
        ? JVar.firebaseIOSOptions
        : JVar.firebaseAndroidOptions,
  );
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      supportedLocales: [Locale('en', "US"), Locale('zh', 'CN')],
      path: 'assets/lang',
      fallbackLocale: Locale('en', "US"),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [...providers],
      child: GetMaterialApp(
        title: 'ESS Management',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          ...context.localizationDelegates,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: JColor.primaryColor,
            secondary: JColor.secondaryColor
          ),
          shadowColor: JColor.secondaryColor,
          primaryColor: JColor.primaryColor,
          fontFamily: "Poppins",
          datePickerTheme: DatePickerThemeData(
            // dayBackgroundColor: MaterialStateProperty<Color>() => JColor.primaryColor,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: JColor.primaryColor,
          ),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.resolveWith((states) { return TextStyle(
                      color: JColor.primaryColor,
                );}),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return JColor.white;
                }),
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  // if (states.contains(MaterialState.pressed)) {
                  //   return JColor.primaryColor.withOpacity(.8);
                  // }
                  return JColor.primaryColor.withOpacity(.2);
                }),
                shadowColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                  return JColor.primaryColor.withOpacity(.8);
                  }
                  return JColor.primaryColor.withOpacity(.2);
                }),

              )
          ),
          textTheme: TextTheme(
              bodyText2: TextStyle(
                fontWeight: FontWeight.w500,
              )),
          // primarySwatch: JColor.primaryColor.withOpacity(.5) as MaterialColor,

          // backgroundColor: backgroundGreyShade,
        ),
        // home: CleaningAndSenitizationForm(),
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
