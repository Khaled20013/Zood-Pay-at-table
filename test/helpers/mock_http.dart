import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zood_pay_at_table/Helper/ApiServices/Base/DemoDataPolicy.dart';
import 'package:zood_pay_at_table/Helper/Configs/kcore.dart';
import 'package:zood_pay_at_table/Helper/connection/http_client.dart';

const testBaseUrl = 'https://api.test/api/v1';

/// Routes every API call to [handler] and records the requests.
class MockApi {
  MockApi(this.handler) {
    config = Config(url: testBaseUrl);
    DemoDataPolicy.useDummyData = false;
    DemoDataPolicy.fallbackToDummyOnNetworkError = false;
    HttpClientHelper.clientFactory = () => MockClient((request) async {
      requests.add(request);
      return handler(request);
    });
  }

  final Future<http.Response> Function(http.Request request) handler;
  final List<http.Request> requests = [];

  /// Restores the real client; call from `tearDown`.
  static void reset() {
    HttpClientHelper.clientFactory = http.Client.new;
  }
}

http.Response jsonResponse(int status, Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// `{ "success": false, "message": ..., "errors": {} }`
http.Response errorResponse(int status, String message) =>
    jsonResponse(status, {'success': false, 'message': message, 'errors': {}});

/// Serves the bundled demo data with no delay.
void useDummyData() {
  DemoDataPolicy.useDummyData = true;
  DemoDataPolicy.simulatedLatency = Duration.zero;
}
