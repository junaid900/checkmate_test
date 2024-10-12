import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var password = TextEditingController();
  var confirmPassword = TextEditingController();
  submit() async {
    if(password.text.isEmpty){
      showToast("Password cannot be empty.");
      return;
    }
    if(password.text != confirmPassword.text){
      showToast("Both passwords must be same.");
      return;
    }
    var profileProvider = context.read<ProfileProvider>();
    showProgressDialog(context, "Updating password");
    var res = await profileProvider.updateProfile({
      "id": profileProvider.profile.id,
      "password": password.text,
    });
    hideProgressDialog(context);

    if(res){
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Change Password"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Enter your new password"),
                AppInputField(
                  hintText: "Password",
                  controller: password,
                ),
                SizedBox(height: 10,),
                AppInputField(
                  hintText: "Confirm Password",
                  controller: confirmPassword,
                ),
                SizedBox(height: 10,),
                AppColorButton(
                  color: JColor.primaryColor,
                  name: "Change",
                  onPressed: (){
                    submit();
                  },
                  elevation: 0,
                ),
              ],
            ),
          ),
        ));
  }
}
