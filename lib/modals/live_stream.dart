import 'User.dart';

class LiveStream {
  String? id;
  String? channelName;
  String? userId;
  String? title;
  String? description;
  String? startTime;
  String? agoraUid;
  String? token;
  String? endTime;
  String? status;
  String? createdAt;
  User? user;
  LiveStream(
      {this.id,
        this.channelName,
        this.userId,
        this.title,
        this.description,
        this.startTime,
        this.endTime,
        this.status,
        this.agoraUid,
        this.createdAt,
        this.user});

  LiveStream.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? '').toString();
    channelName = json['channel_name'];
    userId = (json['user_id'] ?? "").toString();
    title = (json['title'] ?? "").toString();
    description = (json['description'] ?? "").toString();
    startTime = (json['start_time'] ?? "").toString();
    agoraUid = (json['agora_uid'] ?? "").toString();
    endTime = (json['end_time'] ?? "").toString();
    token = (json['token'] ?? "").toString();
    status = json['status'];
    createdAt = (json['created_at'] ?? "").toString();
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['channel_name'] = this.channelName;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}