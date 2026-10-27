import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Helper/kPrint.dart';
import '../ApiServices/Base/ApiEndpoints.dart';
import '../ApiServices/Base/ApiRequest.dart';
import '../ApiServices/Base/KApiResponse.dart';
import 'cash/CashLocal.dart';

const int cacheDurationHours = 0;

class HttpClientHelper {
  HttpClientHelper._privateConstructor();

  static final HttpClientHelper _instance =
      HttpClientHelper._privateConstructor();

  factory HttpClientHelper() {
    return _instance;
  }

  /// Tests swap this for an `http.testing.MockClient`.
  static http.Client Function() clientFactory = http.Client.new;

  String getkey(String cashKey, String url) {
    String key = "$cashKey-$url";

    return key;
  }

  String prettyJson(dynamic json) {
    var spaces = ' ' * 4;
    var encoder = JsonEncoder.withIndent(spaces);
    try {
      return encoder.convert(json);
    } catch (_) {
      return json.toString();
    }
  }

  void requestUrl(String path, RequestType type,
      {dynamic body,
      bool isCaching = false,
      bool inCachReturnNewData = false,
      bool returnCaching = false,
      String cashKey = "",
      Map<String, String> headers = const {},
      final Function(KApiResponse)? onResult,
      required Map<String, dynamic> query}) {
    post(path,
        type: type,
        body: body,
        query: query,
        isCaching: isCaching,
        inCachReturnNewData: inCachReturnNewData,
        returnCaching: returnCaching,
        cashKey: cashKey,
        headers: headers,
        onResult: onResult);
  }

  Future<KApiResponse?> getCashedData(
      {required String cashKey, required String url}) async {
    final localData = await CashLocal.getString(getkey(cashKey, url));
    if (localData.isNotEmpty) {
      kLog("$cashKey return Cashed data");

      try {
        KApiResponse cashRespone = KApiResponse(localData, 200, true);
        return cashRespone;
      } catch (err) {
        kLog("error: $err", logType: kLogType.error);
      }
    }

    return null;
  }

  /// GET sends [query] (and a map [body], like the original client) as the
  /// query string; other verbs send [body] as JSON.
  Uri buildUri(String path, RequestType type,
      {dynamic body, Map<String, dynamic> query = const {}}) {
    final uri = Uri.parse(path);
    final params = <String, String>{
      ...uri.queryParameters,
      for (final e in query.entries)
        if (e.value != null) e.key: e.value.toString(),
      if (type == RequestType.get && body is Map)
        for (final e in body.entries)
          if (e.value != null) e.key.toString(): e.value.toString(),
    };
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  Future<void> post(String path,
      {dynamic body,
      Map<String, dynamic> query = const {},
      RequestType type = RequestType.post,
      bool isCaching = false,
      bool inCachReturnNewData = false,
      bool returnCaching = false,
      String cashKey = "",
      Map<String, String> headers = const {},
      Function(KApiResponse)? onResult}) async {
    final uri = buildUri(path, type, body: body, query: query);
    final url = uri.toString();

    kLog("$cashKey con Url ${type.name.toUpperCase()}: $url");

    // ======================================================================
    Map<String, dynamic> cashData = {};
    // check Cash
    if (isCaching == true && returnCaching) {
      KApiResponse? cashRespone =
          await getCashedData(cashKey: cashKey, url: url);
      if (cashRespone != null) {
        cashData = toJSon(cashRespone.body);
        if (cashData.isNotEmpty) {
          onResult!(cashRespone);
        }
      }
    }
    // ======================================================================

    var requestJson = jsonEncode(body);
    var client = clientFactory();

    var respStr = "";
    int statusCode = 0;

    try {
      final http.Response response = await switch (type) {
        RequestType.get => client.get(uri, headers: headers),
        RequestType.put =>
          client.put(uri, headers: headers, body: requestJson),
        RequestType.delete =>
          client.delete(uri, headers: headers, body: requestJson),
        _ => client.post(uri, headers: headers, body: requestJson),
      }
          .timeout(ApiEndpoints.timeout);
      respStr = utf8.decode(response.bodyBytes);
      statusCode = response.statusCode;
    } catch (ex) {
      kLog("$cashKey connection error: $ex", logType: kLogType.error);
      onResult!(KApiResponse.connectionFailure());
      return;
    } finally {
      client.close();
    }

    kLogJson(
      url: url,
      cashKey: cashKey,
      requestType: type.name.toUpperCase(),
      body: type == RequestType.get ? "" : prettyJson(sanitizeForLog(body)),
      response: prettyJson(sanitizeForLog(toJSon(respStr))),
    );

    if (statusCode >= 200 && statusCode < 299 && isCaching) {
      CashLocal.saveCash(getkey(cashKey, url), respStr,
          duration: const Duration(hours: cacheDurationHours));

      if (cashData.isNotEmpty && inCachReturnNewData == false) {
        return;
      }
    }
    onResult!(KApiResponse(respStr, statusCode, false));
  }

  Map<String, dynamic> toJSon(String? body) {
    if (body == null || body.isEmpty) {
      return {};
    }
    try {
      final decoded = json.decode(body);
      return decoded is Map<String, dynamic> ? decoded : {"data": decoded};
    } catch (err) {
      return {};
    }
  }
}
