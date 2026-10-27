import 'dart:convert';

import '../../Errors/AppException.dart';

class KApiResponse {
  String? body;
  dynamic data;
  Map<String, String> headers = const {};
  Map<String, dynamic>? responseMap = {};
  bool isCashed = false;

  int statusCode = 500;
  bool success = false;
  String message = "Something went wrong please try again later";

  /// True when the request never got an answer (offline, DNS, timeout).
  bool connectionFailed = false;

  /// Typed failure for the UI, set by `DemoDataPolicy` / the `<X>Api` class.
  AppException? error;

  static KApiResponse successRespone() {
    return KApiResponse('{"success": true, "status": 200, "message": "تم بنجاح"}',
        200, false);
  }

  static KApiResponse failRespone({
    int? statusCode,
    String? message,
  }) {
    final res = jsonEncode({
      "success": false,
      "status": statusCode ?? 500,
      "message": message ?? "Something went wrong please try again later",
    });

    return KApiResponse(res, statusCode ?? 500, false);
  }

  static KApiResponse connectionFailure() =>
      KApiResponse(null, 0, false)..connectionFailed = true;

  /// A `200` carrying [json], used for the bundled demo data.
  static KApiResponse fromJson(Map<String, dynamic> json) =>
      KApiResponse(jsonEncode(json), 200, false);

  static KApiResponse failure(AppException error) =>
      KApiResponse(null, 500, false)..error = error;

  String getMessageList() {
    try {
      final messages = responseMap?["message"];
      if (messages is List) {
        return messages.isEmpty ? message : messages.first.toString();
      }
      return message;
    } catch (e) {
      return message;
    }
  }

  List? responseList = [];

  KApiResponse(this.body, this.statusCode, this.isCashed) {

    if (body == null) {
      success = false;
    } else {
      try {
        var decoded = json.decode(body!);

        if (decoded is Map<String, dynamic>) {
          responseMap = decoded;
          final raw = responseMap?["message"] ?? responseMap?["massage"];
          message = raw is String ? raw : "";

          if (message.isEmpty && !_isOk) {
            message = responseMap?["error"]?.toString() ?? "Error $statusCode";
          }

          success = _isOk;
        } else if (decoded is List) {
          responseList = decoded;
          responseMap = {};
          message = "";
          success = _isOk;
        } else {
          success = false;
          message = "Invalid response format";
        }
      } catch (e) {
        success = false;
        // Keep the raw (e.g. HTML) body so it can be inspected.
        message = body ?? "invalid to connect .";
      }
    }
  }

  bool get _isOk => statusCode >= 200 && statusCode < 300;
}
