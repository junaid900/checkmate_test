import 'package:checkmate/providers/blocked_user/blocked_user_provider.dart';
import 'package:checkmate/ui/setting/blocked_users/components/blocked_user_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/jempty_layout.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  getPageData() async {
    var blockedUserProvider = context.read<BlockedUserProvider>();
    blockedUserProvider.load();
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
        title: Text("Blocked Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Consumer<BlockedUserProvider>(builder: (BuildContext context,
              BlockedUserProvider blockedUserProvider, Widget? child) {
            return blockedUserProvider.isLoading &&
                    blockedUserProvider.list.length < 1
                ? Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator()),
                  )
                : !blockedUserProvider.isLoading &&
                        blockedUserProvider.list.length < 1
                    ? Padding(
                      padding: const EdgeInsets.only(top:50.0),
                      child: JEmptyLayout(
                          height: 120,
                          width: 120,
                          text: "No User Found",
                        ),
                    )
                    : Column(
                        children: [
                          ...blockedUserProvider.list
                              .map((e) => BlockedUserItem(blockedUser: e))
                        ],
                      );
          }),
        ),
      ),
    );
  }
}
