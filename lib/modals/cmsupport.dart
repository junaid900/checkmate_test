class CMSupport {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? status;
  String? createdAt;

  CMSupport(
      {this.id,
        this.userId,
        this.title,
        this.description,
        this.status,
        this.createdAt});

  CMSupport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}