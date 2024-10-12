
import 'User.dart';

class Conversation {
  int? id;
  String? lastMsg;
  String? lastMsgDate;
  String? status;
  String? type;
  String? createdAt;
  String? updatedAt;
  String? timeAgo;
  List<ChatData>? chatData;

  Conversation(
      {this.id,
        this.lastMsg,
        this.lastMsgDate,
        this.status,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.timeAgo,
        this.chatData});

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastMsg = json['last_msg'];
    lastMsgDate = json['last_msg_date'];
    status = json['status'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    timeAgo = json['time_ago'];
    if (json['chat_data'] != null) {
      chatData = <ChatData>[];
      json['chat_data'].forEach((v) {
        chatData!.add(new ChatData.fromJson(v));
      });
    }
  }
  ChatData? getOtherUser(userId){
    // var user = getUser(id);
    // print(userId);
    try {
      // chatData!.forEach((element) {
      //   print("${userId} = ${element.userId}");
      // });
      if (chatData!.isNotEmpty) {
        ChatData _chatData = chatData!.where((element) =>
        element.userId.toString() != userId.toString())
            .first;
        print(_chatData.userId);
        if(_chatData == null) return null;
        return _chatData;
      } else {
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }
  ChatData? getMyChat(userId){
    // var user = getUser(id);
    try {
      if (chatData!.isNotEmpty) {
        ChatData _chatData = chatData!.where((element) =>
        element.userId.toString() == userId.toString())
            .first;
        if(_chatData == null) return null;
        return _chatData;
      } else {
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['last_msg'] = this.lastMsg;
    data['last_msg_date'] = this.lastMsgDate;
    data['status'] = this.status;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['time_ago'] = this.timeAgo;

    if (this.chatData != null) {
      data['chat_data'] = this.chatData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatData {
  String? id;
  String? chatId;
  String? userId;
  String? unreadCount;
  String? createdAt;
  String? updatedAt;
  User? user;

  ChatData(
      {this.id,
        this.chatId,
        this.userId,
        this.unreadCount,
        this.createdAt,
        this.updatedAt,
        this.user});

  ChatData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    chatId = json['chat_id'].toString();
    userId = json['user_id'].toString();
    unreadCount = json['unread_count'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['chat_id'] = this.chatId.toString();
    data['user_id'] = this.userId.toString();
    data['unread_count'] = this.unreadCount.toString();
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}