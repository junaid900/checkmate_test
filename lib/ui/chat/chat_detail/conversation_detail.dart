import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/chat/chat_detail/components/message_bubble.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constraints/enum_values.dart';
import '../../../constraints/helpers/app_methods.dart';
import '../../../modals/User.dart';
import '../../../modals/conversation.dart';
import '../../../providers/chat/conversation_provider.dart';
import '../../../providers/post/create_post_provider.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  ScrollController listViewScrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  DatabaseReference chatRef = FirebaseDatabase.instance.ref().child('chats');
  User? otherUserProfile;
  int? userId;

  // String? otherUserId;
  bool isExist = false, init = false;
  bool isLoading = false;
  Conversation? conversation;
  bool initChat = false;
  User? currentUser = User();
  int msgCount = 0;
  StreamSubscription<DatabaseEvent>? chatMessagesRef = null;
  late StreamSubscription<bool> keyboardSubscription;
  @override
  void initState() {
    getPageData();
    // TODO: implement initState
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) async {
        print("view keyboard ${visible}");
        await Future.delayed(Duration(milliseconds: 700));
        if(visible){
          scrollToLast();
        }
      });
    // });

  }

  scrollToLast({fast = false}) async {
    try {
      bool _init = init;
      init = true;
      // await Future.delayed(Duration(milliseconds: 300));
      if (listViewScrollController.hasClients) {
        if (listViewScrollController.position == null) return;
        if (!_init) {
          await Future.delayed(Duration(milliseconds: 50));
          if (listViewScrollController.position != null)
            listViewScrollController
                .jumpTo(listViewScrollController.position.maxScrollExtent);
        }
        listViewScrollController.animateTo(
          listViewScrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 500),
        );
        _init = true;
      } else {
        await Future.delayed(Duration(milliseconds: 100));
        if (!_init) scrollToLast();
      }
    } catch (e) {}
    // listViewScrollController.addListener(() {
    //   // print("here");
    // });
  }

  checkChatData() async {
    // print("checkChatData");
    await Future.delayed(Duration(milliseconds: 1));
    var data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      try {
        Map routeData = data as Map;
        // print("routeData: ${routeData}");
        if (routeData['type'] != null) {
          if (routeData['type'] == 'profile') {
            if (routeData['isExist']) {
              Conversation? conv = routeData['conversation'];
              if (conv != null) {
                chat_id = conv.id.toString();
                setState(() {
                  conversation = conv;
                  chat_id = chat_id;
                  isExist = true;
                });
              }
              User otherUser = routeData['user'];
              otherUserProfile = otherUser;
              getChat();
              return;
            } else {
              User otherUser = routeData['user'];
              if (otherUser != null) {
                setState(() {
                  otherUserProfile = otherUser;
                  isExist = false;
                });
              }
              return;
            }
          } else if (routeData['type'] == 'conversation') {
            Conversation? conv = routeData['conversation'];
            User user = context.read<ProfileProvider>().profile;
            if (conv != null) {
              chat_id = conv.id.toString();
              ChatData? otherUserChat = conv.getOtherUser(user.id);
              if (otherUserChat != null) {
                otherUserProfile = conv.getOtherUser(userId)!.user;
                // otherUserId = conv.getOtherUser(userId)!.userId;
              }
              setState(() {
                chat_id = chat_id;
                isExist = true;
                conversation = conv;
              });
            }
            // UserProfile otherUser = routeData['user'];
            // User user = (await getUser())!;
            // otherUserId = conv!.getOtherUser(user.id)!.userId;
            otherUserProfile = conv!.getOtherUser(userId)!.user;
            updateChat("");
            return;
          }
        } else {}
        // getChat();
      } catch (e) {}
    }
  }

  Future getChat() async {
    print("getChat");
    try {
      User user = context.read<ProfileProvider>().profile;
      if (otherUserProfile == null) {
        if (conversation != null) {
          otherUserProfile = conversation!.getOtherUser(user.id)!.user;
        }
        return;
      }
      if (otherUserProfile!.id == null) {
        return;
      }
      List list = [user.id, otherUserProfile!.id];
      var payload = {"user_ids": jsonEncode(list)};
      var response = await JApiService()
          .postRequest(JApi.GET_CHAT + "/${user.id.toString()}", payload);
      if (response != null) {
        Conversation conversation = Conversation.fromJson(response);
        setState(() {
          isExist = true;
          chat_id = conversation.id.toString();
          this.conversation = conversation;
          ChatData? otherUserChat = conversation.getOtherUser(userId);
          if (otherUserChat != null) {
            otherUserProfile = conversation.getOtherUser(userId)!.user;
          }
        });
        // print("=======>${chat_id}");
      } else {
        showAlertDialog(
            context, "Cannot find", "Chat not found try again later",
            type: AlertType.WARNING,
            okButtonText: "Go Back",
            showCancelButton: false, onPress: () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      print(e);
      showAlertDialog(context, "Unfortunate error",
          "while creating chat an error encountered try again later",
          type: AlertType.WARNING,
          okButtonText: "Go Back",
          showCancelButton: false, onPress: () {
        Navigator.of(context).pop();
      });
      // return null;
    }
    return false;
  }

  getPageData() async {
    // context.read<ProfileProvider>().currentUser = (await getUser())!;
    currentUser = context.read<ProfileProvider>().profile;
    if (currentUser!.id != null) {
      userId = convertNumber(currentUser!.id);
    }
    checkChatData();
    // scrollToLast();
  }

  updateChat(message, {type = 'simple'}) async {
    User user = context.read<ProfileProvider>().profile;
    List list = [user.id, otherUserProfile!.id.toString()];
    // {"user_ids":"[2,11]","request_type":"simple","detail_user_id":11,"last_msg":"Hello World","unread_count":1,"my_user_id":"2","my_unread_count":0 }
    var payload;
    if (type == 'send')
      payload = {
        "user_ids": jsonEncode(list),
        "detail_user_id": otherUserProfile!.id.toString(),
        "last_msg": message,
        "unread_count": "1",
        "my_user_id": user.id.toString(),
        "my_unread_count": "0",
        "last_msg_date":
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
      };
    else
      payload = {
        "user_ids": jsonEncode(list),
        // "detail_user_id": otherUserId,
        // "last_msg": message,
        // "unread_count": 1,
        "my_user_id": user.id,
        "my_unread_count": "0",
      };
    var response = await JApiService().postRequest(
        JApi.UPDATE_CHAT + "/${user.id.toString()}/${chat_id.toString()}",
        payload);
    if (response != null) {
      Conversation conversation = Conversation.fromJson(response);
      context.read<ConversationProvider>().updateChat(conversation);
    }
  }

  Future<String> uploadAndGetUrl(XFile? file, {type = 'profile'}) async {
    if (file != null) {
      print("uploading");
      var urlResponse = '';
      urlResponse = await CreatePostProvider()
          .uploadFiles("${JVar.imagePaths.chatImages}", File(file.path));
      if (urlResponse.isEmpty) {
        return '';
      }
      return urlResponse;
    }
    showToast("cannot pick file");
    return '';
  }

  @override
  void dispose() {
    if (chatMessagesRef != null) {
      chatMessagesRef!.cancel();
    }
    if(keyboardSubscription != null){
      keyboardSubscription.cancel();
    }
    listViewScrollController.dispose();
    super.dispose();
  }

  String? chat_id;
  String date = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: IconButton(
            icon: Image.asset(
              "assets/icons/circle_back.png",
              width: 50,
              height: 50,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: otherUserProfile == null
            ? Text("Checkmate User")
            : otherUserProfile!.id == null
                ? Text("Checkmate User")
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ImageWithPlaceholder(
                            image: '${otherUserProfile!.profileImage}',
                            prefix:
                                '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${otherUserProfile!.fname}",
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              "@${otherUserProfile!.username}",
                              style: TextStyle(
                                  color: JColor.greyTextColor, fontSize: 14),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
        actions: [
          // SizedBox(
          //   width: 50,
          //   height: 50,
          //   child: IconButton(
          //       onPressed: () {},
          //       icon: Image.asset(
          //         "assets/icons/circle_dots.png",
          //         width: 50,
          //         height: 50,
          //       )),
          // )
        ],
      ),
      body: Builder(
        builder: (context) {
          if (chatMessagesRef != null) {
            chatMessagesRef!.cancel();
          }
          // if (conversation != null)
          //   chatMessagesRef = chatRef
          //       .child(conversation!.id.toString())
          //       .child('messages')
          //       .onValue
          //       .listen((event) async {
          //     print("data added");
          //     await Future.delayed(Duration(milliseconds: 600));
          //     if (listViewScrollController.position.pixels >
          //         (listViewScrollController.position.maxScrollExtent - 1000))
          //       scrollToLast();
          //     updateChat('');
          //   });

          return Container(
            width: getWidth(context),
            height: getHeight(context),
            child: Stack(
              children: [
                Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: conversation == null
                          ? Center(
                              child: Text(
                                "Start Conversation",
                                style:
                                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          : SizedBox(
                              // height: getHeight(context) - 190,
                              child: FirebaseAnimatedList(
                                controller: listViewScrollController,
                                physics: BouncingScrollPhysics(),
                                // shrinkWrap: false,

                                query: chatRef
                                    .child(conversation!.id.toString())
                                    .child('messages')
                                    .orderByChild('timestamp'),

                                itemBuilder: (context, snapshot, animation, index) {
                                  if (!init) {
                                    scrollToLast(fast: true);
                                  }
                                  // print('MK: index of chat: ${index}');
                                  Map snap = snapshot.value as Map;
                                  var isOther =
                                      snap['creater-id'] != currentUser!.id.toString();
                                  return MessageBubble(
                                      message: snap['message'] ?? '',
                                      userName: !isOther
                                          ? 'You'
                                          : '${conversation!.getOtherUser(currentUser!.id)!.user!.fname}',
                                      isOther: isOther,
                                      key: ValueKey(snap['timestamp']),
                                      url: snap['image'] ?? '',
                                      type: snap['type'] ?? '',
                                      timestamp: snap['timestamp']);
                                  // return SizeTransition(
                                  // sizeFactor: CurvedAnimation(
                                  // parent: animation, curve: Curves.easeOut),
                                  // child: MessageBubble(
                                  // message: snap['message'] ?? '',
                                  // userName: !isOther
                                  // ? 'You'
                                  //     : '${conversation.getOtherUser(currentUser!.id)!.user!.firstname}',
                                  // isOther: isOther,
                                  // key: ValueKey(snap['timestamp']),
                                  // url: snap['image'] ?? '',
                                  // type: snap['type'] ?? '',
                                  // timestamp: snap['timestamp']),
                                  // );
                                },

                                defaultChild: Center(child: CircularProgressIndicator()),
                              ),
                            ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 90,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        width: getWidth(context),
                        decoration: BoxDecoration(color: JColor.white, boxShadow: [
                          BoxShadow(color: JColor.grey.withOpacity(.2), blurRadius: 4),
                        ]),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: JColor.grey.withOpacity(.04),
                                    border:
                                    Border.all(color: JColor.grey.withOpacity(.5)),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Image.asset("assets/icons/attachment.png",
                                      width: 24,
                                      height: 24,
                                      color: JColor.grey,),
                                      onPressed: () {
                                        pickFileSheet();
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: TextField(
                                        controller: messageController,
                                        onTap: () async {
                                          print("here");
                                          if(WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                                          {
                                            await Future.delayed(Duration(seconds: 3));
                                            if (listViewScrollController.position.pixels >
                                                (listViewScrollController.position.maxScrollExtent - 800))
                                              scrollToLast();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Message",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            isLoading
                                ? SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator())
                                : FloatingActionButton(
                              elevation: 0,
                              onPressed: () async {
                                if (messageController.text.trim().isEmpty) {
                                  return;
                                }
                                if ((conversation == null)) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await getChat();
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                                if (conversation!.id == null) {
                                  await getChat();
                                }
                                if (conversation == null) {
                                  showToast("cannot find chat");
                                  return;
                                }
                                if (conversation!.id == null) {
                                  showToast("cannot find chat");
                                  return;
                                }
                                String key = await chatRef
                                    .child(conversation!.id.toString())
                                    .child('messages')
                                    .push()
                                    .key!;
                                DatabaseReference ref = await chatRef
                                    .child(conversation!.id.toString())
                                    .child('messages')
                                    .child(key);
                                print('creater-id: ${currentUser!.id}');
                                var message = messageController.text;
                                ref.set({
                                  "image": "url",
                                  "message": messageController.text,
                                  "message-id": 'message-id',
                                  "creater-id": currentUser!.id.toString(),
                                  "timestamp":
                                  DateTime.now().microsecondsSinceEpoch,
                                  'type': 'text',
                                  'from': 'app',
                                }).then((value) {
                                  print('chat added');
                                  // context
                                  //     .read<FirebaseHelper>()
                                  //     .setMessageNotification(
                                  //     userId: conversation
                                  //         .getOtherUser(currentUser!.id)!
                                  //         .userId,
                                  //     count: 1,
                                  //     message: message);
                                  updateChat(message, type: 'send');
                                  scrollToLast();
                                });

                                messageController.text = '';
                              },
                              // backgroundColor: JColor.primaryColor,
                              shape: CircleBorder(),
                              child: Center(
                                  child: Image.asset(
                                    "assets/icons/send.png",
                                    width: 22,
                                    height: 22,
                                    color: JColor.white,
                                  )),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          );
        }
      ),
    );
  }
  pickFileSheet({type = "profile"}) async {
    showModalBottomSheet(
        context: context,
        builder: (__) {
          return Container(
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    "Choose File",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.camera);
                    if(file != null){
                      setState(() {
                        isLoading = true;
                      });
                      String fileUrl = await uploadAndGetUrl(file, type: type);
                      setState(() {
                        isLoading = false;
                      });
                      if(fileUrl.isNotEmpty){
                        sendImageMessage(fileUrl);
                      }
                    }
                  },
                  title: Text("Camera"),
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.gallery);
                    if(file != null){
                      setState(() {
                        isLoading = true;
                      });
                      String fileUrl = await uploadAndGetUrl(file, type: type);
                      setState(() {
                        isLoading = false;
                      });
                      print(fileUrl);
                      if(fileUrl.isNotEmpty){
                        sendImageMessage(fileUrl);
                      }
                    }
                  },
                  title: Text("Gallery"),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }
  sendImageMessage(url) async {
    String key = await chatRef
        .child(conversation!.id.toString())
        .child('messages')
        .push()
        .key!;
    DatabaseReference ref = await chatRef
        .child(conversation!.id.toString())
        .child('messages')
        .child(key);
    ref.set({
      "image": "$url",
      "message": "",
      "message-id": '$key',
      "creater-id": currentUser!.id.toString(),
      "timestamp":
      DateTime.now().microsecondsSinceEpoch,
      'type': 'image',
      'from': 'app',
    });
  }
}
