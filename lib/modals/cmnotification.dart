class CMNotification {
  int? id;
  int? receiverId;
  String? title;
  String? description;
  String? image;
  String? click;
  String? readStatus;
  String? data;
  String? type;
  String? createdAt;
  String? updatedAt;
  String? timeAgo;

  CMNotification(
      {this.id,
        this.receiverId,
        this.title,
        this.description,
        this.image,
        this.click,
        this.readStatus,
        this.data,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.timeAgo});

  CMNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    receiverId = json['receiver_id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    click = json['click'];
    readStatus = json['read_status'];
    data = json['data'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    timeAgo = json['time_ago'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['receiver_id'] = this.receiverId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['click'] = this.click;
    data['read_status'] = this.readStatus;
    data['data'] = this.data;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['time_ago'] = this.timeAgo;
    return data;
  }
}