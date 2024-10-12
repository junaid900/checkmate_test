import 'dart:convert';

import 'package:checkmate/constraints/helpers/helper.dart';

import 'User.dart';

class Story {
  String? id;
  String? userId;
  String? video;
  String? caption;
  List? tags;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool isSaved = false;
  bool isLiked = false;
  int? commentsCount;
  int? likeCount;
  int? saveCount;
  User? user;

  Story(
      {this.id,
        this.userId,
        this.video,
        this.caption,
        this.tags,
        this.status,
        this.createdAt,
        this.updatedAt,
        // this.isSavedCount,
        this.commentsCount,
        this.user});

  Story.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? '').toString();
    userId = (json['user_id'] ?? '').toString();
    video = json['video'];
    caption = json['caption'];
    tags = jsonDecode((json['tags'] ?? '[]'));
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isSaved = convertNumber(json['is_saved_count'].toString() ?? "0") > 0;
    isLiked = convertNumber(json['is_liked_count'].toString() ?? "0") > 0;
    commentsCount = json['comments_count'];
    likeCount = json['likes_count'];
    saveCount = json['saves_count'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['video'] = this.video;
    data['caption'] = this.caption;
    data['tags'] = this.tags;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    // data['is_saved_count'] = this.isSavedCount;
    data['comments_count'] = this.commentsCount;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}