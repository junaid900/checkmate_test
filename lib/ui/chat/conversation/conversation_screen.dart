import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/providers/chat/conversation_provider.dart';
import 'package:checkmate/providers/main/app_setting_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/jempty_layout.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../constraints/jcolor.dart';
import '../../common/placeholder_image.dart';
import 'components/conversation_item.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  getPageData() async {
    var convProvider = context.read<ConversationProvider>();
    if (convProvider.list.length < 1) {
      convProvider.reset();
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
        leading: TouchableOpacity(
          onTap: () {
            context.read<AppSettingProvider>().toggleDrawer();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/menu.png",
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
        title: Text(
          "Messages",
          style: TextStyle(
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                // Navigator.of(context).pushNamed(JRoutes.followersScreen,);
                var profileProvider = context.read<ProfileProvider>();
                var profile = profileProvider.profile;
                await Navigator.pushNamed(context, JRoutes.followersScreen,
                    arguments: {
                      "type": "followers",
                      "user_id": profile!.id,
                      "user": profile,
                      "screen": "conversation"
                    });
                var conversationProvider = context.read<ConversationProvider>();
                conversationProvider.reset(loading: false);
              },
              icon: Image.asset(
                "assets/icons/chat-add.png",
                width: 30,
                height: 30,
              ))
        ],
        titleSpacing: getWidth(context) * .22,
      ),
      body: Consumer<ConversationProvider>(builder: (key, provider, child) {
        return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: provider.refreshController,
            onLoading: () async {
              bool res = await provider.loadMoreData();
            },
            onRefresh: () async {
              bool res = await provider.reset();
              provider.refreshController.refreshCompleted();
              provider.refreshController = provider.refreshController;
            },
            footer: ClassicFooter(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: Column(children: [
                      SizedBox(
                        height: 10,
                      ),
                      /*Container(
                          width: getWidth(context),
                          // margin: EdgeInsets.symmetric(horizontal: 12),
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: JColor.searchBorderColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  // hintText: "",
                                  onChanged: (val) {},
                                  decoration: InputDecoration(
                                      hintText: "Search here...",
                                      hintStyle: TextStyle(
                                          color: JColor.greyTextColor,
                                          fontSize: 16),
                                      contentPadding: EdgeInsets.only(left: 0),
                                      border: InputBorder.none,
                                      icon: Image.asset(
                                          'assets/icons/search.png')),
                                ),
                              ),
                            ],
                          )),*/
                      SizedBox(
                        height: 16,
                      ),
                      if (provider.list.length < 1 && provider.isLoading)
                        Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()),
                        )
                      else if (provider.list.length < 1 && !provider.isLoading)
                        Container(
                            padding: EdgeInsets.only(top: 30),
                            child: JEmptyLayout(
                              text: "No Chat Found",
                              width: 120,
                              height: 120,
                            ))
                      else
                        ...provider.list
                            .map(
                              (e) => ConversationItem(
                                conversation: e,
                                reset: () {
                                  provider.reset(loading: false);
                                },
                              ),
                            )
                            .toList()
                    ]),
                  ),
                ],
              ),
            ));
      }),
    );
  }
}
