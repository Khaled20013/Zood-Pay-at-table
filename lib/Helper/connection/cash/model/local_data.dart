class BaseLocal {
  DateTime? time;
  String? model;

  BaseLocal({this.time, this.model});

  BaseLocal.fromJson(Map<String, dynamic> json) {
    try {
      time = DateTime.parse(json['time'] ?? "");
      model = json['model'];
    } catch (_) {
      time = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time.toString();
    data['model'] = model;
    return data;
  }
}
