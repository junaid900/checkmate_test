import 'package:checkmate/modals/cmpost.dart';

class SavedPost {
  int? id;
  int? postId;
  int? userId;
  String? createdAt;
  CMPost? post;

  SavedPost({this.id, this.postId, this.userId, this.createdAt, this.post});

  SavedPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['post_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    post = json['post'] != null ? new CMPost.fromJson(json['post']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['post_id'] = this.postId;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    if (this.post != null) {
      data['post'] = this.post!.toJson();
    }
    return data;
  }
}