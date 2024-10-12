import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/modals/city.dart';
import 'package:checkmate/modals/states.dart';

import 'User.dart';

class CMPost {
  int? id;
  int? userId;
  String? name;
  String? gender;
  int? stateId;
  int? cityId;
  String? age;
  String? race;
  String? ethnicity;
  String? profileImage;
  String? ratingCommunication;
  String? ratingLoyalty;
  String? ratingTime;
  String? ratingBehaviour;
  String? description;
  int? clicks;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<Images>? images;
  List<Videos>? videos;
  User? user;
  States? state;
  City? city;
  bool isSaved = false;

  CMPost(
      {this.id,
        this.userId,
        this.name,
        this.gender,
        this.stateId,
        this.cityId,
        this.age,
        this.race,
        this.ethnicity,
        this.profileImage,
        this.ratingCommunication,
        this.ratingLoyalty,
        this.ratingTime,
        this.ratingBehaviour,
        this.description,
        this.clicks,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.images,
        this.videos,
        this.user,
        this.state,
        this.city,
        this.isSaved = false});

  CMPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    gender = json['gender'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    age = json['age'];
    race = json['race'];
    ethnicity = json['ethnicity'];
    profileImage = json['profile_image'];
    ratingCommunication = (json['rating_communication'] ?? 0).toString();
    ratingLoyalty = (json['rating_loyalty']?? 0).toString();
    ratingTime = (json['rating_time']?? 0).toString();
    ratingBehaviour = (json['rating_behaviour']?? 0).toString();
    description = json['description'];
    clicks = json['clicks'];
    status = json['status'];
    createdAt = json['created_at'];
    isSaved = json['is_saved_count'] != null ? convertNumber(json['is_saved_count']) > 0 : false;
    updatedAt = json['updated_at'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    if (json['videos'] != null) {
      videos = <Videos>[];
      json['videos'].forEach((v) {
        videos!.add(new Videos.fromJson(v));
      });
    }
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    state = json['state'] != null ? new States.fromJson(json['state']) : null;
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['age'] = this.age;
    data['race'] = this.race;
    data['ethnicity'] = this.ethnicity;
    data['profile_image'] = this.profileImage;
    data['rating_communication'] = this.ratingCommunication;
    data['rating_loyalty'] = this.ratingLoyalty;
    data['rating_time'] = this.ratingTime;
    data['rating_behaviour'] = this.ratingBehaviour;
    data['description'] = this.description;
    data['clicks'] = this.clicks;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.videos != null) {
      data['videos'] = this.videos!.map((v) => v.toJson()).toList();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    return data;
  }
}

class Images {
  int? id;
  int? postId;
  String? image;
  String? type;
  String? status;

  Images({this.id, this.postId, this.image, this.status, this.type});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['post_id'];
    image = json['image'];
    type = 'image';
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['post_id'] = this.postId;
    data['image'] = this.image;
    data['status'] = this.status;
    return data;
  }
}

class Videos {
  int? id;
  int? postId;
  String? video;
  String? thumbnail;
  String? status;

  Videos({this.id, this.postId, this.video, this.status, this.thumbnail});

  Videos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['post_id'];
    video = json['video'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['post_id'] = this.postId;
    data['video'] = this.video;
    data['status'] = this.status;
    return data;
  }
}