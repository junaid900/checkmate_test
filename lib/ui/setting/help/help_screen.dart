import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/support/support_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:checkmate/ui/setting/help/components/support_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/jempty_layout.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  var title = TextEditingController();
  var desc = TextEditingController();

  submit() async {
    if (title.text.isEmpty) {
      showToast("Title cannot be empty");
      return;
    }
    if (desc.text.isEmpty) {
      showToast("Description cannot be empty");
      return;
    }
    showProgressDialog(context, "Please wait");
    var supportProvider = context.read<SupportProvider>();
    var res =
        await supportProvider.add(title: title.text, description: desc.text);
    hideProgressDialog(context);
    if (res != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Center"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Consumer<SupportProvider>(builder: (BuildContext context,
              SupportProvider supportProvider, Widget? child) {
            return Column(
              children: [
                Text(
                  "Enter your query details. that you want to send to support.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                AppInputField(
                  hintText: "Title",
                  controller: title,
                ),
                SizedBox(
                  height: 10,
                ),
                AppInputField(
                  hintText: "Description",
                  controller: desc,
                  minLines: 3,
                  maxLines: 3,
                ),
                SizedBox(
                  height: 30,
                ),
                AppColorButton(
                  name: "Submit",
                  color: JColor.primaryColor,
                  elevation: 0,
                  onPressed: () {
                    submit();
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                supportProvider.isLoading && supportProvider.list.length < 1
                    ? Center(
                        child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator()),
                      )
                    : !supportProvider.isLoading &&
                            supportProvider.list.length < 1
                        ? JEmptyLayout(
                            height: 120,
                            width: 120,
                            text: "No Case Found",
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My Queries Status",
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ...supportProvider.list.map((e) {
                                return SupportItem(support: e);
                              })
                            ],
                          ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void getPageData() {
    var supportProvider = context.read<SupportProvider>();
    supportProvider.load();
  }
}
