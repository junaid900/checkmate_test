import 'package:checkmate/modals/story.dart';

class SavedStory {
  int? id;
  int? storyId;
  int? userId;
  String? createdAt;
  Story? story;

  SavedStory({this.id, this.storyId, this.userId, this.createdAt, this.story});

  SavedStory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storyId = json['story_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    story = json['story'] != null ? new Story.fromJson(json['story']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['story_id'] = this.storyId;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    if (this.story != null) {
      data['story'] = this.story!.toJson();
    }
    return data;
  }
}
