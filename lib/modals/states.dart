class States {
  String? id;
  String? name;
  String? status;

  States({this.id, this.name, this.status});

  States.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? '').toString();
    name = (json['name'] ?? '').toString();
    status = (json['status'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return this.name ?? "";
  }
}
