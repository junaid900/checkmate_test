class CMSendNotificationData {
  String? userId;
  String? image;
  String? title;
  String? desc;
  String? click;
  String? type;
  String? data;
  String? notificationType;

  CMSendNotificationData(
      {this.userId,
        this.image,
        this.title,
        this.desc,
        this.click,
        this.type,
        this.data,
        this.notificationType});

  CMSendNotificationData.fromJson(Map<String, dynamic> json) {
    userId = (json['user_id'] ?? '').toString();
    image = json['image'];
    title = json['title'];
    desc = json['desc'];
    click = json['click'];
    type = json['type'];
    data = json['data'];
    notificationType = json['notification_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['image'] = this.image;
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['click'] = this.click;
    data['type'] = this.type;
    data['data'] = this.data;
    data['notification_type'] = this.notificationType;
    return data;
  }
}
