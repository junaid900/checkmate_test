import 'package:checkmate/constraints/helpers/helper.dart';

class User {
  String? id;
  String? username;
  String? fname;
  String? email;
  String? phoneNumber;
  String? profileImage;
  String? coverImage;
  String? about;
  String? age;
  String? address;
  String? lat;
  String? lng;
  String? googleId;
  String? appleId;
  String? facebookId;
  String? referalId;
  String? rolesId;
  String? fcmToken;
  String? status;
  String? isPhoneVerified;
  String? createdAt;
  String? updatedAt;
  String? clicks;
  String? followersCount;
  String? followingCount;
  String? postsCount;
  String? localNotifications;
  String? pushNotifications;
  String? password;
  bool isFollowing = false;


  User(
      {this.id,
        this.username,
        this.fname,
        this.email,
        this.phoneNumber,
        this.profileImage,
        this.coverImage,
        this.age,
        this.address,
        this.lat,
        this.lng,
        this.googleId,
        this.appleId,
        this.facebookId,
        this.referalId,
        this.rolesId,
        this.about,
        this.fcmToken,
        this.status,
        this.isPhoneVerified,
        this.createdAt,
        this.updatedAt,
        this.followersCount,
        this.followingCount,
        this.postsCount,
        this.localNotifications,
        this.pushNotifications,
        this.password,
        this.clicks,
      this.isFollowing = false});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    username = (json['username'] ?? '').toString();
    fname = (json['fname'] ?? '').toString();
    email = (json['email'] ?? '').toString();
    phoneNumber = (json['phone_number'] ?? '').toString();
    profileImage = (json['profile_image'] ?? '').toString();
    coverImage = (json['cover_image'] ?? '').toString();
    age = (json['age'] ?? '').toString();
    address = (json['address'] ?? '').toString();
    lat = (json['lat'] ?? '').toString();
    lng = (json['lng'] ?? '').toString();
    googleId = (json['google_id'] ?? '').toString();
    appleId = (json['apple_id'] ?? '').toString();
    facebookId = (json['facebook_id'] ?? '').toString();
    referalId = (json['referal_id'] ?? '').toString();
    about = (json['about'] ?? '').toString();
    rolesId = (json['roles_id'] ?? '').toString();
    fcmToken = (json['fcm_token'] ?? '').toString();
    status = (json['status'] ?? '').toString();
    isPhoneVerified = (json['is_phone_verified'] ?? '').toString();
    createdAt = (json['created_at'] ?? '').toString();
    updatedAt = (json['updated_at'] ?? '').toString();
    clicks = (json['clicks'] ?? '').toString();
    followersCount = (json['followers_count'] ?? '').toString();
    followingCount = (json['following_count'] ?? '').toString();
    localNotifications = (json['local_notifications'] ?? '').toString();
    pushNotifications = (json['push_notifications'] ?? '').toString();
    postsCount = (json['posts_count'] ?? '').toString();
    password = (json['password'] ?? '').toString();
    isFollowing = convertNumber(json['is_user_following_count'].toString()) > 0 ? true: false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['fname'] = this.fname;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['profile_image'] = this.profileImage;
    data['cover_image'] = this.coverImage;
    data['age'] = this.age;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['google_id'] = this.googleId;
    data['facebook_id'] = this.facebookId;
    data['referal_id'] = this.referalId;
    data['roles_id'] = this.rolesId;
    data['fcm_token'] = this.fcmToken;
    data['status'] = this.status;
    data['is_phone_verified'] = this.isPhoneVerified;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['clicks'] = this.clicks;
    data['local_notifications'] = this.localNotifications;
    data['push_notifications'] = this.pushNotifications;
    return data;
  }
}