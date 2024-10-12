import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/firebase/firebase_live_stream_provider.dart';
import 'package:checkmate/providers/live_stream/live_stream_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constraints/helpers/helper.dart';
import '../common/app_input_field.dart';

class CreateLiveStreamScreen extends StatefulWidget {
  const CreateLiveStreamScreen({super.key});

  @override
  State<CreateLiveStreamScreen> createState() => _CreateLiveStreamScreenState();
}

class _CreateLiveStreamScreenState extends State<CreateLiveStreamScreen> {
  TextEditingController description = TextEditingController();
  TextEditingController title = TextEditingController();
  bool isLoading = false;

  submit() async {
    if (title.text.isEmpty) {
      showToast("title cannot be empty");
      return;
    }
    if (description.text.isEmpty) {
      showToast("description cannot be empty");
      return;
    }
    var profileProvider = context.read<ProfileProvider>();
    var user = profileProvider.profile;
    if (user.id == null) {
      showToast("cannot get user detail");
      return;
    }
    var liveStreamProvider = context.read<LiveStreamProvider>();
    showProgressDialog(context, "Creating livestream...");
    var res = await liveStreamProvider.createLiveStream({
      "title": title.text,
      "description": description.text,
      "channel_name": user.username ?? generateRandomId(),
    });
    hideProgressDialog(context);
    if (res != null) {
      var firebaseLiveStreamProvider = context.read<FirebaseLiveStreamProvider>();
      showProgressDialog(context, "Starting livestream...");
      var start = await firebaseLiveStreamProvider.startStream(res);
      Navigator.of(context).pop();

      var data = {
        "stream": res,
      };
      Navigator.pushReplacementNamed(context, JRoutes.liveStreamScreen, arguments: data);
    } else {
      showAlertDialog(context, "Error!",
          "Error while creating live stream entry please try again.",
          type: AlertType.INFO);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Stream"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Channel name"),
                  Consumer<ProfileProvider>(builder: (key, provider, child) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: JColor.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${provider.profile.username}",
                        style: TextStyle(color: JColor.white),
                      ),
                    );
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stream Title"),
                      AppInputField(
                        controller: title,
                        hintText: "Enter Stream Title",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stream Description"),
                      AppInputField(
                        controller: description,
                        hintText: "Details for your live stream",
                        minLines: 3,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TouchableOpacity(
              onTap: () {
                submit();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppColorButton(
                  color: JColor.accentColor,
                  elevation: 0,
                  onPressed: null,
                  name: "Go Live",
                  isDisable: isLoading,
                  isLoading: isLoading,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
