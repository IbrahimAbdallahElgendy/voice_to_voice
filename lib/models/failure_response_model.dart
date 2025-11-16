class FailureResponseModel {
  String? key;
  bool? success;
  String? msg;
  dynamic data;

  FailureResponseModel({this.key, this.success, this.msg, this.data});

  FailureResponseModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    success = json['success'];
    msg = json['message'] ?? json['msg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}
