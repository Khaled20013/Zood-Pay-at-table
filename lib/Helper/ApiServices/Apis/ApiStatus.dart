class ApiStatus {
  ApiStatus({required this.status, this.errorMessage = "", this.response});

  bool status = false;

  String errorMessage = "";

  Map<String, dynamic>? response = {};

  void fromJson(Map<String, dynamic> json) {
    response = json;

    status = json['status'] ?? false;
    errorMessage = json['message'] ?? "";
  }

  void checkApiStatus(Map<String, dynamic> json) {
    response = json;

    Map<String, dynamic> meta = json["meta"] ?? 0;

    status = meta["status"] ?? false;
    errorMessage = meta['message'] ?? "";
  }
}
