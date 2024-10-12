import 'package:checkmate/modals/post_comment.dart';

import '../constraints/helpers/helper.dart';
import 'User.dart';

class StoryComment {
  String? id;
  String? storyId;
  String? userId;
  String? comment;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? commentId;
  String? parentId;
  String? replyTo;
  User? user;
  User? repliedTo;
  int commentLikesCount = 0;
  bool isLike = false;
  int repliesCount = 0;
  List<StoryComment> replies = [];
  bool isReplyLoading = false;
  int currentPage = 0;
  int maxPages = 0;
  bool noMore = false;
  bool viewReplies = false;

  StoryComment(
      {this.id,
        this.storyId,
        this.userId,
        this.comment,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.user});

  StoryComment.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? '').toString();
    storyId = (json['story_id'] ?? '').toString();
    userId = (json['user_id'] ?? '').toString();
    comment = json['comment'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    commentId = json['comment_id'] != null ? json['comment_id'].toString(): null;
    parentId = json['parent_id'] != null ? json['parent_id'].toString(): null;
    replyTo = json['reply_to'] != null ? json['reply_to'].toString(): null;
    repliedTo = json['replied_to'] != null ? new User.fromJson(json['replied_to']) : null;
    repliesCount = json['replies_count'] != null ? convertNumber(json["replies_count"].toString()) : 0;
    commentLikesCount = json['comment_likes_count'] != null ? convertNumber(json["comment_likes_count"].toString()) : 0;
    isLike = commentLikesCount > 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['story_id'] = this.storyId;
    data['user_id'] = this.userId;
    data['comment'] = this.comment;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}