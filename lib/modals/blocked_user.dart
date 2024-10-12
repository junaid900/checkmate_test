import 'User.dart';

class BlockedUser {
  int? id;
  int? userId;
  int? blockedUserId;
  String? createdAt;
  User? user;

  BlockedUser(
      {this.id, this.userId, this.blockedUserId, this.createdAt, this.user});

  BlockedUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    blockedUserId = json['blocked_user_id'];
    createdAt = json['created_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['blocked_user_id'] = this.blockedUserId;
    data['created_at'] = this.createdAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}