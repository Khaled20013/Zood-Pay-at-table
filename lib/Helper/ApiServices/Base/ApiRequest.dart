enum RequestType { get, post, put, delete, upload }

class ApiRequest {
  late String url;
  Map<String, String> header = {};
  dynamic body;
  Map<String, dynamic> query = {};
  bool isCaching = false;
  bool returnCaching = false;
  bool inCachReturnNewData = false;

  String cashKey = "";
  RequestType type = RequestType.post;
}
