import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constraints/jcolor.dart';
import '../../providers/settings/language_provider.dart';
import 'small_text_fab.dart';


PreferredSizeWidget JAppBar(BuildContext context, {Function? onLanguageChanged, leading = null}){
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 80,
    elevation: 0,
    leading: leading,
    title: Row(
      children: [
        Container(
          // padding: EdgeInsets.only(left: 6),
          child: Image.asset(
            "assets/icons/app_icon_small.png",
            height: 36,
          ),
        ),
      ],
    ),
    actions: [
      // Container(
      //   padding: EdgeInsets.only(right: 30),
      //   child: Consumer<LanguageProvider>(builder: (key, provider, child) {
      //     return SmallTextFAB(
      //       toolTip: "change language",
      //       text: provider.currenLanguage == "en_US" ? "EN" : "CH",
      //       onPressed: () async {
      //         print("chnaging lang");
      //         print(context.locale.toString());
      //         var languageProvider =  context.read<LanguageProvider>();
      //         if (provider.currenLanguage == "en_US") {
      //           languageProvider.currenLanguage = "zh_CN";
      //           await context.setLocale(Locale("zh", "CN"));
      //           await Get.updateLocale(Locale("zh", "CN"));
      //         } else {
      //           languageProvider.currenLanguage = "en_US";
      //           await context.setLocale(Locale("en","US"));
      //           await Get.updateLocale(Locale("en","US"));
      //         }
      //         if(onLanguageChanged!=null){
      //           onLanguageChanged();
      //         }
      //       },
      //     );
      //   }),
      // ),
    ],
    backgroundColor: Colors.white,
  );
}
// class JAppBar extends StatelessWidget {
//   Function? onLanguageChanged;
//   JAppBar({super.key, this.onLanguageChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
